# The main script for the game

#_require util/SpriteSheet
#_require util/AtlasParser
#_require gui/MainMenu
#_require missions/Menu
#_require gui/UserInterface
#_require util/Camera

# Load the atlas and dom before doing anything else
IMAGE_LOADED = false
DOM_LOADED = false

# Load image and image data as soon as possible
SHEET = null
$.getJSON('assets/images/atlas.json', {}, (data) ->
  SHEET = new SpriteSheet('assets/images/atlas.png')
  SHEET.loadImage ->
    as = new AtlasParser(SHEET, data)
    as.parseDataToSheet()
    IMAGE_LOADED = true
    if DOM_LOADED
      main()
)

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  if IMAGE_LOADED
    main()

KeyCodes =
  SPACE: 32
#  UP: 38
#  RIGHT: 39
#  DOWN: 40

SpriteNames = window.config.spriteNames

UI = new UserInterface()
camera = new Camera(0, 0, 0, 0)

CurrentMission = new Menu()

drawBackground = (ctx, spritesheet, name) ->
  canvas = ctx.canvas
  width = canvas.width
  height = canvas.height
  sprite = spritesheet.getSprite(name)
  bgWidth = sprite.w
  bgHeight = sprite.h
  numXTiles = Math.ceil(width/bgWidth)
  numYTiles = Math.floor(height/bgWidth)
  xStart = sprite.cx
  yStart = sprite.cy
  xCoords = [xStart]
  yCoords = [yStart]
  for i in [0..numXTiles]
    xStart += bgWidth
    xCoords.push(xStart)
  for i in [0..numYTiles]
    yStart += bgHeight
    yCoords.push(yStart)
  for xPos in xCoords
    for yPos in yCoords
      spritesheet.drawSprite(name, xPos, yPos, ctx, false)

#drawHUD = (ctx, spritesheet) ->
#  winStyle = window.config.windowStyle
#  ctx.fillStyle = winStyle.fill #"rgba(0, 37, 255, 0.5)"
#  ctx.strokeStyle = winStyle.stroke #"rgba(0, 37, 255, 1)"
#  ctx.lineJoin = winStyle.lineJoin #"bevel"
#  ctx.lineWidth = winStyle.lineWidth #5
#  ctx.font = winStyle.title.font #"15px Arial"
#  ctx.fillRect(50, 50, 105, 100)
#  ctx.strokeRect(50, 50, 105, 100)
#  ctx.beginPath()
#  ctx.moveTo(50, 73)
#  ctx.lineTo(155, 73)
#  ctx.stroke()
#  ctx.fillStyle = winStyle.title.color #"rgba(255, 255, 255, 1)"
#  ctx.fillText("Selected Units", 57, 67)
#  ctx.fillStyle = winStyle.value.color #"rgba(255, 255, 0, 1)"
#  ctx.fillText("1", 110, 105)

#  spritesheet.drawSprite(SpriteNames.PROBE, 70, 100, ctx)

updateCanvases = (frame, canvases...) ->
  frameWidth = window.innerWidth
  frameHeight = window.innerHeight
  frame.width = frameWidth
  frame.height = frameHeight
  for canvas in canvases
    canvas.width = frameWidth
    canvas.height = frameHeight
  camera.setSize(window.innerWidth, window.innerHeight)

main = ->
  frame = document.getElementById('frame')
  canvas = document.getElementById('canvas-fg')
  bgCanvas = document.getElementById('canvas-bg')
  hudCanvas = document.getElementById('canvas-hud')
  updateCanvases(frame, canvas, hudCanvas)
  # we should just make the bg larger than we'll ever need it to be
  bgCanvas.width = screen.width * 2
  bgCanvas.height = screen.height * 2
  bgCtx = bgCanvas.getContext('2d')
  ctx = canvas.getContext('2d')
  hudCtx = hudCanvas.getContext('2d')

  fsCanvas = document.getElementById('fs-button')
  fsCtx = fsCanvas.getContext('2d')

  sheet = SHEET
  if sheet == null
    # Should never get here
    console.log("Sheet not loaded!")
  else
    console.log("Sheet loaded!")
    drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)

  sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)

  # Some fun messing around with fullscreen
  maxWidth = 0
  maxHeight = 0

  canvasclick = ->
    # eheight: 619 -> 774 (diff of 155)
    if document.mozFullScreenElement or document.webkitFullScreenElement
      console.log "Already full screen!"
      if document.cancelFullScreen
        document.cancelFullScreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else if document.webkitCancelFullScreen
        document.webkitCancelFullScreen()
      sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)
    else
      console.log "Not at full screen"
      body = document.body
      if body.requestFullScreen
        body.requestFullScreen()
      else if body.mozRequestFullScreen
        body.mozRequestFullScreen()
      else if body.webkitRequestFullscreen
        body.webkitRequestFullscreen()
      sheet.drawSprite(SpriteNames.UNFULL_SCREEN, 8, 8, fsCtx, false)
  fsCanvas.addEventListener('mousedown', canvasclick)

  window.onresize = ->
    console.log("New Size: #{window.innerWidth} x #{window.innerHeight}")
    updateCanvases(frame, canvas, hudCanvas)
    #box.x = canvas.width/2
    #box.y = canvas.height/2

    if screen.height > bgCanvas.height or screen.width > bgCanvas.width
      bgCanvas.height = screen.height
      bgCanvas.width = screen.width
      drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)
    if not document.mozFullScreenElement and
        not document.webkitFullScreenElement
      sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)

    bgCanvas.style.left = (0.5+(canvas.width - bgCanvas.width)/2) << 0 + "px"
    bgCanvas.style.top = (0.5+(canvas.height - bgCanvas.height)/2) << 0 + "px"

    console.log("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

#  box =
#    x: canvas.width/2
#    y: canvas.height/2
#    w: 40
#    h: 40
#    halfwidth: 20
#    halfheight: 20
#    radius: Math.ceil(20*1.5)
#    diameter: Math.ceil(40*1.5)
#    angle: 2

#  mm = MainMenu.get(ctx, sheet)
#  mm.startAnim()

  document.body.addEventListener('keydown', (e) ->
    if e.keyCode == KeyCodes.SPACE
      camera.setTarget(0, 0))

  prevPos = {x: 0, y: 0}
  drag = false
  hudCanvas.addEventListener('mousemove', (e) ->
    x = e.clientX
    y = e.clientY
    UI.onMouseMove(x, y)
    if drag
      difx = x - prevPos.x
      dify = y - prevPos.y
      newX = camera.x + difx #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      newY = camera.y + dify #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      camera.setPosition(newX, newY)
      prevPos = {x: x, y: y})

  hudCanvas.addEventListener('click', (e) ->
    UI.onMouseClick(e.clientX, e.clientY))

  hudCanvas.addEventListener('mousedown', (e) ->
    drag = true
    prevPos = {x: e.clientX, y: e.clientY})

  hudCanvas.addEventListener('mouseup', (e) ->
    drag = false)

  hudCanvas.addEventListener('mouseout', (e) ->
    drag = false)

#  mouseWheelHandler: (e) ->
#    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
#    console.log(delta)
#    z = camera.getZoom()
#    camera.setZoom(z + delta * 0.01)

  document.body.addEventListener('DOMMouseScroll', (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    nz = camera.zoom + delta * window.config.ZOOM_SPEED
    camera.setZoom(nz))

  document.body.addEventListener('mousewheel', (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    nz = camera.zoom + delta * window.config.ZOOM_SPEED
    camera.setZoom(nz))

  draw = ->
    ctx.clearRect(0, 0, camera.width, camera.height)
    UI.draw(ctx)
    CurrentMission.draw(ctx)
    bgCanvas.style.left = Math.floor(camera.x /
      window.config.BG_PAN_SPEED_FACTOR - camera.width/2) + "px"
    bgCanvas.style.top = Math.floor(camera.y /
      window.config.BG_PAN_SPEED_FACTOR - camera.height/2) + "px"
    camera.update()
  #   if sheet != null
  #     ctx.save()
  #     ctx.translate(box.x, box.y)
  #     sheet.drawSprite(SpriteNames.PLANETS[0], 0, 0, ctx)
  #     lastAngle = 0
  #     for ship in ships
  #       ship.angle += ship.angularVelocity
  #       ctx.rotate(ship.angle-lastAngle)
  #       if ship.orientation == Orientation.UP
  #         sheet.drawSprite(ship.sptName, -ship.orbitRadius, 0, ctx)
  #       else
  #         sheet.drawSprite(ship.sptName, 0, -ship.orbitRadius, ctx)
  #       lastAngle = ship.angle
  #     ctx.restore()
  #     sheet.drawSprite(SpriteNames.TITLE, box.x, 100, ctx)

  setInterval draw, 30