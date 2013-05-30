class ArrowElement
  constructor: (@start, @end, @speed, @length, @onHud=false) ->
    @distanceMoved = 0
    @current = @start
    vec = {x: @end.x - start.x, y: @end.y - start.y}
    @pathLength = Math.sqrt(vec.x*vec.x + vec.y*vec.y)
    @dir = {x: vec.x / @pathLength, y: vec.y / @pathLength}
    @_dir = {x: @dir.x, y: @dir.y}
    @element = new Elements.BoxElement(@current.x, @current.y, 0, 0)
    @element.setDrawFunc(@draw)
    @element.setClearFunc(@clear)
    @element.visible = true
    if @onHud
      cameraHudFrame.addChild(@element)
    else
      gameFrame.addChild(@element)

    c = Math.cos(window.config.arrowStyle.angle)
    s = Math.sin(window.config.arrowStyle.angle)
    @h1Dir = {x: @dir.x * c - @dir.y * s, y: @dir.x * s + @dir.y * c}
    c = Math.cos(-window.config.arrowStyle.angle)
    s = Math.sin(-window.config.arrowStyle.angle)
    @h2Dir = {x: @dir.x * c - @dir.y * s, y: @dir.x * s + @dir.y * c}
    @hLength = @length / 4

  close: ->
    @element.close()

  open: ->
    @element.open()

  clear: (ctx) =>
    x = Math.min(@start.x, @end.x) - @length - 10
    y = Math.min(@start.y, @end.y) - @length - 10
    w = Math.max(@start.x, @end.x) - x + @length + 10
    h = Math.max(@start.y, @end.y) - y + @length + 10
    ctx.clearRect(x, y, w, h)

  _drawArrow: (ctx, loc) =>
    #@clear(ctx)
    ctx.strokeStyle = window.config.arrowStyle.color
    ctx.lineWidth = window.config.arrowStyle.width
    ctx.lineJoin = 'round'
    ctx.miterLimit = 5
    start = loc
    end = {x: start.x + @_dir.x * @length, y: start.y + @_dir.y * @length}
    h1end = {x: start.x + @h1Dir.x * @hLength, y: start.y + @h1Dir.y * @hLength}
    h2end = {x: start.x + @h2Dir.x * @hLength, y: start.y + @h2Dir.y * @hLength}

    ctx.beginPath()
    ctx.moveTo(end.x, end.y)
    ctx.lineTo(start.x, start.y)
    ctx.lineTo(h1end.x, h1end.y)
    ctx.moveTo(start.x, start.y)
    ctx.lineTo(h2end.x, h2end.y)
    ctx.stroke()

  draw: (ctx) =>
    loc =
      x: Math.floor(@current.x)
      y: Math.floor(@current.y)

    if @onHud
      l = loc
    else
      l = camera.getScreenCoordinates(loc)
    @_drawArrow(ctx, l)

    @current.x += @dir.x * @speed
    @current.y += @dir.y * @speed

    @element.moveTo(@current.x, @current.y)

    @distanceMoved += @speed
    if @distanceMoved > @pathLength
      @distanceMoved = 0
      @dir = {x: @dir.x * -1, y: @dir.y * -1}

  destroy: ->
    @element.destroy()
    UI.movingElements = UI.movingElements.filter((e) => e != @)
