const serverless = require('serverless-http');
const express = require('express')
const { v4: uuidv4 } = require('uuid');
const { CORS_ORIGIN } = require('./config')
console.log(require('./config'))
console.log(CORS_ORIGIN)

const ID = uuidv4()

const app = express()
app.use(express.json())

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', "birdinthewind.com")
    res.setHeader('Access-Control-Allow-Methods', 'GET')
    res.setHeader('Access-Control-Allow-Headers', '*')
    next();
})
app.get(/.*/, (req, res) => {
    console.log(`${new Date().toISOString()} GET`)
    res.json({id: ID})
})

module.exports.handler = serverless(app);