authorizedRoutes = require '../conf/authorizedRoutes.json'

getToken = ( headers ) ->
  if headers and headers.authorization
    parted = headers.authorization.split ' '
    if parted.length == 2
      return parted[ 1 ]
    else
      return null
  else
    return null

module.exports = ( app, config, schemas, jwt ) ->

  app.use ( req, res, next ) ->

    if req.method != 'OPTIONS'

      if authorizedRoutes.indexOf( req.path ) > -1
        return next()
      else
        (( callback ) ->
          # Verify composed paths
          currentPath = req.path.replace( /\/+$/, '' ).split( '/' )
          for path in authorizedRoutes
            unauthPath = path.split '/'
            if unauthPath.length == currentPath.length
              flag = true
              for part in [0..unauthPath.length - 1] by 1
                if unauthPath[ part ] != currentPath[ part ]
                  if unauthPath[ part ].indexOf( ':' ) != 0
                    flag = false
              if flag
                return next()
          callback()
        )( ->

          # Verify Token
          token = getToken req.headers

          if token
            decoded = jwt.decode token, config.secret

            schemas.User.findOne { username : decoded.username }, ( err, user ) ->
              if err then throw err
              if !user
                return res.status( 401 ).send 'USER_NOT_FOUND'
              else
                req.user = user
                return next()
          else
            return res.status( 401 ).send 'NOT_TOKEN_PROVIDER'
        )
    else
      next()
