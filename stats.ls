require! {
    \./get-db.ls
    \./config.json
    \./lib.ls : { make-request }
    \./cb.ls
    \diskusage : { check }
    \cli-table : Table
    \asciichart

}

err, db <- get-db config
return cb err if err?
err, known-block <- db.get \blocks/number
return cb err if err?

err, filled-block <- db.get \blocks/filled/number
return cb err if err?

err, latest-block-hex <- make-request config , \eth_blockNumber , []
return cb err if err?

latest-block = parse-int latest-block-hex, 16

percent-known =  (100 / latest-block) * known-block
percent-filled = (100 / latest-block) * filled-block

err, info <- check \/
return cb err if err?

table = new Table { head : ['Known Block', 'Filled Block', 'Latest Block', 'Disk Space'], colWidths : [20, 20, 20, 20] }

table.push [known-block, filled-block, latest-block, parse-int(info.available / 1024 / 1024) + ' GB']
table.push [percent-known, percent-filled, 100, (100 / info.total * info.available)].map(-> it + ' %')


build-chart = (name, cb)->
    err, data <- db.get "speed/#{name}"
    return cb err if err?
    cb null, asciichart.plot data , { height: 10 }

err, eth_getTransactionReceipt  <- build-chart \eth_getTransactionReceipt
return cb err if err?

err, eth_getBlockByNumber  <- build-chart \eth_getBlockByNumber
return cb err if err?

#console.log table.toString!
console.log eth_getTransactionReceipt
#console.log eth_getBlockByNumber

cb null



