require! {
    \./lib.ls : { load-and-save-blocks }
}


err <- load-and-save-blocks { db: 'velas', host: "https://evmexplorer.velas.com/rpc" }
console.log 'exit', err