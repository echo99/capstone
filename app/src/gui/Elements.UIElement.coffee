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

if exports?
  root.CursorType = CursorType

# The base class for UI elements
#
# TODO:
# - Figure what to do about duplicate child references
# - Delay actual removing of children until after drawing to eliminate bugs due to
#   removing while drawing
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

    @_clearBucket = []

    @actX = @x
    @actY = @y
    @positioning = 'default'

  # Add a child element to this element
  #
  # @param [Elements.UIElement] elem
  #
  addChild: (elem) ->
    if elem not instanceof Elements.UIElement
      console.error("#{elem} is not a UIElement")
    else
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
  # @param [Elements.UIElement] elem
  # @return [Boolean] Whether or not the child was successfully removed
  #
  removeChild: (elem) ->
    @setDirty()
    @_clearBucket.push(elem)
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
    console.log("Destroy called on " + @toString())
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
  # @param [Elements.UIElement] parent
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
    for clearedChild in @_clearBucket
      clearedChild.clear(ctx, coords, zoom) if clearedChild.visible or
        clearedChild._closing
    @_clearBucket = []
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
      @_hasDirtyChildren = false
        # for child in @_children
        #   child.draw(ctx, coords, zoom, forceDraw)

  # @private Draw all children of this element
  #
  _drawChildren: (ctx, coords=null, zoom=1.0, forceDraw=false) ->
    for child in @_children
      child?.draw(ctx, coords, zoom, forceDraw)

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
      child?.setActualLocation(this)


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
          if child?.visible
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
          if child?
            if hoveredChild
              child.mouseOut()
            else
              pointer = child.mouseMove(relLoc.x, relLoc.y)
              if pointer
                pointerType = pointer
                hoveredChild = true
    else if @_hovering and @visible
      # @_hovering = false
      # @_onMouseOut()
      @mouseOut()
    return pointerType

  # Call when the mouse leaves the element (for times when the event can't be
  # automatically detected)
  mouseOut: ->
    if @_hovering
      @_hovering = false
      @_onMouseOut()
      for child in @_children
        child?.mouseOut()

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
          if child?
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
        child.mouseUp() if child? and child._pressed

  # [WIP] Call to when element is resized
  resize: ->
    @_onResize()
    for child in @_children
      child.mouseUp() if child? and child._pressed

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

