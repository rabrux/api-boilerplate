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
