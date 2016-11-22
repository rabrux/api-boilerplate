nodemailer   = require 'nodemailer'
emailConfig  = require '../conf/email.json'
transporter  = nodemailer.createTransport emailConfig


module.exports = ( options, callback ) ->

  if !options or !options.from or !options.to or !options.subject or !options.html
    return callback 'MISSING_PARAMETERS', false

  transporter.sendMail options, ( err, info ) ->
    if err
      return callback 'EMAIL_CAN_NOT_SEND', false
    return callback null, true
