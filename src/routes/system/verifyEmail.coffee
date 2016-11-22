module.exports = ( router, schemas ) ->

  router.post '/verify/:hash', ( req, res ) ->

    schemas.User.findOne { key: req.params.hash }, ( err, user ) ->
      if err then throw err
      if !user
        return res.send
          success : false
          code    : 'INVALID_VALIDATE_KEY'
      else
        if user.status != 'EMAIL_PENDING_VALIDATE'
          return res.send
            success : false
            code    : 'ALREADY_VERIFIED'
        else
          user.status = 'ACTIVE'
          user.save ( err ) ->
            if err then throw err
            return res.send
              success : true
              code    : 'SUCCESSFULLY_VERIFIED_EMAIL'
