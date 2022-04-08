require! {
    \./lib.ls : { load-and-save-transactions }
    \./config.json
    \./cb.ls
}


load-and-save-transactions config, cb