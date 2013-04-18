# Elements namespace
Elements = Elements or {}

# The base class for UI elements
#
class Elements.UIElement
  # @private @property [Array<UIElement>]
  _children: []

  # Create a new UI element
  #
  constructor: ->

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

  # Draw the element to the canvas
  #
  # @abstract Each element will have its own draw function
  #
  # @param [CanvasRenderingContext2D] ctx
  # @param [Number] x
  # @param [Number] y
  #
  draw: (ctx, x, y) ->

  # Call to element when it is clicked
  click: (x, y) ->
    console.log("clicked (#{x}, #{y})")
    @_onClick()
    relLoc = @getRelativeLocation(x, y)
    for child in @_children
      if child.containsPoint(relLoc.x, relLoc.y)
        child.click(relLoc.x, relLoc.y)

  # @private Action to perform when element is clicked
  # @abstract
  #
  _onClick: ->

  # Gets the relative location of the point to this element
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Object] {'x': x, 'y': y}
  getRelativeLocation: (x, y) ->
    return {'x': x, 'y': y}



# A box UI element
#
class Elements.BoxElement extends Elements.UIElement

  # Create a new box element
  #
  # @param [Number] x x-position of left edge of element relative to parent
  # @param [Number] y y-position of top edge of element relative to parent
  # @param [Number] w Width of element
  # @param [Number] h Height of element
  #
  constructor: (@x, @y, @w, @h) ->
    super()

  containsPoint: (x, y) ->
    # return not (@x < x or x > @x + width or @y < y or y > @y + width)
    return @x <= x <= @x + @w and @y < y <= @y + @h

  getRelativeLocation: (x, y) ->
    return {'x': x-@x, 'y': y-@y}

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
  # @param [Number] x The x-coordinate of the left edge of the box
  # @param [Number] y The y-coordinate of the top edge of the box
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [String] message The message to display in the box
  #
  constructor: (@x, @y, @w, @h, @message) ->
    super(@x, @y, @w, @h)
    @visible = true
    test = ->
      alert(@visible)
      @visible = false
      alert(@visible)
    @closeBtn = new Elements.Button(5, 5, 16, 16, @)
    @addChild(@closeBtn)

  callback: () ->
    @visible = false
    if @updCallback
      @updCallback()

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
      ctx.strokeRect(@x, @y, @w, @h)
      ctx.fillRect(@x, @y, @w, @h)
      ctx.font = config.windowStyle.labelText.font
      ctx.fillStyle = config.windowStyle.labelText.color
      ctx.textAlign = 'center'
      cx = Math.round(@w/2 + @x)
      cy = Math.round(@h/2 + @y)
      ctx.fillText(@message, cx, cy)

      btnOffsetX = @x + @closeBtn.x
      btnOffsetY = @y + @closeBtn.y
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
  # @param [Number] x The x-coordinate of the left edge of the box
  # @param [Number] y The y-coordinate of the top edge of the box
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [Function] callback The function to call when this button is clicked
  constructor: (@x, @y, @w, @h, @callback) ->
    super(@x, @y, @w, @h)

  # Call the attached callback function when the button is clicked
  #
  _onClick: ->
    @callback.callback()

  # Do something when the user hovers over the button
  #
  hover: ->
