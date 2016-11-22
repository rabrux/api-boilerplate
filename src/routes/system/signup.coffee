module.exports = ( router, schemas ) ->

  router.post '/signup', ( req, res ) ->
    if !req.body.username or !req.body.password
      res.status( 400 ).send 'INVALID_DATA'
    else
      newUser = new schemas.User( req.body )

      # Save user
      newUser.save ( err ) ->
        if err
          switch err.code
            when 11000
              return res.status( 400 ).send 'DUPLICATE_USER'
            else
              return res.status( 400 ).send err
        res.status( 201 ).send newUser
