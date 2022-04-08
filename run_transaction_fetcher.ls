require! {
    \./lib.ls : { load-and-save-transactions }
}


err <- load-and-save-transactions { db: 'velas', host: "https://evmexplorer.velas.com/rpc" }
console.log 'exit', err