randomstring = require 'randomstring'
moment       = require 'moment-timezone'

module.exports = ( mongoose, bcrypt, mailing, config ) ->

  userSchema = new mongoose.Schema
    name :
      type     : String
      required : true
    username :
      type     : String
      required : true
      unique   : true
    password :
      type     : String
      required : true
    level :
      type    : String
      default : 'PROVIDER'
    key :
      type     : String
      required : true
    status :
      type    : String
      default : 'EMAIL_PENDING_VALIDATE'
    # Complex Access Levels
    complex :
      type : mongoose.Schema.Types.ObjectId
      ref  : 'complex'
    region : String
    zone   : String
    # / Complex Access Levels
    createdAt :
      type : Number
      default : moment( new Date() ).tz( config.localTimeZone ).format( 'x' )
    updatedAt :
      type    : Number
      default : moment( new Date() ).tz( config.localTimeZone ).format( 'x' )
  , { strict : true }

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
    user.updatedAt = moment( new Date() ).tz( config.localTimeZone ).format( 'x' )
    if @isModified( 'password' ) or @isNew
      bcrypt.genSalt 10, ( err, salt ) ->
        if err then return next err
        bcrypt.hash user.password, salt, ( err, hash ) ->
          if err then return next err
          user.password = hash
          next()
    else
      return next()

  userSchema.methods.comparePassword = ( passw, cb ) ->
    bcrypt.compare passw, @password, ( err, isMatch ) ->
      if err then return cb err
      cb null, isMatch

  return mongoose.model 'user', userSchema, 'users'
