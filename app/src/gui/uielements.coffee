# Elements namespace
root = exports ? window
root.Elements ?= {}
# Elements = Elements or {}
Elements = root.Elements

CURSOR_TYPES =
  DEFAULT: 'auto'
  POINTER: 'pointer'
  WAIT: 'wait'
  MOVE: 'move'


# The base class for UI elements
#
class Elements.UIElement
  # @property [Boolean] Flag for if element is visible
  visible: true

  # Create a new UI element
  #
  constructor: ->
    # @private @property [Array<UIElement>]
    @_children = []

  # Add a child element to this element
  #
  # @param [UIElement] elem
  #
  addChild: (elem) ->
    @_children.push(elem)

  # Remove a child element from this element if it exists
  #
  # @param [UIElement] elem
  #
  removeChild: (elem) ->
    index = @_children.indexOf(elem)
    if index != -1
      @_children.splice(index)

  # Check if the given point is within the boundaries of the UI element
  #
  # @abstract Depends on shape
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Boolean] whether or not the point lies inside the element
  #
  containsPoint: (x, y) ->

  # Check if the given coordinates are within the boundaries of the UI element
  #
  # @param [Object] coords Where coords.x and cords.y are the coordinates
  #                        to modify
  # @return [Boolean] whether or not the coordinates lie inside the element
  #
  containsCoords: (coords) ->
    return @containsPoint(coords.x, coords.y)

  # Draw the element to the canvas
  #
  # @abstract Each element will have its own draw function
  #
  # @param [CanvasRenderingContext2D] ctx
  # @param [Number] x
  # @param [Number] y
  #
  draw: (ctx, x, y) ->

  # Call to element to check if it is clicked
  #
  # @param [Number] x
  # @param [Number] y
  #
  click: (x, y) =>
    if @containsPoint(x, y) and @visible
      console.log("clicked #{@constructor.name} at (#{x}, #{y})")
      @_onClick()
      relLoc = @getRelativeLocation(x, y)
      console.log("relative location: #{relLoc.x}, #{relLoc.y}")
      # console.log("In loop")
      # console.log("Children of #{@name} : #{@_children}")
      for child in @_children
        if child.visible
          # console.log("Checking #{child.name}")
          child.click(relLoc.x, relLoc.y)
      # console.log("Out of loop")

  # @private Action to perform when element is clicked
  # @abstract
  #
  _onClick: ->

  mouseMove: (x, y) ->
    pointerType = null
    if @containsPoint(x, y) and @visible
      pointerType = @_onHover()
      relLoc = @getRelativeLocation(x, y)
      # console.log("relative location: #{@constructor.name} #{relLoc.x},
      #   #{relLoc.y} | #{pointerType}")
      for child in @_children
        pointer = child.mouseMove(relLoc.x, relLoc.y)
        pointerType = pointer if pointer
    return pointerType

  # @private Action to perform when element is hovered over
  # @abstract
  #
  _onHover: ->
    return null

  # Gets the relative location of the point to this element
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Object] The coordinates `{'x': x, 'y': y}`
  getRelativeLocation: (x, y) ->
    return {'x': x, 'y': y}



# A box UI element
#
class Elements.BoxElement extends Elements.UIElement

  # Create a new box element
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] w Width of element
  # @param [Number] h Height of element
  #
  constructor: (@x, @y, @w, @h) ->
    super()
    @cx = -Math.round(@w/2)
    @cy = -Math.round(@h/2)

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    # return not (@x < x or x > @x + width or @y < y or y > @y + width)
    # return @x <= x <= @x + @w and @y <= y <= @y + @h
    return @x + @cx <= x <= @x - @cx and @y + @cy <= y <= @y - @cy

  # @see Elements.UIElement#getRelativeLocation
  getRelativeLocation: (x, y) ->
    return {'x': x-@x-@cx, 'y': y-@y-@cy}

# A radial UI element
#
class Elements.RadialElement extends Elements.UIElement

  # Create a new radial element
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] r Radius of element
  #
  constructor: (@x, @y, @r) ->
    super()
    @r2 = @r*@r

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    dx = Math.abs(@x - x)
    dy = Math.abs(@y - y)
    return dx*dx + dy*dy <= @r2

# Message box class for displaying messages in the user interface
#
class Elements.MessageBox extends Elements.BoxElement
  # Various types of messages
  TYPES =
    Info: 1
    Warn: 2

  # Create a new message box
  #
  # @param [Number] x The x-coordinate of the center of the box
  # @param [Number] y The y-coordinate of the center of the box
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [String] message The message to display in the box
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  constructor: (@x, @y, @w, @h, @message, @ctx) ->
    super(@x, @y, @w, @h)
    # test = ->
    #   alert(@visible)
    #   @visible = false
    #   alert(@visible)
    # @closeBtn = new Elements.Button(5, 5, 16, 16, @)
    @closeBtn = new Elements.Button(8, 8, 16, 16,
      ((obj) ->
        return -> obj.close())(this))
    @addChild(@closeBtn)
    console.log("My children: #{@_children}")
    console.log("Button's children: #{@closeBtn._children}")

  # # Temporary callback function
  # callback: () ->
  #   @visible = false
  #   if @updCallback
  #     @updCallback()

  # Close this message box
  close: ->
    @visible = false
    lw = config.windowStyle.lineWidth
    lw2 = lw + lw
    @ctx.clearRect(@x+@cx-lw, @y+@cy-lw, @w + lw2, @h + lw2)
    @ctx.canvas.style.cursor = CURSOR_TYPES.DEFAULT


  # Add a callback to call when the message box updates
  addUpdateCallback: (callback) ->
    @updCallback = callback

  # Draw this message box to the canvas context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  draw: (ctx) ->
    if @visible
      ctx.strokeStyle = config.windowStyle.stroke
      ctx.fillStyle = config.windowStyle.fill
      # ctx.strokeRect(@x, @y, @w, @h)
      # ctx.fillRect(@x, @y, @w, @h)
      ctx.strokeRect(@x+@cx, @y+@cy, @w, @h)
      ctx.fillRect(@x+@cx, @y+@cy, @w, @h)
      ctx.font = config.windowStyle.labelText.font
      ctx.fillStyle = config.windowStyle.labelText.color
      ctx.textAlign = 'center'
      # cx = Math.round(@w/2 + @x)
      # cy = Math.round(@h/2 + @y)
      ctx.fillText(@message, cx, cy)
      ctx.fillText(@message, @x, @y)

      btnOffsetX = @x + @cx + @closeBtn.x + @closeBtn.cx
      btnOffsetY = @y + @cy + @closeBtn.y + @closeBtn.cy
      cx = Math.round(@closeBtn.w/2 + btnOffsetX)
      cy = Math.round(@closeBtn.h/2 + btnOffsetY) + 4
      ctx.fillStyle = 'rgb(0,0,0)'
      ctx.fillRect(btnOffsetX, btnOffsetY, @closeBtn.w, @closeBtn.h)
      ctx.fillStyle = 'rgb(255,255,255)'
      ctx.font = '12pt Arial'
      ctx.fillText('x', cx, cy)


# Button class for handling user interactions
#
class Elements.Button extends Elements.BoxElement

  # Create a new button
  #
  # @param [Number] x The x-coordinate of the center of the button
  # @param [Number] y The y-coordinate of the center of the button
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [Function] callback The function to call when this button is clicked
  constructor: (@x, @y, @w, @h, @callback) ->
    super(@x, @y, @w, @h)

  # Call the attached callback function when the button is clicked
  #
  _onClick: ->
    # @callback.callback()
    @callback()

  # Do something when the user hovers over the button
  #
  _onHover: ->
    return CURSOR_TYPES.POINTER


# Button class for circular buttons
#
class Elements.RadialButton extends Elements.RadialElement

  # Create a new radial button
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] r Radius of element
  # @param [Function] callback The function to call when this button is clicked
  constructor: (@x, @y, @w, @h, @callback) ->
    super(@x, @y, @r)

  # Call the attached callback function when the button is clicked
  #
  _onClick: ->
    # @callback.callback()
    @callback()

  # Do something when the user hovers over the button
  #
  _onHover: ->
    return CURSOR_TYPES.POINTER


# Class for handling DOM buttons
#
class Elements.DOMButton

  # Create a new DOM button
  #
  # @param [AnimatedSprite] sprite The sprite to use for the button
  # @param [SpriteSheet] sheet The sprite sheet the sprite belongs to
  constructor: (@sprite, @sheet) ->
    spt = @sheet.getSprite(@sprite)
    @w = spt.w
    @h = spt.h
    @canvas = document.createElement('canvas')
    @canvas.width = @w
    @canvas.height = @h
    @canvas.style.cursor = 'pointer'
    @canvas.style.position = 'absolute'
    document.body.appendChild(@canvas)
    ctx = @canvas.getContext('2d')
    # ctx.fillStyle = "rgb(255,0,0)"
    # ctx.fillRect(0,0,16,16)
    @sheet.drawSprite(@sprite, Math.round(@w/2), Math.round(@h/2), ctx, false)
    return this

  setTop: (@offsetTop) ->
    @canvas.style.top = @offsetTop + 'px'
    return this

  setBottom: (@offsetBottom) ->
    @canvas.style.bottom = @offsetBottom + 'px'
    return this

  setLeft: (@offsetLeft) ->
    @canvas.style.left = @offsetLeft + 'px'
    return this

  setRight: (@offsetRight) ->
    @canvas.style.right = @offsetRight + 'px'
    return this

  setClickHandler: (@callback) ->
    @canvas.addEventListener('mousedown', @callback)
    return this