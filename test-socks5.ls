require! {
    \superagent
}

require( \superagent-proxy )(superagent)

proxy = \socks://Selastegno:T9v5WgU@83.147.222.169:45786


superagent.get("http://api.ipify.org?format=json").proxy(proxy).timeout({ deadline: 60000 }).end(console~log)
