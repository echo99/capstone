class Camera
  currentX: 0
  currentY: 0
  MINZOOM: 0.01

  contructor: (@targetX, @targetY, @width, @height, @zoom=1) ->

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
    @currentX = x
    @currentY = y

  # Gets the actual current position of the camera
  #
  # @return [Object] {x, y} Where x is the current x position and
  #                         y is the current y position
  getPosition: ->
    return {x: @currentX, y: @currentY}

  # Sets the zoom to the given value. The zoom will always be between
  # 1 and MINZOOM
  #
  # @param [Number] z the desired zoom
  setZoom: (z) ->
    if z > 1 then @zoom = 1
    else if z < @MINZOOM then @zoom = @MINZOOM
    else @zoom = z

  # Gets the current zoom
  #
  # @return [Number] the current zoom
  getZoom: ->
    return @zoom

  # Moves the camera's current position toward its target position
  update: ->
    # call once per draw
    # move current x/y toward target x/y