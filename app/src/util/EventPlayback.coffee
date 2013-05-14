
class EventPlayback
  dir: "recorded_games/"
  callbacks: {}
  line: ""
  lineReady: false

  # Initializes the event playback
  #
  # @param [String] file The file name of the recorded game
  constructor: (file) ->
    file = @dir + file
    $.ajax
      type: 'GET'
      url: file
      success: (data) =>
        @text = data
      error: (data, error, obj=null) ->
        console.log('data ' + data)
        console.log('error ' + error)
        console.log('obj ' + obj)
      dataType: 'text'
      async: false

    seed = @_nextLine('endseed\n')
    Math.seedrandom(seed)

    sizeline = @_nextLine('\n')
    wh = sizeline.match(/[0-9]+/g)
    window.resizeTo(wh[0], wh[1])

    @currentLine = @_nextLine('\n')

  _nextLine: (lineEnd) ->
    end = @text.indexOf(lineEnd)
    line = @text.substr(0, end)
    @text = @text.substr(end + lineEnd.length)
    return line

  # Registers and event with a callback function
  #
  # @param [String] event The event name that was used to record the event
  # @param [Function] callback The function to call to trigger the event
  registerEvent: (event, callback) ->
    @callbacks[event] = callback

  beginPlayback: ->
    line = @_nextLine('\n')
    while line != ""
      time = line.match(/[0-9]+/)
      event = line.match(/[A-z]+/)
      param = line.match(/{.*}/)
      e = JSON.parse(param)
      if timeSinceStart() >= time
        console.log("calling event " + event + " at " + timeSinceStart())
        if event[0] == "onResize"
          width = window.outerWidth - window.innerWidth + e.width
          height = window.outerHeight - window.innerHeight + e.height
          window.resizeTo(width, height)
        else
          @callbacks[event](e)
        line = @_nextLine('\n')

  next: =>
    if @currentLine != ""
      time = @currentLine.match(/[0-9]+/)
      event = @currentLine.match(/[A-z]+/)
      param = @currentLine.match(/{.*}/)
      e = JSON.parse(param)
      if timeSinceStart() >= time
        #console.log("calling event " + event + " at " + timeSinceStart())
        if event[0] == "onResize"
          width = window.outerWidth - window.innerWidth + e.width
          height = window.outerHeight - window.innerHeight + e.height
          window.resizeTo(width, height)
        else
          for key, value of e
            e[key] = Number(value)
          @callbacks[event](e)
        @currentLine = @_nextLine('\n')