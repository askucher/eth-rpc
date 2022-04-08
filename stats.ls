require! {
    \./get-db.ls
    \./config.json
    \./lib.ls : { make-request }
    \./cb.ls
}



err, db <- get-db config
return cb err if err?
err, known-block <- db.get \blocks/number
return cb err if err?

err, filled-block <- db.get \blocks/filled/number
return cb err if err?

err, latest-block-hex <- make-request config , \eth_blockNumber , []
return cb err if err?

latest-block = parse-int(latest-block-hex, 16)

percent-known = ( 100 / latest-block ) * known-block
percent-filled = (100 / latest-block) * filled-block

cb null, "Known block #{known-block} (#{percent-known}%), Filled block #{filled-block} (#{percent-filled}%), Latest block #{latest-block}"



