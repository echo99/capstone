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
camera.setDragMode(window.config.DRAG_TYPE)
game = new Game(0, 0)
gameFrame = null

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
  frameElement = new Elements.Frame(frame, hudCanvas)
  gameFrame = new Elements.GameFrame(camera, canvas)
  # msgBox = new Elements.MessageBox(60, 300, 100, 100, "HUD", hudCtx)
  # frameElement.addChild(msgBox)
  # frameElement.addChild(new Elements.MessageBox(200, 500, 200, 80,
  #   "This message is too long", hudCtx))
  frameElement.drawChildren()

  msgBox2 = new Elements.MessageBox(50, -50, 100, 100, "test", ctx)
  msgBox2.setZIndex(1)
  gameFrame.addChild(msgBox2)

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
    # console.log("New Size: #{window.innerWidth} x #{window.innerHeight}")
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
    frameElement.setDirty()
    frameElement.drawChildren()

    # console.log("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

  document.body.addEventListener('keydown', (e) ->
    if e.keyCode == KeyCodes.HOME
      camera.setTarget(0, 0)
    else if e.keyCode == KeyCodes.SPACE
      console.log("end turn")
      game.endTurn()
      UI.endTurn()
  )

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
    if pointer is null
      pointer = gameFrame.mouseMove(x, y)
    else
      gameFrame.mouseOut()
    if pointer isnt null
      hudCanvas.style.cursor = pointer
    else
      hudCanvas.style.cursor = 'auto'
    if drag
      difx = x - prevPos.x
      dify = y - prevPos.y
      # difx = difx / Math.abs(difx) if difx
      # dify = dify / Math.abs(dify) if dify
      # console.log "Difx: #{difx}, dify: #{dify}"
      # newX = camera.x + difx #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      # newY = camera.y + dify #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      # camera.setPosition(newX, newY)
      prevPos = {x: x, y: y}
      camera.moveCameraByScreenDistance(difx, dify)
      # coords = camera.getWorldCoordinates({x: x, y: x})
      # camera.setPosition(coords.x, coords.y)
      # camera.setPosition(camera.x+difx/camera.zoom, camera.y+dify/camera.zoom)
  )

  hudCanvas.addEventListener('click', (e) ->
    UI.onMouseClick(e.clientX, e.clientY)
    CurrentMission.onMouseMove(e.clientX, e.clientY)
    # if msgBox.containsPoint(e.clientX, e.clientY)
    # msgBox.click(e.clientX, e.clientY)
    x = e.clientX
    y = e.clientY
    if frameElement.click(x, y)
      frameElement.mouseMove(x, y)
    else if gameFrame.click(x, y)
      gameFrame.mouseMove(x, y)
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
