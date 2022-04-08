require! {
    \./lib.ls : { load-and-save-blocks }
    \./config.json
}


err <- load-and-save-blocks config
console.log 'exit', err