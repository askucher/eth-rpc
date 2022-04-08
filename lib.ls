require! {
    \superagent : { post }
    \./get-db.ls
    \moment
}

try-parse = (text, cb)->
    try
        cb null, JSON.parse(text)
    catch err
        cb err

get-body = (model, cb)->
    try-parse model.text, cb

speed = {}

make-request-internal = (config, method, params, cb)->
    err, db <- get-db config 
    return cb err if err?
    make-request.id = make-request.id ? 1
    make-request.id += 2
    req =  { jsonrpc : \2.0 , method , params , id : make-request.id }
    return cb err if err?
    start-time = moment.utc!.format("YYYY-MM-DDTHH:mm:ss.SSS")
    err, model <- post config.host, req .timeout({ deadline: 60000 }).end
    return cb err if err?
    speed[method] = if speed[method]? then speed[method].slice(-100) else []
    ms = moment.utc!.diff(moment.utc(start-time, "YYYY-MM-DDTHH:mm:ss.SSS"))
    speed[method].push Math.round(Math.round(ms) / 10) / 100
    err <- db.put "speed/#{method}", speed[method]
    return cb err if err?
    err <- db.put "last-call/#{method}", moment.utc!.format("YYYY-MM-DDTHH:mm:ss.SSS")
    return cb err if err?
    err, body <- get-body model
    return cb err if err?
    return cb "expected body" if not body?jsonrpc?
    cb null, body.result

make-request-trials = (trials, config, method, params, cb)->
    err, data <- make-request-internal config, method, params
    return cb null, data if not err?
    return cb err if err? and err isnt 'expected body'
    return cb err if trials is 0
    <- set-timeout _, 1000
    next-trials = trials - 1
    make-request-trials next-trials, config, method, params, cb

export make-request = (config, method, params, cb)->
    make-request-trials 3, config, method, params, cb

web3-get-transaction-receipt = (config, hash, cb)->
    make-request config , \eth_getTransactionReceipt , [hash], cb

web3-get-block-number = (config, number, cb)->
    hex = '0x' + number.to-string 16
    make-request config , \eth_getBlockByNumber , [hex, no], cb

web3-get-block-number-with-cache = (config, number, cb)->
    err, db <- get-db config 
    return cb err if err?
    err, block-data <- db.get "blocks/#{number}"
    return cb err if err? and err?not-found isnt yes
    return cb null, block-data if block-data?
    err, block-data <- web3-get-block-number config, number
    return cb err if err?
    err, isFinalized <- check-block-finalized config, block-data
    return cb err if err?
    return cb "block #{number} is not finalized" if isFinalized is no 
    err <- db.put "blocks/#{number}" , block-data
    cb null, block-data

export precache-blocks = (config, number-start, cb)->
    console.log number-start    
    err, block-data <- web3-get-block-number-with-cache config, number-start
    console.log err if err?
    return precache-blocks config, number-start, cb if err?
    <- set-immediate
    err <- fill-block-transactions-one-by-one config, block-data.transactions
    return precache-blocks config, number-start, cb if err?
    precache-blocks config, (number-start + 1), cb





get-next-index = (config, name, cb)->
    err, db <- get-db config
    return cb err if err?
    err, number-guess <- db.get name
    return cb err if err? and err?not-found isnt 
    
    number =
        | err?not-found is yes => 0
        | _ => number-guess + 1   
    cb null, number

check-block-finalized = (config, block, cb)->
    return cb "not support chain #{config.db}" if config.db isnt \velas
    # just skip null blocks for now
    return cb null, true, if block is null
    return cb null, true if block.isFinalized is yes 
    cb null, no



export load-and-save-blocks = (config, cb)->
    err, db <- get-db config
    return cb err if err?
    err, number <- get-next-index config, \blocks/number
    return cb err if err?
    #console.log number 
    err, block-data <- web3-get-block-number-with-cache config, number
    #console.log err, block-data
    return cb err if err?
    err <- db.put "blocks/#{number}", block-data
    return cb err if err?
    err <- db.put \blocks/number , number
    return cb err if err?
    <- set-immediate
    load-and-save-blocks config, cb


fill-tx = (config, tx, cb)->
    return cb "expected tx" if typeof! tx isnt \String
    err, db <- get-db config
    return cb err if err?
    err, data <- db.get "tx/#{tx}"
    return cb err if err? and err?not-found isnt yes 
    return cb null, data if data?
    err, data <- web3-get-transaction-receipt config, tx
    return cb err if err?
    err <- db.put "tx/#{tx}", data 
    return cb err if err?
    cb null, data

fill-block-transactions-one-by-one = (config, [tx, ...txs], cb) ->
    return cb null if not tx?
    err <- fill-tx config, tx 
    return cb err if err?
    <- set-immediate
    fill-block-transactions-one-by-one config, txs, cb
    

fill-block-transactions = (config, number, cb)->
    err, db <- get-db config
    return cb err if err?
    err, block-data <- db.get "blocks/#{number}"
    return cb null if not block-data?
    return cb "expected transactions" if typeof! block-data.transactions isnt \Array
    fill-block-transactions-one-by-one config, block-data.transactions, cb


export load-and-save-transactions = (config, cb)->
    err, db <- get-db config
    return cb err if err?
    err, fill-number <- get-next-index config, \blocks/filled/number
    return cb err if err?
    err, number <- get-next-index config, \blocks/number
    return cb err if err?
    return cb "nothing to do. filled block #{fill-number}, known block #{number}" if fill-number >= number - 1
    err <- fill-block-transactions config, fill-number
    return cb err if err?
    err <- db.put \blocks/filled/number , fill-number
    return cb err if err?
    <- set-immediate 
    load-and-save-transactions config, cb

# to mark used
load-and-save-transactions










