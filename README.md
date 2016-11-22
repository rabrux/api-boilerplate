# API Boilerplate

## Description ##

## Prerequisites ##

* Git
* NodeJS
* NPM
* Dev Dependencies
  * CoffeeScript

## Installation and Configuration ##

* ** Download Source Code **
```bash
> git clone https://github.com/rabrux/api-boilerplate.git
```

* ** Go to Source Code Directory **
```bash
> cd api-boilerplate
```

* ** Installing NPM Dependencies **
```bash
> npm install
```
*To install dev dependencies (just coffeescript) run command `npm install -g coffee-script` it can be require root privileges*

* ** Execute API Server **
```bash
> npm start
```

## Understanding Project Structure ##

### API Files Structure ###

Base file structure to understand project bootstrap

```
.
│   README.md                # This README file
│   package.json             # NPM config file
│   .gitignore               # Excluded files
│
└───src                      # Source directory
    │
    │   index.coffee        # Main server file
    │
    └───conf                 # Configuration files
    │
    └───email-templates      # Email templates
    │
    └───hooks                # Server hooks
    │
    └───lib                  # Local libraries (reused code)
    │
    └───routes               # Server API paths (group in folders)
    │
    └───schemas              # Mongoose model schemas
```
##### Adding new NPM package  #####

If you need to use an unincluded package, you must add with the command `npm install --save YourPackageName`, it instruction install the npm package and add it to the config file (`--save`).

##### Main Server File ( src/index.coffee ) #####

```coffeescript
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
# / Required packages

# Schemas
schemas    =
  User : require('./schemas/user')( mongoose, bcrypt, mailing )

# Logger config
logger.remove logger.transports.Console
logger.add logger.transports.Console,
  colorize: true
  timestamp: true

# Get our request parameters
app.use bodyParser.urlencoded( { extended: false } )
app.use bodyParser.json()

# Log to console
app.use morgan( 'dev' )

# Passport package
app.use passport.initialize()

app.get '/', ( req, res ) ->
  res.send "Hello from api"

# Connect to database
mongoose.connect config.database

require( './conf/passport' )( passport )

# Hooks
require( './hooks/getAuthorization' )( app, config, schemas, jwt )

# Router
router = express.Router()
require( './routes/system/index' )( router, config, schemas, jwt, mailing )

app.use '/', router

app.listen port

logger.info "Magic happends on #{ port }"

```

##### Schema file structure #####

```coffeescript
# Required packages
randomstring = require 'randomstring'
moment       = require 'moment-timezone'
# / Required packages

# Module declaration
module.exports = ( mongoose, bcrypt, mailing ) ->

  userSchema = new mongoose.Schema        # Change userSchema variable name that reference and describe your model name
    # Schema Field
    # Url: http://mongoosejs.com/docs/2.7.x/docs/schematypes.html
    username :                            # Field name
      type     : String                   # Field Type
      required : true                     # Field additional option
      unique   : true                     # Field additional option
    # / Schema Field
    password :
      type     : String
      required : true
    level :
      type    : String
      default : 'DEFAULT_LEVEL'
    key :
      type     : String
      required : true
    status :
      type    : String
      default : 'EMAIL_PENDING_VALIDATE'
    createdAt :
      type : Number
      default : moment( new Date() ).format( 'x' )
    updatedAt :
      type    : Number
      default : moment( new Date() ).format( 'x' )
  , { strict : true }                     # Schema options http://mongoosejs.com/docs/2.7.x/docs/schema-options.html

  # Middleware functions
  # Url: http://mongoosejs.com/docs/2.7.x/docs/middleware.html

  # Generate user hash key
  userSchema.pre 'validate', ( next ) ->
    user = @
    if @isNew
      user.key = randomstring.generate
        length  : 32
        charset : 'alphanumeric'
      next()
    else
      next()

  # Hash password
  userSchema.pre 'save', ( next ) ->
    user = @
    user.updatedAt = moment( new Date() ).format( 'x' )
    if @isModified( 'password' ) or @isNew
      bcrypt.genSalt 10, ( err, salt ) ->
        if err then return next err
        bcrypt.hash user.password, salt, ( err, hash ) ->
          if err then return next err
          user.password = hash
          next()
    else
      return next()

  # Send validation email
  userSchema.post 'save', ( doc ) ->
    # Load and prepare email template
    user = @
    if user.status == 'EMAIL_PENDING_VALIDATE'
      email = require( '../email-templates/signup' )
        to  : doc.username
        key : doc.key
      # Send email
      if email
        mailing email, ( err, done ) ->
          if err then return console.log err
          console.log 'Success send email'

  # / Middleware functions

  # Schema methods
  # Url: http://mongoosejs.com/docs/2.7.x/docs/methods-statics.html
  userSchema.methods.comparePassword = ( passw, cb ) ->
    bcrypt.compare passw, @password, ( err, isMatch ) ->
      if err then return cb err
      cb null, isMatch
  # / Schema methods

  # Return model
  # Params:
  #   modelName
  #   schema
  #   collectionName
  return mongoose.model 'user', userSchema, 'users'
```

##### Config Files #####

Before the creation of a new configuration file verify that is not categorized in any existing file.

if you need a new configuration file you must create it within `./src/conf/<FileName>`. It can be described in JSON format if only contains static variables otherwise you can create it as a new module package like `module.exports` and saved as .coffee extension.

** JSON config file example **

```json
{
  "port"     : 1337,
  "secret"   : "YOUR_SECRET_HERE",
  "database" : "mongodb://localhost:27017/"
}
```

** Dynamic config file example (CoffeeScript) **

```coffeescript
module.exports = ( <inject_dependencies> ) ->

  object =
    name : 'lorem'
    date : new Date()

  return object
```

** Email config example (src/conf/email.json) **

```json
{
  "name"     : "NAME",
  "dashURL" : "http://localhost:8080/#",
  "login"    : {
    "host"   : "<host>",
    "port"   : 465,
    "secure" : true,
    "auth"   : {
      "user" : "<email>",
      "pass" : "<password>"
    }
  }
}
```

** Server config example (src/conf/server.json) **

```json
{
  "port"     : 1337,
  "secret"   : "YOUR_SECRET_HERE",
  "database" : "mongodb://localhost:27017/",
  "localTimeZone" : "America/Mexico_City"
}
```

where `<inject_dependencies>` are variables, objects or modules needed for returning a computed object. This configuration file can be loaded as `require( '<file_path>' )( <inject_dependencies> )` for example `myConfig = require( 'myconfig' )( mongoose, app )`

##### Hooks Files #####

A **hook** is an express middleware action that executes when an event is triggered.

[Express Middleware Docs](http://expressjs.com/en/guide/using-middleware.html)

** Before hook **
```coffeescript
module.exports = ( app ) ->

  app.use ( req, res, next ) ->
    console.log 'Before'
    next()
```

** After hook **
```coffeescript
module.exports = ( app ) ->

  app.use ( req, res, next ) ->
    res.on 'finish', ->
      console.log 'After'
    next()
```

##### Route Files #####

A route in express is a entry point where the client can interact with the API.

Router architecture example:
* System
  * singup
  * validateEmail
  * resetPassword
  * ...
  * index

Where index is a file that includes all routes for a faster access. It has to be included into `./src/index.coffee`

For organization purposes each route file can only contain a single route, and a group of routes that share interaction with one specific data model. That route files had to be grouped in a folder with a name that describes it function.

##### Email Template File #####

For organization purposes all email templates are stored in `./src/email-templates` and saved as CoffeeScript file type.

** Email Template example **
```coffeescript
emailConfig = require '../conf/email.json'

module.exports = ( args ) ->

  if !args or !args.to or !args.key
    return false

  return {
    from    : "\" #{ emailConfig.name } \" <#{ emailConfig.login.auth.user }>"
    to      : args.to
    subject : 'SIGNUP'
    html    : "<a href=\"#{ emailConfig.dashURL }/verify/#{ args.key }\">validate</a>"
  }
```

Where `args` param is an object that contains all dynamic data that will be required to correctly render the template.

##### Library Files #####

A Library file contains code that is used in many times in the API.

For organization purposes all library files are within `./src/email-templates` and saved as CoffeeScript file type.

## License

*MIT License:*

```
Copyright (c) 2016 Alchimia Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

## Contributors ##

```json
{
  "contributors": [
    {
      "name": "g33ktony",
      "email": "antonio[at]alchimia[dot]mx",
      "github": "https://github.com/g33ktony",
      "twitter": "[at]g33ktony"
    },
    {
      "name": "rabrux",
      "email": "raul[at]alchimia[dot]mx",
      "github": "https://github.com/rabrux",
      "twitter": "[at]rabrux"
    }
  ]
}
```

## Last Update ##

Last update November 21, 2016
