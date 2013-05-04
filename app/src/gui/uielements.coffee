# Elements namespace
if not root?
  root = exports ? window
root.Elements ?= {}
# Elements = Elements or {}
Elements = root.Elements


#_require ../util/Module
if exports?
  {Module} = require '../util/Module'


# An "Enum" of cursor types
CursorType =
  DEFAULT: 'auto'
  POINTER: 'pointer'
  WAIT: 'wait'
  MOVE: 'move'


# The base class for UI elements
#
# TODO:
# - Figure what to do about duplicate child references
#
class Elements.UIElement extends Module
  # @property [Boolean] Flag for if element is visible
  visible: true

  # @property [Boolean] Flag for if an element can obstruct clicks (might need
  #   to come up with a better name)
  clickable: true

  # @private @property [Boolean] Flag for if an element is being hovered over
  _hovering: false

  _pressed: false
  _clicked: false
  _startPressedOnThis: false
  _debug: false
  _closing: false
  _transparent: true
  _moving: false

  # @private @property [Number] Element ordering rank
  _zIndex: 0

  # @property [Boolean] Flag for if the elemnt needs to be redrawn
  dirty: true

  _hasDirtyChildren: false

  # Create a new UI element
  #
  # @param [Number] x
  # @param [Number] y
  # @param [Object] options
  # @option options [Boolean] visible
  # @option options [Boolean] clickable
  # @option options [Boolean] transparent
  # @option options [Number] zIndex
  #
  constructor: (@x, @y, options={}) ->
    {visible, clickable, transparent, zIndex} = options
    @visible = visible if visible?
    @clickable = clickable if clickable?
    @_zIndex = zIndex if zIndex?
    @_transparent = transparent if transparent?

    # @private @property [Array<Elements.UIElement>]
    @_children = []
    # @private @property [Array<Number>]
    @zIndices = [0]
    # @private @property [Array<Number>]
    @zIndicesRev = [0]
    # @private @property [Object]
    @_childBuckets = {0: []}
    # @private @property [Elements.UIElement]
    @_parent = null
    # @private @property [Object]
    @_properties = {}
    @_drawFunc = null

    @actX = @x
    @actY = @y
    @positioning = 'default'

  # Add a child element to this element
  #
  # @param [UIElement] elem
  #
  addChild: (elem) ->
    elem._parent = this
    elem.setActualLocation(this)
    @_children.push(elem)
    zIndex = elem._zIndex
    if zIndex in @zIndices
      @_childBuckets[zIndex].push(elem)
    else
      @zIndices.push(zIndex)
      @zIndices.sort()
      @zIndicesRev = @zIndices.slice(0)
      @zIndicesRev.reverse()
      @_childBuckets[zIndex] = [elem]

    # @_children.unshift(elem)

  # Remove a child element from this element if it exists
  #
  # @param [UIElement] elem
  # @return [Boolean] Whether or not the child was successfully removed
  #
  removeChild: (elem) ->
    elem._parent = null
    index = @_children.indexOf(elem)
    if index != -1
      @_children.splice(index)
    zIndex = elem._zIndex
    if zIndex of @_childBuckets
      childBucket = @_childBuckets[zIndex]
      index = childBucket.indexOf(elem)
      if index != -1
        childBucket.splice(index)
        return true
    return false

  # Destroy this element by removing references to it and its children.
  #
  # NOTE: Calling this method will not garbage collect this object unless you
  #   manually assign the reference to `null`
  #
  destroy: ->
    @deleteChildren()
    @_parent?.removeChild(this)

  # Remove all children from this element
  #
  deleteChildren: ->
    children = @_children
    for child in children
      @removeChild(child)
    @_children = []
    @zIndices = [0]
    @zIndicesRev = [0]
    @_childBuckets = {0: []}

  # @private Set actual location of this element
  #
  # @param [UIElement] parent
  #
  setActualLocation: (parent) ->
    {x, y} = parent.getActualLocation(0, 0)
    if @_debug
      console.log("Set actual location called on #{this}")
      console.log("Parent location: #{x}, #{y}")
    # @actX = parent.actX - @x
    # @actY = parent.actY - @y
    @actX = x + @x
    @actY = y + @y
    console.log("Set actual location at #{@actX}, #{@actY}") if @_debug
    # Propagate actual location setting
    for child in @_children
      child.setActualLocation(this)

  # Set a custom property for this element
  #
  # @param [String] key
  # @param [Mixed] value
  #
  setProperty: (key, value) ->
    @_properties[key] = value

  # Get a custom property value from this element
  #
  # @param [String] key
  # @return [Mixed] Property value that was set
  #
  getProperty: (key) ->
    if key of @_properties
      return @_properties[key]
    else return null

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

  # Sets the draw function for this element
  #
  # @param [Function] _drawFunc
  #
  setDrawFunc: (@_drawFunc) ->

  # Sets the clearing function for this element
  #
  # @param [Function] _clearFunc
  #
  setClearFunc: (@_clearFunc) ->

  # [WIP] Set the positioning of this element. Setting this currently has no effect.
  #
  # @param [String] positioning Either `default` or `center`
  #
  setPositioning: (@positioning) ->



  # Open this element
  #
  open: ->
    # console.log("==========================")
    # console.log(@toString() + " Opened")
    if not @visible
      # console.log("Called setDirty()")
      @setDirty()
      @visible = true

  # Close this element
  #
  close: ->
    if @visible
      @setDirty()
      @_closing = true


  # Call the draw function with the passed arguments
  #
  # @overload draw(ctx)
  #   Draw the element
  #   @param [CanvasRenderingContext2D] ctx
  #
  # @overload draw(ctx, coords, zoom, forceDraw)
  #   Draw the element at the given coordinates and zoom
  #   @param [CanvasRenderingContext2D] ctx
  #   @param [Object] coords The coordinates to draw to
  #   @param [Number] zoom The current zoom
  #   @param [Boolean] forceDraw Force the element to be redrawn
  #
  draw: (ctx, coords=null, zoom=1.0, forceDraw=false) ->
    if @_closing
      @_closing = false
      @visible = false
      @clear(ctx, coords, zoom)
      @setDirty()
    else if @visible
      if @dirty or forceDraw
        if @_moving
          @clear(ctx, coords, zoom)
          @_moving = false
        @dirty = false
        @_customDraw(ctx, coords, zoom)
        if @_drawFunc
          if coords is null
            @_drawFunc(ctx)
          else
            @_drawFunc(ctx, coords, zoom)
        # Draw all children
        # for child in @_children
        #   child.draw(ctx, coords, zoom)
        @_drawChildren(ctx, coords, zoom, forceDraw)
      else if @_hasDirtyChildren
        @_drawChildren(ctx, coords, zoom, forceDraw)
        # for child in @_children
        #   child.draw(ctx, coords, zoom, forceDraw)

  # @private Draw all children of this element
  #
  _drawChildren: (ctx, coords=null, zoom=1.0, forceDraw=false) ->
    for child in @_children
      child.draw(ctx, coords, zoom, forceDraw)

  # @private @abstract Custom draw method for each element that is meant to be
  # overridden
  #
  _customDraw: (ctx, coords=null, zoom=1.0) ->

  # Move this element to a new location
  #
  # @param [Number] newX
  # @param [Number] newY
  #
  moveTo: (newX, newY) ->
    if @visible
      @_moving = true
      @setDirty()
    {x, y} = @getActualLocation(newX, newY)
    @actX = x
    @actY = y
    @x = newX
    @y = newY
    for child in @_children
      child.setActualLocation(this)


  # Clear this element using a clear function
  #
  # @param [CanvasRenderingContext2D] ctx
  # @param [Object] coords The coordinates to draw to
  # @param [Number] zoom The current zoom
  #
  clear: (ctx, coords=null, zoom=1.0) ->
    # @dirty = false
    if coords is null
      @_clearFunc?(ctx)
    else
      @_clearFunc?(ctx, coords, zoom)

  # Set this element and all child elements to dirty
  #
  # @TODO: Somehow propogate dirty state back to parent so it knows to redraw it,
  #   but we don't always want to redraw the dirty parent.
  #
  setDirty: (propagateUp = true) ->
    # console.log("SetDirty called on #{@constructor.name}")
    @dirty = true
    for zIndex in @zIndices
      children = @_childBuckets[zIndex]
      for child in children
        child.setDirty(false) if not child.dirty
    @_parent?._handleDirtyChild(this) if propagateUp

  # @private Method for propogating dirtyness
  #
  # @param [UIElement] child
  #
  _handleDirtyChild: (child) ->
    console.log("HandleDirtyChild called on  #{@toString()} by #{child.toString()}")
    #  and (@_transparent or @_closing)
    @_hasDirtyChildren = true
    if @clickable and not @dirty
      if child._transparent or child._closing
        @setDirty()
      else
        @_parent?._handleDirtyChild(this)

  # Call to element to check if it is clicked and executes click handlers if it
  # is
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Boolean] whether or not any of the element's children were clicked
  #
  click: (x, y) =>
    clickedSomething = false
    if @containsPoint(x, y) and @visible and @_clicked
      clickedSomething = @clickable
      # console.log("clicked #{@constructor.name} at (#{x}, #{y})")
      @_onClick()
      relLoc = @getRelativeLocation(x, y)
      # console.log("  relative location: #{relLoc.x}, #{relLoc.y}")
      # console.log("In loop")
      # console.log("Children of #{@constructor.name} : #{@_children}")
      for zIndex in @zIndicesRev
        children = @_childBuckets[zIndex]
        # for child in @_children
        for child in children
          if child.visible
            # console.log("Checking #{child.name}")
            clickedChild = child.click(relLoc.x, relLoc.y)
            clickedSomething or= clickedChild
            # console.log("ClickedSomething: #{clickedSomething}")
        # console.log("Out of loop")
    # else
    #   console.log("missed #{@constructor.name} at (#{x}, #{y})")
    return clickedSomething

  # Call to element to check if it is being hovered over as the mouse moves and
  # executes hover handlers if it is
  #
  # @param [Number] x
  # @param [Number] y
  # @return [String] Pointer type if element is being hovered over, else null
  #
  mouseMove: (x, y) ->
    pointerType = null
    if @containsPoint(x, y) and @visible
      @_hovering = true
      pointerType = @_onHover() if @clickable
      relLoc = @getRelativeLocation(x, y)
      # console.log("relative location: #{@constructor.name} #{relLoc.x},
      #   #{relLoc.y} | #{pointerType}")
      # Flag to see if a child is being hovered over
      hoveredChild = false
      for zIndex in @zIndicesRev
        children = @_childBuckets[zIndex]
        # for child in @_children
        for child in children
          if hoveredChild
            child.mouseOut()
          else
            pointer = child.mouseMove(relLoc.x, relLoc.y)
            if pointer
              pointerType = pointer
              hoveredChild = true
    else if @_hovering and @visible
      @_hovering = false
      @_onMouseOut()
    return pointerType

  # Call when the mouse leaves the element (for times when the event can't be
  # automatically detected)
  mouseOut: ->
    if @_hovering
      @_hovering = false
      @_onMouseOut()
      for child in @_children
        child.mouseOut()

  # Call to element to check if it is being pressed
  #
  # @param [Number] x
  # @param [Number] y
  # @param [Boolean] Whether or not an element was pressed
  #
  mouseDown: (x, y) ->
    if @containsPoint(x, y) and @visible
      @_onMouseDown()
      relLoc = @getRelativeLocation(x, y)
      # console.log("relative location: #{@constructor.name} #{relLoc.x},
      #   #{relLoc.y} | #{pointerType}")
      # Flag to see if a child is being hovered over
      pressedChild = false
      for zIndex in @zIndicesRev
        children = @_childBuckets[zIndex]
        for child in children
          # if pressedChild
          #   child.mouseOut()
          # else
          pressedChild or= child.mouseDown(relLoc.x, relLoc.y)
          break if pressedChild
      return (@_pressed and @clickable) or pressedChild
    return false
          # if not pressedChild
          #   pressed = child.mouseDown(relLoc.x, relLoc.y)
            # pointer = child.mouseMove(relLoc.x, relLoc.y)
            # if pointer
            #   pointerType = pointer
              # hoveredChild = true
    # else if @_hovering and @visible
    #   @_hovering = false
    #   @_onMouseOut()
    # return pointerType

  # Call when the mouse lifts off the element
  #
  # TODO: Maybe make mouseUp() call click() if certain conditions are met?
  #
  mouseUp: ->
    if @_pressed
      @_onMouseUp()
      for child in @_children
        child.mouseUp() if child._pressed

  # [WIP] Call to when element is resized
  resize: ->
    @_onResize()
    for child in @_children
      child.mouseUp() if child._pressed

  # # @private Action to perform when element is hovered over
  # # @abstract
  # #
  # _onHover: ->
  #   return CursorType.DEFAULT

  # # @private Action to perform when an element is no longer being hovered over
  # # @abstract
  # #
  # _onMouseOut: ->

  # Set the onClick handler
  #
  # @param [Function] clickHandler
  #
  setClickHandler: (@clickHandler) ->

  # Set the onHover handler
  #
  # @param [Function] hoverHandler
  #
  setHoverHandler: (@hoverHandler) ->

  # Set the onMouseOut handler
  #
  # @param [Function] mouseOutHandler
  #
  setMouseOutHandler: (@mouseOutHandler) ->

  # Set the onMouseDown handler
  #
  # @param [Function] mouseDownHandler
  #
  setMouseDownHandler: (@mouseDownHandler) ->

  # Set the onMouseUp handler
  #
  # @param [Function] mouseUpHandler
  #
  setMouseUpHandler: (@mouseUpHandler) ->

  # Set the onResize handler
  #
  # @param [Function] resizeHandler
  #
  setResizeHandler: (@resizeHandler) ->

  # @private Action to perform when element is clicked
  #
  _onClick: ->
    @_clicked = false
    @clickHandler?()

  # @private Action to perform when element is hovered over
  #
  _onHover: ->
    @hoverHandler?()
    # @setDirty()
    return CursorType.DEFAULT

  # @private Action to perform when an element is no longer being hovered over
  #
  _onMouseOut: ->
    # @_pressed = false
    @mouseOutHandler?()

  # @private Action to perform when the mouse is pressed on this element
  #
  _onMouseDown: ->
    # console.log(@toString() + " pressed")
    @_pressed = true
    # @_startPressedOnThis = true
    @mouseDownHandler?()

  # @private Action to perform when the mouse is lifted off this element
  #
  _onMouseUp: ->
    # console.log(@toString() + " mouse up")
    @_clicked = @_pressed and @_hovering
    @_pressed = false
    # console.log(@_clicked)
    # Not sure if this is the right place to put this
    # @_startPressedOnThis = false
    @mouseUpHandler?()

  # @private Action to perform when the element is resized
  #
  _onResize: ->
    # if
    @resizeHandler?()

  # Get the hover status of this element
  #
  # @return [Boolean] Whether or not this element is currently being hovered over
  #
  isHovered: ->
    return @_hovering

  # Get the pressed status of this element
  #
  # @return [Boolean] Whether or not this element is currently being pressed
  #
  isPressed: ->
    return @_pressed and @_hovering

  # Gets the relative location of the point to this element
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Object] The coordinates `{'x': x, 'y': y}`
  getRelativeLocation: (x, y) ->
    return {'x': x, 'y': y}

  # Gets the actual location of the on this element in relation to the root element
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Object] The coordinates `{'x': x, 'y': y}`
  getActualLocation: (x, y) ->
    return {'x': @actX, 'y': @actY}

  # Set the z-index of the element
  #
  # @param [Number] zIndex (Must be an integer value)
  #
  setZIndex: (zIndex) ->
    lastZIndex = @_zIndex
    if lastZIndex != zIndex
      @_zIndex = zIndex
      if @_parent isnt null
        @_parent._updateChildOrdering(this, lastZIndex)

  # @private Update ordering of child elements when a child's z-index updates
  #
  # @param [UIElement] child
  # @param [Number] lastZIndex
  #
  _updateChildOrdering: (child, lastZIndex) ->
    # May be able to do this with calls to @removeChild and @addChild instead
    # but this works for now
    if lastZIndex of @_childBuckets
      childBucket = @_childBuckets[lastZIndex]
      console.log(childBucket)
      index = childBucket.indexOf(child)
      if index != -1
        childBucket.splice(index)
    zIndex = child._zIndex
    if zIndex in @zIndices
      @_childBuckets[zIndex].push(child)
    else
      @zIndices.push(zIndex)
      @zIndices.sort()
      @zIndicesRev = @zIndices.slice(0)
      @zIndicesRev.reverse()
      @_childBuckets[zIndex] = [child]

  # Get the string representation of the UIElement
  #
  # @return [String] String representation of element
  #
  toString: ->
    return "#{@constructor.name}: (#{@x}, #{@y})"



# A box UI element
#
class Elements.BoxElement extends Elements.UIElement

  # Create a new box element
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] w Width of element
  # @param [Number] h Height of element
  # @param [Object] options Extra options, see {Elements.UIElement#constructor}
  #
  constructor: (@x, @y, @w, @h, options={}) ->
    super(@x, @y, options)
    @cx = -Math.round(@w/2)
    @cy = -Math.round(@h/2)

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    # return not (@x < x or x > @x + width or @y < y or y > @y + width)
    return @x + @cx <= x <= @x - @cx and @y + @cy <= y <= @y - @cy

  # @see Elements.UIElement#getRelativeLocation
  getRelativeLocation: (x, y) ->
    return {'x': x-@x-@cx, 'y': y-@y-@cy}

  # @see Elements.UIElement#getActualLocation
  getActualLocation: (x, y) ->
    return {'x': x+@actX+@cx, 'y': y+@actY+@cy}

  # @see Elements.UIElement#toString
  toString: ->
    return "#{@constructor.name}: (#{@x}, #{@y}, #{@w}, #{@h})"


# A radial UI element
#
class Elements.RadialElement extends Elements.UIElement

  # Create a new radial element
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] r Radius of element
  # @param [Object] options Extra options, see {Elements.UIElement#constructor}
  #
  constructor: (@x, @y, @r, options={}) ->
    super(@x, @y, options)
    @r2 = @r*@r

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    dx = Math.abs(@x - x)
    dy = Math.abs(@y - y)
    return dx*dx + dy*dy <= @r2

  # @see Elements.UIElement#toString
  toString: ->
    return "#{@constructor.name}: (#{@x}, #{@y}, #{@r})"


# A window for holding various other elements
#
class Elements.Window extends Elements.BoxElement

  # Create a new window
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] w Width of element
  # @param [Number] h Height of element
  # @param [Object] options Extra options, see {Elements.UIElement#constructor}
  #
  constructor: (@x, @y, @w, @h, options={}) ->
    super(@x, @y, @w, @h, options)
    @_backgroundColor = null
    @_fadeFrames = 15
    @_currentAlpha = 0.5
    @_minAlpha = 0.5
    @_alphaInc = 1 / @_fadeFrames
    @_animating = false
    @_animateChildren = true
    # @hoverHandler = ->
    #   alert("hi")

  # Set the background color of this window
  #
  # @param [String] _backgroundColor
  #
  setBackgroundColor: (@_backgroundColor) ->

  # @private Override default onHover function
  _onHover: ->
    @_animating = true
    @setDirty()
    super()

  # @private Override default onMouseOut function
  _onMouseOut: ->
    @_animating = true
    @setDirty()
    super()

  # Draw the window
  #
  # @param [CanvasRenderingContext2D] ctx
  draw: (ctx) ->
    if @_backgroundColor?
      ctx.fillStyle = @_backgroundColor
      ctx.save()
      # console.log(@_hovering)
      # console.log(@_currentAlpha)
      if @_hovering and @_currentAlpha < 1
        @_currentAlpha += @_alphaInc
        # @setDirty()
      else if not @_hovering and @_currentAlpha > @_minAlpha
        # console.log(@_currentAlpha)
        @_currentAlpha -= @_alphaInc
      else
        @_animating = false
      ctx.globalAlpha = @_currentAlpha
      ctx.clearRect(@x+@cx, @y+@cy, @w, @h)
      ctx.fillRect(@x+@cx, @y+@cy, @w, @h)
      if @_animateChildren
        # super(ctx)
        @_drawChildren(ctx, null, null, true)
        ctx.restore()
      else
        ctx.restore()
        # super(ctx)
        @_drawChildren(ctx, null, null, true)
    else
      # super(ctx)
      @_drawChildren(ctx, null, null, true)
    if @_animating
      @setDirty()
    @dirty = false


# Frame for holding all elements in the HUD
class Elements.Frame extends Elements.UIElement

  # Create a new frame
  #
  # @param [Div] frame The frame div
  # @param [Canvas] canvas The HUD canvas
  #
  constructor: (@frame, @canvas) ->
    super(0, 0)
    @resize()
    @clickable = false
    @ctx = @canvas.getContext('2d')
    # cx = Math.round(@frame.width/2)
    # cy = Math.round(@frame.height/2)
    # super(cx, cy, @frame.width, @frame.height)

  # Resize the frame if the document frame resizes
  resize: ->
    # cx = Math.round(@frame.width/2)
    # cy = Math.round(@frame.height/2)
    # @x = cx
    # @y = cy
    @w = @frame.width
    @h = @frame.height
    super()

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    return true

  # @see Elements.UIElement#getRelativeLocation
  getRelativeLocation: (x, y) ->
    return {x: x, y: y}

  # Draw the frame's children
  drawChildren: ->
    # console.log("Frame's drawChildren called!")
    for zIndex in @zIndices
      children = @_childBuckets[zIndex]
      for child in children
        child.draw(@ctx) # if child.dirty or child._hasDirtyChildren


# Frame for holding all elements that need to be drawn relative to the center
# of the screen
#
class Elements.CameraFrame extends Elements.UIElement

  # Create a new camera frame
  #
  # @param [Camera] camera The camera object
  # @param [Canvas] canvas The camera hud canvas
  #
  constructor: (@camera, @canvas) ->
    # super(Math.floor(@camera.width/2), Math.floor(@camera.height/2))
    super(Math.floor(@camera.width/2), Math.floor(@camera.height/2))
    @clickable = false
    @ctx = @canvas.getContext('2d')

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    return true

  # @see Elements.UIElement#getRelativeLocation
  getRelativeLocation: (x, y) ->
    return {x: x-@x, y: y-@y}

  # @see Elements.UIElement#getActualLocation
  getActualLocation: (x, y) ->
    return {'x': @actX+x, 'y': @actY+y}

  # Resize the frame if the document frame resizes
  resize: ->
    # cx = Math.round(@frame.width/2)
    # cy = Math.round(@frame.height/2)
    # @x = cx
    # @y = cy
    @w = @camera.width
    @h = @camera.height
    @canvas.width = @w
    @canvas.height = @h
    @x = @w / 2
    @y = @h / 2
    @actX = @x
    @actY = @y
    # console.log("New x y: #{@x}, #{@y}")
    for child in @_children
      child.setActualLocation(this)
    super()
    @setDirty()
    @drawChildren()

  # Draw the frame's children
  drawChildren: ->
    # console.log("Frame's drawChildren called!")
    if @_hasDirtyChildren
      for zIndex in @zIndices
        children = @_childBuckets[zIndex]
        for child in children
          # if child.dirty
          #   console.log("Drawing: " + child)
          child.draw(@ctx, null, null, true)



# Frame for holding all elements in the game
class Elements.GameFrame extends Elements.UIElement

  # Create a new game frame
  #
  # @param [Camera] camera The camera object
  # @param [Canvas] canvas The game canvas
  #
  constructor: (@camera, @canvas) ->
    super(0, 0)
    @clickable = false
    @ctx = @canvas.getContext('2d')

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    return true

  # @see Elements.UIElement#getRelativeLocation
  getRelativeLocation: (x, y) ->
    return @camera.getWorldCoordinates({x: x, y: y})

  # Draw the frame's children if they are on the screen
  drawChildren: ->
    # console.log("GameFrame's drawChildren called!")
    for zIndex in @zIndices
      children = @_childBuckets[zIndex]
      for child in children
        coords = @camera.getScreenCoordinates({x: child.x, y: child.y})
        if @camera.onScreen(coords)
          child.draw(@ctx, coords, @camera.getZoom(), true)


# A class for holding text
class Elements.TextElement extends Elements.BoxElement
  # Create a new text element
  #
  # @param [Number] x The x-coordinate of the center of the box
  # @param [Number] y The y-coordinate of the center of the box
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [String] message The message to display in the box
  # @param [Object] options
  #   Extra options, see {Elements.UIElement#constructor} for more options
  # @option options [String] textAlign
  #   Horizontal alignment of the text: `'left'`, `'center'`, `'right'`.
  #   Default: `'center'`
  # @option options [String] vAlign
  #   Vertical alignment of the text: `'top'`, `'middle'`, `'bottom'`.
  #   Default: `'middle'`
  # @option options [String] font Set the message font
  # @option options [String] fontColor Set the message color
  #
  constructor: (@x, @y, @w, @h, @message, options={}) ->
    {textAlign, vAlign, font, fontColor} = options
    @closeBtn = if closeBtn? then closeBtn else null
    @textAlign = if textAlign? then textAlign else 'center'
    @vAlign = if vAlign? then vAlign else 'middle'
    @font = if font? then font else config.windowStyle.msgBoxText.font
    @fontColor = if fontColor? then fontColor else
      config.windowStyle.msgBoxText.color
    super(@x, @y, @w, @h, options)
    @lineSpacing = config.windowStyle.msgBoxText.lineWidth / 2
    @lines = []
    @_checkedWrap = false


  # @private Wrap the text for this message box so the message will fit in the box
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  _wrapText: (ctx) ->
    # ctx.font = config.windowStyle.msgBoxText.font
    ctx.font = @font
    textWidth = ctx.measureText(@message).width
    # console.log("Width of #{@message} : #{textWidth}")
    allowedWidth = @w - (config.windowStyle.lineWidth * 4)
    lines = @message.split("\n")
    # console.log(lines)
    for line in lines
      if textWidth > allowedWidth
        words = line.split(" ")
        # console.log("Words: #{words}")
        curline = null
        lastTried = null
        for word in words
          lastTried = curline
          if curline is null
            curline = word
          else
            curline += ' ' + word
          if ctx.measureText(curline).width > allowedWidth
            if lastTried isnt null
              @lines.push(lastTried)
              curline = word
            else
              @lines.push(curline)
              curline = null
        if curline isnt null
          @lines.push(curline)
    # console.log(@lines)
    @_checkedWrap = true

  # @see Elements.UIElement#clear
  clear: (ctx) ->
    if not @_clearFunc?
      lw = Math.ceil(config.windowStyle.lineWidth / 2)
      lw2 = lw + lw
      ctx.clearRect(@actX+@cx-lw, @actY+@cy-lw, @w + lw2, @h + lw2)


  # @private Draw this text element to the canvas context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  # @param [Object] coords The coordinates to draw to
  # @param [Number] zoom The current zoom
  #
  _customDraw: (ctx, coords = null, zoom = null) ->
    # if @_closing
    #   @_closing = false
    #   @visible = false
    #   @clear(ctx)
    #   @setDirty()
    # else if @visible
    if true
      if not @_parent?.clickable
        @clear(ctx)
      if not @_checkedWrap
        @_wrapText(ctx)
      if coords
        x = coords.x
        y = coords.y
      else
        # x = @x
        # y = @y
        x = @actX
        y = @actY
      # if zoom
      #   cx = @cx * zoom
      #   cy = @cy * zoom
      #   w = @w * zoom
      #   h = @h * zoom
      # else
      if zoom
        ctx.save()
        ctx.translate(x, y)
        # x = @x
        # y = @y
        x = 0
        y = 0
        ctx.scale(zoom, zoom)
      cx = @cx
      cy = @cy
      w = @w
      h = @h
      ctx.font = @font
      ctx.fillStyle = @fontColor
      ctx.textAlign = @textAlign
      ctx.textBaseline = @vAlign

      lineWidth = config.windowStyle.lineWidth * 2
      switch @textAlign
        when 'left'
          tx = x + cx + lineWidth
        when 'right'
          tx = x - cx - lineWidth
        when 'center'
          tx = x

      yOffset = (@lines.length-1) * @lineSpacing
      switch @vAlign
        when 'top'
          ty = y + cy + lineWidth
          yTmp = ty
        when 'middle'
          ty = y
          yTmp = ty - yOffset
        when 'bottom'
          ty = y - cy - lineWidth
          yTmp = ty - yOffset*2

      if @lines.length > 0
        for line in @lines
          # ctx.fillText(line, x, yTmp)
          ctx.fillText(line, tx, yTmp)
          yTmp += config.windowStyle.msgBoxText.lineWidth
      else
        # ctx.fillText(@message, x, y)
        ctx.fillText(@message, tx, ty)

      if zoom
        ctx.restore()

      super(ctx, coords, zoom)

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
  # @param [Object] options
  #   Extra options, see {Elements.UIElement#constructor} for more options
  # @option options [Elements.UIElement] closeBtn
  # @option options [String] textAlign
  #   Horizontal alignment of the text: `'left'`, `'center'`, `'right'`.
  #   Default: `'center'`
  # @option options [String] vAlign
  #   Vertical alignment of the text: `'top'`, `'middle'`, `'bottom'`.
  #   Default: `'middle'`
  # @option options [String] font Set the message font
  # @option options [String] fontColor Set the message color
  #
  constructor: (@x, @y, @w, @h, @message, options={}) ->
    # @closeBtn=null, @textAlign='center',
    #   @vAlign='middle'
    {closeBtn, textAlign, vAlign, font, fontColor} = options
    @closeBtn = if closeBtn? then closeBtn else null
    @textAlign = if textAlign? then textAlign else 'center'
    @vAlign = if vAlign? then vAlign else 'middle'
    @font = if font? then font else config.windowStyle.msgBoxText.font
    @fontColor = if fontColor? then fontColor else
      config.windowStyle.msgBoxText.color
    super(@x, @y, @w, @h, options)

    if @closeBtn?
      @addChild(@closeBtn)
    @usingDefaultBtn = false
    @lineSpacing = config.windowStyle.msgBoxText.lineWidth / 2
    @lines = []
    # @_closing = false
    @_checkedWrap = false

    # console.log("My children: #{@_children}")
    # console.log("Button's children: #{@closeBtn._children}")

  # Set the default close button for this message box
  #
  setDefaultCloseBtn: ->
    @closeBtn = new Elements.Button(8, 8, 16, 16,
      ((obj) ->
        return -> obj.close())(this))
    @addChild(@closeBtn)
    @usingDefaultBtn = true

  # @private Wrap the text for this message box so the message will fit in the box
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  _wrapText: (ctx) ->
    # ctx.font = config.windowStyle.msgBoxText.font
    ctx.font = @font
    textWidth = ctx.measureText(@message).width
    # console.log("Width of #{@message} : #{textWidth}")
    allowedWidth = @w - (config.windowStyle.lineWidth * 4)
    lines = @message.split("\n")
    # console.log(lines)
    for line in lines
      if textWidth > allowedWidth
        words = line.split(" ")
        # console.log("Words: #{words}")
        curline = null
        lastTried = null
        for word in words
          lastTried = curline
          if curline is null
            curline = word
          else
            curline += ' ' + word
          if ctx.measureText(curline).width > allowedWidth
            if lastTried isnt null
              @lines.push(lastTried)
              curline = word
            else
              @lines.push(curline)
              curline = null
        if curline isnt null
          @lines.push(curline)
    # console.log(@lines)
    @_checkedWrap = true


  # # Temporary callback function
  # callback: () ->
  #   @visible = false
  #   if @updCallback
  #     @updCallback()


  # # Open this message box
  # #
  # open: ->
  #   if not @visible
  #     @setDirty()
  #     @visible = true

  # # Close this message box
  # #
  # close: ->
  #   if @visible
  #     @setDirty()
  #     @_closing = true


  # Add a callback to call when the message box updates
  addUpdateCallback: (callback) ->
    @updCallback = callback


  # # @private Clear this message box from the context
  # #
  # # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  # #
  # _clearBox: (ctx) ->
  #   lw = Math.ceil(config.windowStyle.lineWidth / 2)
  #   lw2 = lw + lw
  #   ctx.clearRect(@actX+@cx-lw, @actY+@cy-lw, @w + lw2, @h + lw2)

  # @see Elements.UIElement#clear
  clear: (ctx) ->
    if not @_clearFunc?
      lw = Math.ceil(config.windowStyle.lineWidth / 2)
      lw2 = lw + lw
      ctx.clearRect(@actX+@cx-lw, @actY+@cy-lw, @w + lw2, @h + lw2)


  # @private Draw this message box to the canvas context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  # @param [Object] coords The coordinates to draw to
  # @param [Number] zoom The current zoom
  #
  _customDraw: (ctx, coords = null, zoom = null) ->
    # if @_closing
    #   @_closing = false
    #   @visible = false
    #   @clear(ctx)
    #   @setDirty()
    # else if @visible
    if true
      if not @_parent?.clickable
        @clear(ctx)
      if not @_checkedWrap
        @_wrapText(ctx)
      if coords
        x = coords.x
        y = coords.y
      else
        # x = @x
        # y = @y
        x = @actX
        y = @actY
      # if zoom
      #   cx = @cx * zoom
      #   cy = @cy * zoom
      #   w = @w * zoom
      #   h = @h * zoom
      # else
      if zoom
        ctx.save()
        ctx.translate(x, y)
        # x = @x
        # y = @y
        x = 0
        y = 0
        ctx.scale(zoom, zoom)
      cx = @cx
      cy = @cy
      w = @w
      h = @h
      ctx.strokeStyle = config.windowStyle.stroke
      ctx.fillStyle = config.windowStyle.fill
      ctx.lineWidth = config.windowStyle.lineWidth
      # ctx.strokeRect(@x, @y, @w, @h)
      # ctx.fillRect(@x, @y, @w, @h)
      ctx.strokeRect(x+cx, y+cy, w, h)
      ctx.fillRect(x+cx, y+cy, w, h)
      # ctx.font = config.windowStyle.msgBoxText.font
      ctx.font = @font
      # ctx.fillStyle = config.windowStyle.msgBoxText.color
      ctx.fillStyle = @fontColor
      ctx.textAlign = @textAlign
      ctx.textBaseline = @vAlign
      # cx = Math.round(@w/2 + @x)
      # cy = Math.round(@h/2 + @y)
      # ctx.fillText(@message, cx, cy)

      lineWidth = config.windowStyle.lineWidth * 2
      switch @textAlign
        when 'left'
          tx = x + cx + lineWidth
        when 'right'
          tx = x - cx - lineWidth
        when 'center'
          tx = x

      yOffset = (@lines.length-1) * @lineSpacing
      switch @vAlign
        when 'top'
          ty = y + cy + lineWidth
          yTmp = ty
        when 'middle'
          ty = y
          yTmp = ty - yOffset
        when 'bottom'
          ty = y - cy - lineWidth
          yTmp = ty - yOffset*2

      if @lines.length > 0
        # console.log("Box is dirty: #{@dirty}")
        # yOffset = (@lines.length-1) * @lineSpacing
        # yTmp = y - yOffset
        for line in @lines
          # ctx.fillText(line, x, yTmp)
          ctx.fillText(line, tx, yTmp)
          yTmp += config.windowStyle.msgBoxText.lineWidth
      else
        # ctx.fillText(@message, x, y)
        ctx.fillText(@message, tx, ty)

      if @closeBtn? and @usingDefaultBtn
        btnOffsetX = x + @cx + @closeBtn.x + @closeBtn.cx
        btnOffsetY = y + @cy + @closeBtn.y + @closeBtn.cy
        cx = Math.round(@closeBtn.w/2 + btnOffsetX)
        cy = Math.round(@closeBtn.h/2 + btnOffsetY)
        ctx.fillStyle = 'rgb(0,0,0)'
        ctx.fillRect(btnOffsetX, btnOffsetY, @closeBtn.w, @closeBtn.h)
        ctx.fillStyle = 'rgb(255,255,255)'
        ctx.font = '12pt Arial'
        ctx.textAlign = 'center'
        ctx.textBaseline = 'middle'
        ctx.fillText('x', cx, cy)

      if zoom
        ctx.restore()

      super(ctx, coords, zoom)

# Button mixin [WIP]
# @mixin
Button =
  # Set the onClick handler
  #
  # @param [Function] clickHandler
  #
  setClickHandler: (@clickHandler) ->

  # Set the onHover handler
  #
  # @param [Function] hoverHandler
  #
  setHoverHandler: (@hoverHandler) ->

  # Set the onMouseOut handler
  #
  # @param [Function] mouseOutHandler
  #
  setMouseOutHandler: (@mouseOutHandler) ->

  # Call the attached callback function when the button is clicked
  #
  _onClick: ->
    if @clickHandler isnt null
      @clickHandler()

  # Do something when the user hovers over the button
  #
  _onHover: ->
    if @hoverHandler isnt null
      @hoverHandler()
    return CursorType.POINTER

  # Do something when the user's mouse leaves the button
  #
  _onMouseOut: ->
    if @mouseOutHandler isnt null
      @mouseOutHandler()


# All possible states for a button
ButtonStates =
  DEFAULT: 1
  HOVER: 2
  PRESSED: 3
  DISABLED: 4


# Button class for handling user interactions
#
class Elements.Button extends Elements.BoxElement

  # Create a new button
  #
  # @param [Number] x The x-coordinate of the center of the button
  # @param [Number] y The y-coordinate of the center of the button
  # @param [Number] w The width of the box
  # @param [Number] h The height of the box
  # @param [Function] clickHandler (optional) The function to call when this
  #   button is clicked
  # @param [Object] options Extra options, see {Elements.UIElement#constructor}
  #
  constructor: (@x, @y, @w, @h, @clickHandler=null, options={}) ->
    super(@x, @y, @w, @h, options)

  # Do something when the user hovers over the button
  #
  _onHover: ->
    super()
    # if @hoverHandler isnt null
    #   @hoverHandler()
    return CursorType.POINTER


# Button class for circular buttons
#
class Elements.RadialButton extends Elements.RadialElement

  # Create a new radial button
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] r Radius of element
  # @param [Function] clickHandler (optional) The function to call when this
  #   button is clicked
  # @param [Object] options Extra options, see {Elements.UIElement#constructor}
  #
  constructor: (@x, @y, @r, @clickHandler=null, options=null) ->
    super(@x, @y, @r, options)

  # Do something when the user hovers over the button
  #
  _onHover: ->
    super()
    return CursorType.POINTER

# Class for handling DOM (Document Object Model) buttons. These buttons are
# inserted into the DOM rather than drawn onto one of the existing canvases.
#
class Elements.DOMButton

  # Create a new DOM button
  #
  # @param [String] state The name of the initial state
  # @param [AnimatedSprite] sprite The initial sprite to use for the button
  # @param [SpriteSheet] sheet The sprite sheet the sprite belongs to
  #
  constructor: (@state, sprite, @sheet) ->
    @states = {}
    @states[state] = sprite
    spt = @sheet.getSprite(sprite)
    @w = spt.w
    @h = spt.h
    @canvas = document.createElement('canvas')
    @canvas.width = @w
    @canvas.height = @h
    @canvas.style.cursor = 'pointer'
    @canvas.style.position = 'absolute'
    document.body.appendChild(@canvas)
    @ctx = @canvas.getContext('2d')
    @sheet.drawSprite(sprite, Math.round(@w/2), Math.round(@h/2), @ctx, false)
    return this

  # Set the top offset of the button. Overrides bottom offset.
  #
  # @param [Number] offsetTop Top offset in pixels
  # @return [Elements.DOMButton] this button
  #
  setTop: (@offsetTop) ->
    @canvas.style.top = @offsetTop + 'px'
    return this

  # Set the bottom offset of the button. Overrides top offset.
  #
  # @param [Number] offsetBottom Bottom offset in pixels
  # @return [Elements.DOMButton] this button
  #
  setBottom: (@offsetBottom) ->
    @canvas.style.bottom = @offsetBottom + 'px'
    return this

  # Set the left offset of the button. Overrides right offset.
  #
  # @param [Number] offsetLeft Left offset in pixels
  # @return [Elements.DOMButton] this button
  #
  setLeft: (@offsetLeft) ->
    @canvas.style.left = @offsetLeft + 'px'
    return this

  # Set the right offset of the button. Overrides left offset.
  #
  # @param [Number] offsetTop Right offset in pixels
  # @return [Elements.DOMButton] this button
  #
  setRight: (@offsetRight) ->
    @canvas.style.right = @offsetRight + 'px'
    return this

  # Set the function to call when the button is clicked.
  #
  # @param [Function] callback Function to call when button is clicked
  # @return [Elements.DOMButton] this button
  #
  setClickHandler: (@callback) ->
    @canvas.addEventListener('mousedown', @callback)
    return this

  # Add a state sprite to the button
  #
  # @param [String] state The name of the state
  # @param [AnimatedSprite] sprite The sprite for this state
  #
  addState: (state, sprite) ->
    @states[state] = sprite

  # Set the state of the button
  #
  # @param [String] state State to set the button to
  #
  setState: (state) ->
    if state != @state and state of @states
      @state = state
      sprite = @states[state]
      @sheet.drawSprite(sprite, Math.round(@w/2), Math.round(@h/2), @ctx, false)

