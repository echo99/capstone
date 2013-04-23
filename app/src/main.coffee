# The main script for the game

#_require util/SpriteSheet
#_require util/AtlasParser
#_require missions/Menu
#_require gui/UserInterface
#_require util/Camera
#_require gui/uielements
#_require backend/Game

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
  HOME: 36  # for repositioning the camera
  SPACE: 32 # for advancing the turn

SpriteNames = window.config.spriteNames

frameElement = null

UI = new UserInterface()
camera = new Camera(0, 0, 0, 0)
game = new Game(0, 0)
gameFrame = new Elements.GameFrame(camera)

CurrentMission = null

# Draw the background
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

# Keeping this here for reference, delete when no longer useful
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

# Update the size of the frame and the canvases when the window size changes
updateCanvases = (frame, canvases...) ->
  frameWidth = window.innerWidth
  frameHeight = window.innerHeight
  frame.width = frameWidth
  frame.height = frameHeight
  for canvas in canvases
    canvas.width = frameWidth
    canvas.height = frameHeight
  camera.setSize(window.innerWidth, window.innerHeight)

# The main method
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

  # frameElement = new Elements.BoxElement(canvas.width/2, canvas.width/2,
  #   canvas.width, canvas.height)
  frameElement = new Elements.Frame(frame)
  msgBox = new Elements.MessageBox(60, 60, 100, 100, "test", hudCtx)
  # msgBox.draw(hudCtx)
  frameElement.addChild(msgBox)
  frameElement.drawChildren()

  # msgBox.addUpdateCallback ->
  #   hudCtx.clearRect(msgBox.x-3, msgBox.y-3, msgBox.w+6, msgBox.h+6)
  #   msgBox.draw(hudCtx)

  CurrentMission = new Menu()

  sheet = SHEET
  if sheet == null
    # Should never get here
    console.log("Sheet not loaded!")
  else
    console.log("Sheet loaded!")
    drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)

  sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)

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

  muteBtn = new Elements.DOMButton(config.spriteNames.UNMUTED, SHEET)
    .setRight(5).setBottom(26)

  window.onresize = ->
    console.log("New Size: #{window.innerWidth} x #{window.innerHeight}")
    updateCanvases(frame, canvas, hudCanvas)

    if screen.height > bgCanvas.height or screen.width > bgCanvas.width
      bgCanvas.height = screen.height
      bgCanvas.width = screen.width
      drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)
    if not document.mozFullScreenElement and
        not document.webkitFullScreenElement
      sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)

    bgCanvas.style.left = (0.5+(canvas.width - bgCanvas.width)/2) << 0 + "px"
    bgCanvas.style.top = (0.5+(canvas.height - bgCanvas.height)/2) << 0 + "px"

    # msgBox.draw(hudCtx)
    frameElement.resize()
    frameElement.drawChildren()

    console.log("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

  document.body.addEventListener('keydown', (e) ->
    if e.keyCode == KeyCodes.HOME
      camera.setTarget(0, 0))

  # Catch accidental leaving
  window.onbeforeunload = (e) ->
    # No progress can be lost in the menu
    if (not CurrentMission instanceof Menu)
      if (not e)
        e = window.event
      e.cancelBubble = true
      e.returnValue = "Progress my be lost, are you sure you want to leave?"
      if (e.stopPropagation)
        e.stopPropagation()
        e.preventDefault()

  prevPos = {x: 0, y: 0}
  drag = false
  hudCanvas.addEventListener('mousemove', (e) ->
    x = e.clientX
    y = e.clientY
    UI.onMouseMove(x, y)
    CurrentMission.onMouseMove(x, y)
    pointer = frameElement.mouseMove(x, y)#msgBox.mouseMove(x, y)
    if pointer
      hudCanvas.style.cursor = pointer
    else
      hudCanvas.style.cursor = 'auto'
    if drag
      difx = x - prevPos.x
      dify = y - prevPos.y
      newX = camera.x + difx #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      newY = camera.y + dify #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      camera.setPosition(newX, newY)
      prevPos = {x: x, y: y})

  hudCanvas.addEventListener('click', (e) ->
    UI.onMouseClick(e.clientX, e.clientY)
    CurrentMission.onMouseMove(e.clientX, e.clientY)
    # if msgBox.containsPoint(e.clientX, e.clientY)
    # msgBox.click(e.clientX, e.clientY)
    frameElement.click(e.clientX, e.clientY)
  )

  hudCanvas.addEventListener('mousedown', (e) ->
    drag = true
    prevPos = {x: e.clientX, y: e.clientY})

  hudCanvas.addEventListener('mouseup', (e) ->
    drag = false)

  hudCanvas.addEventListener('mouseout', (e) ->
    drag = false)

  mouseWheelHandler = (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    nz = camera.zoom + delta * window.config.ZOOM_SPEED
    camera.setZoom(nz)

  document.body.addEventListener('DOMMouseScroll', mouseWheelHandler)

  document.body.addEventListener('mousewheel', mouseWheelHandler)

  draw = ->
    ctx.clearRect(0, 0, camera.width, camera.height)
    UI.draw(ctx, hudCtx)
    CurrentMission.draw(ctx, hudCtx)
    bgCanvas.style.left = Math.floor(camera.x /
      window.config.BG_PAN_SPEED_FACTOR - camera.width/2) + "px"
    bgCanvas.style.top = Math.floor(camera.y /
      window.config.BG_PAN_SPEED_FACTOR - camera.height/2) + "px"
    camera.update()

    # Don't forget to update the animation
    AnimatedSprite.drawCounter++

  setInterval draw, 30