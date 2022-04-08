require! {
    \express
    \body-parser
    \./lib.ls : { make-request }
    \./get-db.ls
    \sha256
    \moment
}

eth_getTransactionReceipt = (config, body, cb)->
    err, db <- get-db config 
    return cb err if err?
    tx = body.params.0
    err, data <- db.get "tx/#{tx}"
    return cb err if err?
    cb null, data

eth_getBlockByNumber = (config, body, cb)->
    err, db <- get-db config
    return cb err if err?
    number = parseInt(body.params.0, 16)
    err, data <- db.get "blocks/#{number}"
    return cb err if err?
    cb null, data


proxify-request = (config, body, cb)->
    err, db <- get-db config 
    return cb err if err?
    hash = sha256 JSON.stringify { body.method, body.params }
    err, cache <- db.get "cache/#{hash}"
    return cb err if err? and err?not-found isnt yes 
    return cb null, cache.data if cache? and cache.deadline < moment.utc!.unix!
    err, data <- make-request config , body.method , body.params
    return cb err if err?
    deadline = moment.utc!.add( \5 , \seconds ).unix!
    err, cache <- db.put "cache/#{hash}", { data , deadline }
    return cb err if err?
    cb null, data



methods = { eth_getTransactionReceipt, eth_getBlockByNumber }

execute-request  = (config, body, cb)->
    return cb "expected object"  if typeof! body isnt \Object
    return cb "expected jsonrpc" if typeof! body.jsonrpc isnt \String
    return cb "expected method"  if typeof! body.method isnt \String
    func =
        | typeof! methods[body.method] isnt \Function => proxify-request
        | _ => methods[body.method]
    err, result <- func config, body
    return cb err if err?
    cb null { result }


export init-app = (config, cb)->
    app = express!
    app.use(body-parser.json!)
    express.post "/", (req, res)->
        err, data <- execute-request config, req.body
        return res.status(400).send("#{err}") if err?
        res.send data
    express.listen config.port
    cb "exit"

