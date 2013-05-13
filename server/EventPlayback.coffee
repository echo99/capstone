
class EventPlayback
  dir: "../recorded_games/"
  callbacks: {}
  line: ""
  lineReady: false

  # Initializes the event playback
  #
  # @param [String] file The file name of the recorded game
  constructor: (file) ->
    file = @dir + file
    # open file
    console.log('opening file ' + file)
    fs = require('fs')
    @steam = fs.createReadStream(file,
      {
        flags: 'r',
        ecoding: 'utf-8',
        fd: null,
        bufferSize: 1
      }
    )
    @stream.addListener('data', (char) ->
      @stream.pause()
      if char == '\n'
        @lineReady = true
        @stream.pause()
      else
        @line += char
        stream.resume()
    )
    seed = @_nextLine()
    console.log(seed)
    Math.seedrandom(seed)

  _nextLine: () ->
    @line = ""
    @stream.resume()
    while not @lineReady
      undefined
    @lineReady = false
    return @line

  _setLine: (@line) ->

  # Registers and event with a callback function
  #
  # @param [String] event The event name that was used to record the event
  # @param [Function] callback The function to call to trigger the event
  registerEvent: (event, callback) ->
    @callbacks[event] = callback

  beginPlayback:  ->
    # while there is a next line in the file
    #   parse the next line for time, event, and e
    #   if time >= timeSinceStart()
    #     @callbacks[event](e)
    # close
