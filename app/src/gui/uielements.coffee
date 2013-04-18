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
  # @param [Number] x
  # @param [Number] y
  # @return [Boolean] whether or not the point lies inside the element
  #
  containsPoint: (x, y) ->

  # Draw the element to the canvas
  #
  # @param [CanvasRenderingContext2D] ctx
  # @param [Number] x
  # @param [Number] y
  draw: (ctx, x, y) ->


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
    return @x <= x <= @x + width and @y < y <= @y + width

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

  # Draw this message box to the canvas context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  draw: (ctx) ->
    ctx.strokeStyle = config.windowStyle.stroke
    ctx.fillStyle = config.windowStyle.fill
    ctx.strokeRect(@x, @y, @w, @h)
    ctx.fillRect(@x, @y, @w, @h)
    ctx.font = config.windowStyle.label.font
    ctx.fillStyle = config.windowStyle.label.color
    ctx.textAlign = 'center'
    cx = Math.round( @w/2 + @x)
    cy = Math.round( @h/2 + @y)
    ctx.fillText(@message, cx, cy)


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
  onClick: ->
    @callback()

  # Do something when the user hovers over the button
  #
  hover: ->
