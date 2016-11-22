randomstring = require 'randomstring'
validator    = require 'validator'

sendEmail = ( user, mailing, callback ) ->
  email = require( '../../email-templates/signup' )
    to  : user.username
    key : user.key
  # Send email
  if email
    mailing email, ( err, done ) ->
      if err
        return callback 'CAN_NOT_SEND_EMAIL'
      else
        return callback null
  else
    return callback 'INVALID_EMAIL_PARAMETERS'

module.exports = ( router, schemas, mailing ) ->

  router.post '/resend', ( req, res ) ->

    if not req.body.email
      return res.status( 400 ).send 'INVALID_DATA'

    # Validate email address
    if !validator.isEmail( req.body.email )
      return res.status( 400 ).send 'INVALID_EMAIL_ADDRESS'

    schemas.User.findOne { username: req.body.email }, ( err, user ) ->
      if err then throw err
      if not user
        return res.status( 400 ).send 'INVALID_USERNAME'

      if user.status != 'EMAIL_PENDING_VALIDATE'
        return res.status( 400 ).send 'ALREADY_VERIFIED'
      else
        sendEmail user, mailing, ( err ) ->
          if err
            return res.status( 400 ).send err
          else
            return res.send 'VERIFICATION_EMAIL_SENT'
