require! {
    \./lib.ls : { precache-blocks }
    \./config.json
    \./cb.ls
}

precache-blocks { ...config, host: "https://evmarchive.mainnet.velas.com" }, 30000000, 30266878, cb