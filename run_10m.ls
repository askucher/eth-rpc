require! {
    \./lib.ls : { precache-blocks }
    \./config.json
    \./cb.ls
}

#host = 'http://15.235.43.12:8899'

host = 'https://evmarchive.mainnet.velas.com'

precache-blocks { ...config, host }, 10000000, 1, cb