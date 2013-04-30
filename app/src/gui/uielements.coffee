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

  # @private @property [Number] Element ordering rank
  _zIndex: 0

  # @property [Boolean] Flag for if the elemnt needs to be redrawn
  dirty: true

  # Create a new UI element
  #
  constructor: (@x, @y) ->
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

  # Set actual location
  setActualLocation: (parent) ->
    {x, y} = parent.getActualLocation(0, 0)
    # @actX = parent.actX - @x
    # @actY = parent.actY - @y
    @actX = x + @x
    @actY = y + @y

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
  setDrawFunc: (@_drawFunc) ->

  # Call the draw function with the passed arguments
  #
  # @overload draw(ctx)
  #   Draw the element
  #   @param [CanvasRenderingContext2D] ctx
  #
  # @overload draw(ctx, coords, zoom)
  #   Draw the element at the given coordinates and zoom
  #   @param [CanvasRenderingContext2D] ctx
  #   @param [Object] coords The coordinates to draw to
  #   @param [Number] zoom The current zoom
  #
  draw: (ctx, coords=null, zoom=1.0) ->
    @dirty = false
    if @_drawFunc
      if coords is null
        @_drawFunc(ctx)
      else
        @_drawFunc(ctx, coords, zoom)
    # Draw all children
    for child in @_children
      child.draw(ctx, coords, zoom)

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
    # console.log("HandleDirtyChild called")
    if @clickable and not @dirty
      @setDirty()

  # Call to element to check if it is clicked and executes click handlers if it
  # is
  #
  # @param [Number] x
  # @param [Number] y
  # @return [Boolean] whether or not any of the element's children were clicked
  #
  click: (x, y) =>
    clickedSomething = false
    if @containsPoint(x, y) and @visible
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

  # @private Action to perform when element is clicked
  #
  _onClick: ->
    @clickHandler?()

  # @private Action to perform when element is hovered over
  #
  _onHover: ->
    @hoverHandler?()
    return CursorType.DEFAULT

  # private Action to perform when an element is no longer being hovered over
  #
  _onMouseOut: ->
    @mouseOutHandler?()

  # Get the hover status of this element
  #
  # @return [Boolean] whether or not this element is currently being hovered over
  isHovered: ->
    return @_hovering

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
    return {'x': x, 'y': y}

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
    super(@x, @y)
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
    return {'x': x+@x+@cx, 'y': y+@y+@cy}


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
    super(@x, @y)
    @r2 = @r*@r

  # @see Elements.UIElement#containsPoint
  containsPoint: (x, y) ->
    dx = Math.abs(@x - x)
    dy = Math.abs(@y - y)
    return dx*dx + dy*dy <= @r2


# A window for holding various other elements
#
class Elements.Window extends Elements.BoxElement

  # Create a new window
  #
  # @param [Number] x x-position of center of element relative to parent
  # @param [Number] y y-position of center of element relative to parent
  # @param [Number] w Width of element
  # @param [Number] h Height of element
  #
  constructor: (@x, @y, @w, @h) ->
    super(@x, @y, @w, @h)
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

  _onHover: ->
    @_animating = true
    @setDirty()
    super()

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
        super(ctx)
        ctx.restore()
      else
        ctx.restore()
        super(ctx)
    else
      super(ctx)
    if @_animating
      @setDirty()


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
        child.draw(@ctx) if child.dirty


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
          child.draw(@ctx, coords, @camera.getZoom())


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
  # @param [String] textAlign
  #   Horizontal alignment of the text: `'left'`, `'center'`, `'right'`
  # @param [String] vAlign
  #   Vertical alignment of the text: `'top'`, `'middle'`, `'bottom'`
  #
  constructor: (@x, @y, @w, @h, @message, @textAlign='center', @vAlign='middle') ->
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
    @lineSpacing = config.windowStyle.msgBoxText.lineWidth / 2
    @lines = []
    @_closing = false
    @_checkedWrap = false

    # console.log("My children: #{@_children}")
    # console.log("Button's children: #{@closeBtn._children}")

  # @private Wrap the text for this message box so the message will fit in the box
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  _wrapText: (ctx) ->
    ctx.font = config.windowStyle.msgBoxText.font
    textWidth = ctx.measureText(@message).width
    console.log("Width of #{@message} : #{textWidth}")
    allowedWidth = @w - (config.windowStyle.lineWidth * 4)
    lines = @message.split("\n")
    console.log(lines)
    for line in lines
      if textWidth > allowedWidth
        words = line.split(" ")
        console.log("Words: #{words}")
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
    console.log(@lines)
    @_checkedWrap = true


  # # Temporary callback function
  # callback: () ->
  #   @visible = false
  #   if @updCallback
  #     @updCallback()


  # Open this message box
  #
  open: ->
    @setDirty()
    @visible = true

  # Close this message box
  #
  close: ->
    @setDirty()
    @_closing = true


  # Add a callback to call when the message box updates
  addUpdateCallback: (callback) ->
    @updCallback = callback


  # @private Clear this message box from the context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  #
  _clearBox: (ctx) ->
    lw = config.windowStyle.lineWidth
    lw2 = lw + lw
    ctx.clearRect(@actX+@cx-lw, @actY+@cy-lw, @w + lw2, @h + lw2)


  # Draw this message box to the canvas context
  #
  # @param [CanvasRenderingContext2D] ctx Canvas context to draw on
  # @param [Object] coords The coordinates to draw to
  # @param [Number] zoom The current zoom
  #
  draw: (ctx, coords = null, zoom = null) ->
    if @_closing
      @_closing = false
      @visible = false
      @_clearBox(ctx)
      @setDirty()
    else if @visible
      if not @_parent.clickable
        @_clearBox(ctx)
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
      ctx.font = config.windowStyle.msgBoxText.font
      ctx.fillStyle = config.windowStyle.msgBoxText.color
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
  #
  constructor: (@x, @y, @w, @h, @clickHandler=null) ->
    super(@x, @y, @w, @h)

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
  #
  constructor: (@x, @y, @r, @clickHandler=null) ->
    super(@x, @y, @r)

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
  # @param [AnimatedSprite] sprite The sprite to use for the button
  # @param [SpriteSheet] sheet The sprite sheet the sprite belongs to
  #
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
    @sheet.drawSprite(@sprite, Math.round(@w/2), Math.round(@h/2), ctx, false)
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
