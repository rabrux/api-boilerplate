# Required packages
express    = require 'express'
app        = express()
bodyParser = require 'body-parser'
morgan     = require 'morgan'
mongoose   = require 'mongoose'
passport   = require 'passport'
config     = require './conf/server.json'
port       = process.env.PORT or config.port
jwt        = require 'jwt-simple'
bcrypt     = require 'bcrypt'
logger     = require 'winston'
mailing    = require './lib/email'
path       = require 'path'
# / Required packages

# Schemas
schemas    =
  User         : require('./schemas/user')( mongoose, bcrypt, mailing, config )

# Logger config
logger.remove logger.transports.Console
logger.add logger.transports.Console,
  colorize: true
  timestamp: true

# Get our request parameters
app.use bodyParser.urlencoded( { extended: false } )
app.use bodyParser.json( { limit: '50mb' } )


# Coords
app.use (req, res, next) ->
  res.header 'Access-Control-Allow-Origin', '*'
  res.header 'Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  res.header 'Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS'
  next()

# Log to console
app.use morgan( 'dev' )

# Passport package
app.use passport.initialize()

app.get '/api', ( req, res ) ->
  res.send "Hello from Aeromexico API"

# Connect to database
mongoose.connect config.database

require( './conf/passport' )( passport )

# Hooks
require( './hooks/getAuthorization' )( app, config, schemas, jwt )

# Router
router = express.Router()
require( './routes/system/index' )( router, config, schemas, jwt, mailing )

app.use '/api', router

app.listen port

logger.info "Magic happends on #{ port }"
