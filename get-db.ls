require! {
    \multileveldown
    \net
}


make-db = (cb)->
    db = multileveldown.client { retry: yes }
    connect = (cb)->
        sock = net.connect 9000
        remote = db.connect!

        sock.on \error , sock~destroy
        
        sock.on \close , ->
            remote.destroy!
            <- set-timeout _, 1000
            <- connect

        sock.pipe(remote).pipe(sock)
        cb null
    <- connect!
    cb null, db

parse-json = (data, cb)->
    try
        cb null, JSON.parse(data.to-string(\utf8))
    catch err 
        cb err


init-domain-db = (domain, cb)->
    err, db <- make-db
    get = (name, cb)->
        err, value <- db.get "#{domain}/#{name}"
        return cb err if err?
        err, model <- parse-json value 
        return cb err if err?
        cb null, model
    put = (name, value, cb)->
        str = JSON.stringify value
        db.put "#{domain}/#{name}", str, cb
    cb null, { get, put }

get-or-init-db = (config, cb)->
    name = "#{config.name}_#{config.network}"
    return cb null, get-or-init-db[name] if get-or-init-db[name]?
    err, db <- init-domain-db name
    return cb err if err?
    get-or-init-db[name] = db
    get-or-init-db config, cb


module.exports = get-or-init-db