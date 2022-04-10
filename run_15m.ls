require! {
    \./lib.ls : { precache-blocks }
    \./config.json
    \./cb.ls
    \./proxies.ls : { list, login, password, https_port, socks5_port }
}

#host = 'http://15.235.43.12:8899'

host = \https://evmexplorer.velas.com/rpc

run-cacher = (address, start)->
    console.log 'run', address, start
    proxy = { login, password, address: address }
    precache-blocks { ...config, host, proxy }, start, 1, console.log

start = 15000000

for i of list
    start = (i * 100000) + start
    http = "socks://#{login}:#{password}@#{list[i]}:#{socks5_port}"
    run-cacher http, start