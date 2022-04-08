require! {
    \./lib.ls : { load-and-save-transactions }
    \./config.json
}


err <- load-and-save-transactions config
console.log 'exit', err