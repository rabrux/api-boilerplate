module.exports = ( router ) ->

  router.get '/ping', ( req, res ) ->
    res.send
      success : true
      data    : req.user
