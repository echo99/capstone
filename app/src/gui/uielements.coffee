# Elements namespace
if not root?
  root = exports ? window
root.Elements ?= {}
# Elements = Elements or {}
Elements = root.Elements


#_require Elements.UIElement
if exports?
  {Elements, CursorType} = require './Elements.UIElement'
  root.Elements = Elements


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
    # for clearedChild in @_removeQueue
    #   clearedChild.clear(@ctx) if clearedChild.visible or
    #     clearedChild._closing
    # @_removeQueue = []
    @_emptyRemoveQueue(@ctx)
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
    # for clearedChild in @_removeQueue
    #   clearedChild.clear(@ctx) if clearedChild.visible or
    #     clearedChild._closing
    # @_removeQueue = []
    @_emptyRemoveQueue(@ctx)
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
    # for clearedChild in @_removeQueue
    #   clearedChild.clear(@ctx) if clearedChild.visible or
    #     clearedChild._closing
    # @_removeQueue = []
    @_emptyRemoveQueue(@ctx)
    # console.log("GameFrame's drawChildren called!")
    for zIndex in @zIndices
      children = @_childBuckets[zIndex]
      for child in children
        if child?
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
      else
        @lines.push(line)
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
  # @options option [Number] lineHeight
  #   Height of each line of text (spacing + text height)
  # @options option [Number] hPadding Extra space to the left and right of the text
  # @options option [Number] vPadding Extra space to the top and bottom of the text
  #
  constructor: (@x, @y, @w, @h, @message, options={}) ->
    # @closeBtn=null, @textAlign='center',
    #   @vAlign='middle'
    {closeBtn, textAlign, vAlign, font, fontColor, lineHeight, hPadding, vPadding} =
      options
    @closeBtn = if closeBtn? then closeBtn else null
    @textAlign = if textAlign? then textAlign else 'center'
    @vAlign = if vAlign? then vAlign else 'middle'
    @font = if font? then font else config.windowStyle.msgBoxText.font
    @fontColor = if fontColor? then fontColor else
      config.windowStyle.msgBoxText.color
    @lineHeight = if lineHeight? then lineHeight else
      config.windowStyle.msgBoxText.lineHeight
    # Add width of border to padding
    @hPadding = Math.round(config.windowStyle.lineWidth / 2)
    @vPadding = @hPadding
    # Set default padding
    @hPadding += if hPadding? then hPadding else
      config.windowStyle.msgBoxText.padding
    @vPadding += if vPadding? then vPadding else
      config.windowStyle.msgBoxText.padding
    super(@x, @y, @w, @h, options)

    if @closeBtn?
      @addChild(@closeBtn)
    @usingDefaultBtn = false
    @lineSpacing = @lineHeight / 2
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
    # allowedWidth = @w - (config.windowStyle.lineWidth * 4)
    allowedWidth = @w - (@hPadding * 2)
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
      else
        @lines.push(line)
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

      switch @textAlign
        when 'left'
          tx = x + cx + @hPadding
        when 'right'
          tx = x - cx - @hPadding
        when 'center'
          tx = x

      yOffset = (@lines.length-1) * @lineSpacing
      switch @vAlign
        when 'top'
          # ty = y + cy + @lineHeight
          ty = y + cy + @vPadding
          yTmp = ty
        when 'middle'
          ty = y
          yTmp = ty - yOffset
        when 'bottom'
          # ty = y - cy - @lineHeight
          ty = y - cy - @vPadding
          yTmp = ty - yOffset*2

      if @lines.length > 0
        # console.log("Box is dirty: #{@dirty}")
        # yOffset = (@lines.length-1) * @lineSpacing
        # yTmp = y - yOffset
        for line in @lines
          # ctx.fillText(line, x, yTmp)
          ctx.fillText(line, tx, yTmp)
          yTmp += @lineHeight
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
    @enabled = true
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
    if @enabled
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

  # Enable this button
  #
  enable: ->
    if not @enabled
      @enabled = true
      sprite = @states[@state]
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @canvas.style.cursor = 'pointer'
      @ctx.globalAlpha = 1
      @sheet.drawSprite(sprite, Math.round(@w/2), Math.round(@h/2), @ctx, false)
      @canvas.addEventListener('mousedown', @callback)

  # Disable this button
  #
  disable: ->
    if @enabled
      @enabled = false
      sprite = @states[@state]
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @canvas.style.cursor = 'auto'
      @ctx.globalAlpha = 0.6
      @sheet.drawSprite(sprite, Math.round(@w/2), Math.round(@h/2), @ctx, false)
      @canvas.removeEventListener('mousedown', @callback)
