# The Camera class has an x and y position and a width and a height. It uses
# these attributes to transform world coordinates into screen coordinates. It
# also provids funcionality for smooth movement to a new location.
class Camera
  # The current x position of the camera
  x: 0
  # The current y position of the camera
  y: 0

  # The minimum allowed zoom
  MINZOOM: 0.1

  # A factor for controlling the movement speed when approaching the target
  MOVEFACTOR: 10

  # Creates a new camera
  #
  # @param [Number] targetX The initial target x coordinate
  # @param [Number] targetY The initial target y coordinate
  # @param [Number] width The initial width
  # @param [Number] height The initial height
  # @param [Number] zoom The initial zoom
  constructor: (@targetX, @targetY, @width, @height, @zoom=1.0) ->
    @setZoom(@zoom)

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

  # Takes the given world coords and returns a new set represting where the
  # given ones appear on the screen
  #
  # @param [Object] {x, y} Where x and y are the coordinates to modify
  # @return [Object] {x, y} The modified coordinates
  getScreenCoordinates: (coords) ->
    difX = (@x - coords.x) * @zoom
    difY = (@y - coords.y) * @zoom
    return {x: difX + @x + @width / 2, y: difY + @y + @height / 2}

  # Moves the camera's current position toward its target position
  # Call once per draw
  update: ->
    difx = @targetX - @x
    dify = @targetY - @y
    @x = @x + difx / @MOVEFACTOR
    @y = @y + dify / @MOVEFACTOR