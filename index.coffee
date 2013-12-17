rte = require("./source/_assets/rte.node")
#
# Implement the abstract Console class
# by overriding the handler method
#
class Console extends rte.Console

  constructor: ($welcome) ->
    @welcomeMessage = $welcome
    super()
  #
  # callback to handle interrupt
  #
  # @return none
  #
  cancelHandle: () ->
    console.log "cancelHandle"

  #
  # callback to handle the input
  #
  # @param  [String]  line  the line that was wntered
  # @return none
  #
  commandHandle: ($line) =>
    console.log 'commandHandle'

_con = new Console('Hello Katra')