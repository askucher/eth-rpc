require! {
    \./rpc.ls : { init-app }
    \./config.json
}


err <- init-app config
console.log 'exit', err