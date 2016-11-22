module.exports = ( router, schemas ) ->

  router.put '/passwd', ( req, res ) ->
    if !req.body or !req.body.key or !req.body.password
      return res.status( 400 ).send 'INVALID_DATA'

    schemas.User.findOne { key: req.body.key }, ( err, user ) ->
      if err then throw err
      if !user
        return res.status( 400 ).send 'INVALID_RECOVERY_HASH'
      else
        if user.status == 'RECOVERY_PASSWORD'
          user.status   = 'ACTIVE'
          user.password = req.body.password
          user.save ( err ) ->
            if err then throw err
            return res.send 'SUCCESSFULLY_CHANGE_PASSWORD'
        else
          return res.status( 400 ).send 'PROCESS_UNINITIALIZED'
