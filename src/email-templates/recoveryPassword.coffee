emailConfig = require '../conf/email.json'

module.exports = ( args ) ->

  if !args or !args.to or !args.key
    return false

  return {
    from    : "\" #{ emailConfig.name } \" <#{ emailConfig.login.auth.user }>"
    to      : args.to
    subject : 'RECOVERY'
    html    : "<a href=\"#{ emailConfig.dashURL }/passwd/#{ args.key }\">recovery password</a>"
  }
