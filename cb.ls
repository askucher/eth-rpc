require! {
    chalk : { red }

}

module.exports = (err, data)->
    console.log red('ERR'), err if err?
    console.log data if data?
    process.exit!