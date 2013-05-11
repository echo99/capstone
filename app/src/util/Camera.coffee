if not root?
  root = exports ? window

# The Camera class has an x and y position and a width and a height. It uses
# these attributes to transform world coordinates into screen coordinates. It
# also provids funcionality for smooth movement to a new location.
class Camera
  # @property The current x position of the camera
  x: 0
  # @property The current y position of the camera
  y: 0
  # @property The current width of the camera
  width: 0
  # @property The current height of the camera
  height: 0

  # The minimum allowed zoom
  MINZOOM: 0.1

  # A factor for controlling the movement speed when approaching the target
  MOVEFACTOR: 10

  @DragMode:
    DEFAULT: 1
    ONE_TO_ONE: 2

  # Creates a new camera
  #
  # @param [Number] targetX The initial target x coordinate
  # @param [Number] targetY The initial target y coordinate
  # @param [Number] width The initial width
  # @param [Number] height The initial height
  # @param [Number] zoom The initial zoom
  constructor: (@targetX, @targetY, @width, @height, @zoom=1.0) ->
    @setZoom(@zoom)
    @curDragMode = @constructor.DragMode.DEFAULT

  # Sets the width and height of the camera
  #
  # @param [Number] width The desired width of the camera
  # @param [Number] height The desired height of the camera
  setSize: (@width, @height) ->

  # Sets the target position of the camera
  #
  # @param [Number] targetX The desired x position of the camera
  # @param [Number] targetY The desired y position of the camera
  setTarget: (target) ->
    @targetX = -target.x
    @targetY = -target.y

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
  # @param [Number] z The desired zoom
  setZoom: (z) ->
    prev = @zoom
    if z > 1.0
      @zoom = 1.0
    else if z < @MINZOOM
      @zoom = @MINZOOM
    else
      @zoom = z

  # Set the drag mode of the camera
  #
  # @param [String] dragMode The name of the drag mode
  setDragMode: (dragMode) ->
    if dragMode of @constructor.DragMode
      @curDragMode = @constructor.DragMode[dragMode]

  # Move the camera using screen distance
  #
  # @param [Number] dx
  # @param [Number] dy
  moveCameraByScreenDistance: (dx, dy) ->
    if @curDragMode is @constructor.DragMode.ONE_TO_ONE
      dx /= @zoom
      dy /= @zoom
    @setPosition(@x+dx, @y+dy)

  # Gets the current zoom
  #
  # @return [Number] The current zoom
  getZoom: ->
    return @zoom

  # Takes the given world coords and returns a new set represting where the
  # given ones appear on the screen
  #
  # @param [Object] coords Where coords.x and cords.y are the coordinates
  #                        to modify
  # @return [Object] The modified coordinates
  getScreenCoordinates: (coords) ->
    difX = (@x + coords.x) * @zoom
    difY = (@y + coords.y) * @zoom
    switch @curDragMode
      when @constructor.DragMode.DEFAULT
        return {x: difX + @x + @width / 2, y: difY + @y + @height / 2}
      when @constructor.DragMode.ONE_TO_ONE
        return {x: Math.floor(difX + @width / 2), y: Math.floor(difY + @height / 2)}

  # Takes the given screen coords and returns a new set represting where the
  # given ones appear in the world
  #
  # @param [Object] coords Where coords.x and cords.y are the coordinates
  #                        to modify
  # @return [Object] The modified coordinates
  getWorldCoordinates: (coords) ->
    difX = difY = 0
    switch @curDragMode
      when @constructor.DragMode.DEFAULT
        difX = coords.x - @x - (@width / 2)
        difY = coords.y - @y - (@height / 2)
      when @constructor.DragMode.ONE_TO_ONE
        difX = coords.x - (@width / 2)
        difY = coords.y - (@height / 2)
    posX = (difX / @zoom) - @x
    posY = (difY / @zoom) - @y
    return {x: posX, y: posY}

  # Takes screen coordinates and returns true if it is a point within view
  # of the camera
  #
  # @param [Object] coords Where coords.x and cords.y are the coordinates
  # @return [Boolean] true if coords is within view, false otherwise
  onScreen: (coords) ->
    return -100 < coords.x < @width+100 and -100 < coords.y < @height+100

  # Moves the camera's current position toward its target position
  # Call once per draw
  update: ->
    difx = @targetX - @x
    dify = @targetY - @y
    @x = @x + difx / @MOVEFACTOR
    @y = @y + dify / @MOVEFACTOR

root.Camera = Camera
