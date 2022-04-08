require! {
    \levelup
    \multileveldown
    \net
    \level-rocksdb
}

db = level-rocksdb \./db

server = net.createServer (sock)->
    sock.on \error , sock~destroy
    sock.pipe(multileveldown.server(db)).pipe(sock)

<- server.listen 9000
console.log \started-db



