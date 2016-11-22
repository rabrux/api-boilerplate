JwtStrategy = require('passport-jwt').Strategy
ExtractJwt  = require('passport-jwt').ExtractJwt

# Load user model
User        = require '../schemas/user'
config      = require '../conf/server.json'

module.exports = ( passport ) ->
  opts = {}
  opts.jwtFromRequest = ExtractJwt.fromAuthHeader()
  opts.secretOrKey    = config.secret
  passport.use new JwtStrategy opts, ( jwt_payload, done ) ->
    User.findOne { id: jwt_payload.id }, ( err, user ) ->
      if err then return done err, false
      if user
        done null, user
      else
        done null, false
