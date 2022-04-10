require! {
    \./lib.ls : { precache-blocks }
    \./config.json
    \./cb.ls
    \./proxies.ls : { list, login, password, https_port, socks5_port }
}

#host = 'http://15.235.43.12:8899'

host = \https://evmexplorer.velas.com/rpc

run-cacher = (address, start)->
    proxy = { login, password, address: address }
    precache-blocks { ...config, host, proxy }, start, 1, console.log


run-index = (i, start)->
    start = (i * 100000) + start
    http = "socks://#{login}:#{password}@#{list[i]}:#{socks5_port}"
    console.log '[-]', http, start
    run-cacher http, start

#for i of list
#    run-index index, 5000000

run-index 15, 5000000