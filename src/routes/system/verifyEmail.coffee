module.exports = ( router, schemas ) ->

  router.post '/verify/:hash', ( req, res ) ->

    schemas.User.findOne { key: req.params.hash }, ( err, user ) ->
      if err then throw err
      if !user
        return res.status( 400 ).send 'INVALID_VALIDATE_KEY'
      else
        if user.status != 'EMAIL_PENDING_VALIDATE'
          return res.send 'ALREADY_VERIFIED'
        else
          user.status = 'ACTIVE'
          user.save ( err ) ->
            if err then throw err
            return res.send 'SUCCESSFULLY_VERIFIED_EMAIL'
