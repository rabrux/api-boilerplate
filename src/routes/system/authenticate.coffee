validator = require 'validator'

module.exports = ( router, config, schemas, jwt ) ->

  router.post '/authenticate', ( req, res ) ->

    if not validator.isEmail( req.body.username )
      return res.status( 400 ).send 'INVALID_EMAIL_ADDRESS'

    schemas.User.findOne { username: req.body.username }, ( err, user ) ->
      if err then throw err
      if not user
        return res.status( 400 ).send 'INVALID_USER'
      
      switch user.status
        when 'EMAIL_PENDING_VALIDATE'
          return res.status( 400 ).send 'EMAIL_NOT_VALIDATED'
        when 'SUSPENDED'
          return res.status( 400 ).send 'SUSPENDED_ACCOUNT'

      user.comparePassword req.body.password, ( err, isMatch ) ->
        if isMatch and !err
          token = jwt.encode user, config.secret
          return res.send
            token   : 'JWT ' + token
            level   : user.level
            # SEND USER PROFILE
        else
          return res.status( 400 ).send 'WRONG_PASSWORD'
