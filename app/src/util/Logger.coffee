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
  # @param [Boolean] async Send the log asynchronously
  #
  @send: (async=true) ->
    # $.post "../server/logger.php",
    #   async: async
    #   events: @_queue
    #   (data) ->
    #   "json"
    $.ajax
      type: 'POST'
      url: '../server/logger.php'
      data:
        events: @_queue
      success: (data) ->
      dataType: 'json'
      async: async
    @_queue = []

window.Logger = Logger
