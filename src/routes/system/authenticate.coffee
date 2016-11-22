module.exports = ( router, config, schemas, jwt ) ->

  router.post '/authenticate', ( req, res ) ->
    schemas.User.findOne { username: req.body.username }, ( err, user ) ->
      if err then throw err
      if !user
        res.send
          success : false
          err     : 'AUTHENTICATE_FAILED_INVALID_USER'
      else
        switch user.status
          when 'EMAIL_PENDING_VALIDATE'
            return res.send
              success : false
              err     : 'EMAIL_NOT_VALIDATED'
          when 'SUSPENDED'
            return res.send
              success : false
              err     : 'SUSPENDED_ACCOUNT'

        user.comparePassword req.body.password, ( err, isMatch ) ->
          if isMatch and !err
            token = jwt.encode user, config.secret
            res.send
              success : true
              token   : 'JWT ' + token
              level   : user.level
              # SEND USER PROFILE
          else
            res.send
              success : false
              err     : 'AUTHENTICATE_FAILED_WRONG_PASSWORD'
