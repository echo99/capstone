# The base class for UI elements
#
class UIElement
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
  # @TODO finish doc
  draw: (ctx, x, y) ->


# A box UI element
#
class BoxElement extends UIElement

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
class RadialElement extends UIElement

  # Create a new radial element
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] r Radius of element
  constructor: (@x, @y, @r) ->
    super()
    @r2 = @r*@r

  containsPoint: (x, y) ->
    dx = Math.abs(@x - x)
    dy = Math.abs(@y - y)
    return dx*dx + dy*dy <= @r2

# Message box class for displaying messages in the user interface
#
class MessageBox extends BoxElement
  # Various types of messages
  TYPES =
    Info: 1
    Warn: 2

  # Create a new message box
  constructor: (@x, @y, @w, @h, @message) ->

  # @param [CanvasRenderingContext2D] ctx
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


