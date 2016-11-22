randomstring = require 'randomstring'
validator    = require 'validator'

recovery = ( user, mailing, callback ) ->
  email = require( '../../email-templates/recoveryPassword' )
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

  router.post '/recovery', ( req, res ) ->

    if not req.body.email
      return res.status( 400 ).send 'INVALID_DATA'

    # Validate email address
    if not validator.isEmail( req.body.email )
      return res.status( 400 ).send 'INVALID_EMAIL_ADDRESS'
    schemas.User.findOne { username: req.body.email }, ( err, user ) ->
      if err then throw err
      if not user
        return res.status( 400 ).send 'INVALID_USERNAME'
      else
        switch user.status
          # Deny action to inactive users
          when 'SUSPENDED'
            return res.status( 400 ).send 'SUSPENDED_ACCOUNT'
          # Resend recovery password email
          when 'RECOVERY_PASSWORD'
            recovery user, mailing, ( err ) ->
              if err
                return res.status( 400 ).send err
              else
                return res.send 'RESEND_RECOVERY_PASSWORD_EMAIL'
          # Generate new hash key
          else
            user.key = randomstring.generate
              length  : 32
              charset : 'alphanumeric'
            # Recovery status flag
            user.status = 'RECOVERY_PASSWORD'
            user.save ( err ) ->
              if err then throw err
              recovery user, mailing, ( err ) ->
                if err
                  return res.status( 400 ).send err
                else
                  return res.send 'SEND_RECOVERY_PASSWORD_EMAIL'
