module.exports = ( router, config, schemas, jwt, mailing ) ->

  require( './signup' )( router, schemas )
  require( './authenticate' )( router, config, schemas, jwt )
  require( './verifyEmail' )( router, schemas )
  require( './recoveryPassword' )( router, schemas, mailing )
  require( './resendValidate' )( router, schemas, mailing )
  require( './passwd' )( router, schemas )
  require( './ping' )( router )
