module.exports = (err, data)->
    console.log 'ERR', err if err?
    console.log data if data?
    process.exit!