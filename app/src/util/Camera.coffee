class Camera
  x: 0
  y: 0
  MINZOOM: 0.1
  MOVEFACTOR: 10

  constructor: (@targetX, @targetY, @width, @height, @zoom=1.0) ->

  # Sets the width and height of the camera
  #
  # @param [Number] width The desired width of the camera
  # @param [Number] height The desired height of the camera
  setSize: (@width, @height) ->

  # Sets the target position of the camera
  #
  # @param [Number] targetX The desired x position of the camera
  # @param [Number] targetY The desired y position of the camera
  setTarget: (@targetX, @targetY) ->

  # Sets the camera position immediately
  #
  # @param [Number] x The desired x position of the camera
  # @param [Number] y The desired y position of the camera
  setPosition: (x, y) ->
    @targetX = @x = x
    @targetY = @y = y

  # Gets the actual current position of the camera
  #
  # @return [Object] {x, y} Where x is the current x position and
  #                         y is the current y position
#  getPosition: ->
#   return {x: @currentX, y: @currentY}

  # Sets the zoom to the given value. The zoom will always be between
  # 1 and MINZOOM
  #
  # @param [Number] z the desired zoom
  setZoom: (z) ->
    prev = @zoom
    if z > 1.0
      @zoom = 1.0
    else if z < @MINZOOM
      @zoom = @MINZOOM
    else
      @zoom = z

  # Gets the current zoom
  #
  # @return [Number] the current zoom
  getZoom: ->
    return @zoom

  # Takes the given coords and returns a new set represting where the given
  # ones actually appear given the camera position and zoom.
  #
  # @param [Object] {x, y} Where x and y are the coordinates to modify
  # @return [Object] {x, y} The modified coordinates
  getModifiedCoordinates: (coords) ->
    difX = (@x - coords.x) * @zoom
    difY = (@y - coords.y) * @zoom
    return {x: difX + @x + @width / 2, y: difY + @y + @height / 2}

  # Moves the camera's current position toward its target position
  update: ->
    # call once per draw
    # move current x/y toward target x/y
    difx = @targetX - @x
    dify = @targetY - @y
    @x = Math.floor(@x + difx / @MOVEFACTOR)
    @y = Math.floor(@y + dify / @MOVEFACTOR)