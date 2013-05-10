# Class for logging events
#
class Logger
  # Start the logger. This must be called before calling any other methods on Logger
  #
  @start: ->
    @startTime = new Date()
    @_queue = []
    @logEvent('Start session', null)

  # Log an event
  #
  # @param [String] evt The name of the event
  # @param [Mixed] params The parameters associated with the event
  #
  @logEvent: (evt, params) ->
    if not @startTime?
      console.error('Logger has not yet been started!')
    else
      @_queue.push
        time:  new Date()
        event: evt
        param: params

  # Send the queued events to the server to log
  #
  @send: ->
    $.post("../server/logger.php", { events: @_queue }, ( (data)-> ), "json")
    @_queue = []

window.Logger = Logger
