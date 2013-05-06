# The main script for the game

#_require util/canvas-context-extended
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

BROWSER = BrowserDetect.browser
Browser =
  CHROME: 'Chrome'
  FIREFOX: 'Firefox'
  IE: 'Explorer'


TESTING = window.TESTING?
# console.log("Testing flag: " + TESTING)

manifest = [
    src: 'assets/audio/empty_space_stage1.ogg'
    id: 'bgmusic1'
  ,
    src: 'assets/audio/empty_space_stage2.ogg'
    id: 'bgmusic2'
]

bgmusic = null

numToLoad = manifest.length
numLoaded = 0

createjs.Sound.addEventListener "loadComplete", ->
  numLoaded++
  if numLoaded >= numToLoad
    # Play music once all sounds have been loaded
    console.log('Finished loading sounds!')
    bgmusic = createjs.Sound.play('bgmusic1', createjs.Sound.INTERRUPT_NONE,
      10, 0, -1, 0.5)
    # Start it off muted
    bgmusic.mute(true)

createjs.Sound.registerManifest(manifest)

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
cameraHudFrame = null

camera = new Camera(0, 0, 0, 0)
camera.setDragMode(window.config.DRAG_TYPE)
UI = null
game = new Game(0, 0)
gameFrame = null

CurrentMission = null

tooltipCanvas = null
tooltipCtx = null

drag = false

newMission = (mission) ->
  CurrentMission.destroy()
  UI.destroy()
  UI = new UserInterface()
  CurrentMission = new mission()
  window.onresize()

newGame = (w, h) ->
  game = new Game(w, h)

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
  camera.setSize(frameWidth, frameHeight)

# The main method for the game
main = ->
  ##################################################################################
  # Get all necessary html elements

  frame = document.getElementById('frame')
  canvas = document.getElementById('canvas-fg')
  bgCanvas = document.getElementById('canvas-bg')
  hudCanvas = document.getElementById('canvas-hud')
  camerahudCanvas = document.getElementById('canvas-camerahud')
  tooltipCanvas = document.getElementById('canvas-tooltip')
  # Need a better variable name for this
  surface = document.getElementById('surface')
  updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas)
  # we should just make the bg larger than we'll ever need it to be
  bgCanvas.width = screen.width * 2
  bgCanvas.height = screen.height * 2
  # console.log(screen.width)
  surface.style.width = screen.width + 'px'
  surface.style.height = screen.height + 'px'
  # console.log(topSurface.style.width)
  bgCtx = bgCanvas.getContext('2d')
  ctx = canvas.getContext('2d')
  hudCtx = hudCanvas.getContext('2d')
  tooltipCtx = tooltipCanvas.getContext('2d')

  # console.log(ctx.font)
  # ctx.setFont({family: 'Arial'})
  # console.log(ctx.font)
  # ctx.setFontSizeVal(20)
  # console.log(ctx.font)

  feedback = $('#comments').jqm()

  # frameElement = new Elements.BoxElement(canvas.width/2, canvas.width/2,
  #   canvas.width, canvas.height)
  frameElement = new Elements.Frame(frame, hudCanvas)
  gameFrame = new Elements.GameFrame(camera, canvas)
  cameraHudFrame = new Elements.CameraFrame(camera, camerahudCanvas)
  # msgBox = new Elements.MessageBox(60, 300, 100, 100, "HUD", hudCtx)
  # frameElement.addChild(msgBox)
  # frameElement.addChild(new Elements.MessageBox(150, 350, 280, 100,
  #   "This message needs to be wrapped",
  #   {textAlign: 'left', vAlign:'bottom', lineHeight: 35}))
  # frameElement.addChild(new Elements.MessageBox(150, 550, 280, 100,
  #   "This message is right aligned",
  #   {textAlign:'right', hPadding: 30, vPadding: 10, vAlign: 'top'}))
  # frameElement.addChild(new Elements.MessageBox(450, 350, 280, 100,
  #   "This message is top aligned", {vAlign:'top'}))
  # frameElement.addChild(new Elements.MessageBox(150, 500, 280, 100,
  #   "This message\nhas a newline"))
  # frameElement.addChild(new Elements.MessageBox(450, 500, 280, 100,
  #   "This message is top right aligned", 'right', 'top'))
  # frameElement.addChild(new Elements.MessageBox(750, 350, 280, 100,
  #   "This message is bottom left aligned", 'left', 'bottom'))
  # win = new Elements.Window(60, 300, 100, 100)
  # win.setBackgroundColor("rgba(0, 37, 255, 0.5)")
  # win.addChild(new Elements.MessageBox(50, 50, 80, 80, "hover here"))
  # frameElement.addChild(win)
  # frameElement.drawChildren()
  # frameElement.addChild(new Elements.TextElement(300, 500, 160, 80,
  #   "some text here", {clickable: false, fontColor: 'rgb(100,255,255)',
  #   font: '15px sans-serif'}))
  # console.log(frameElement.toString())

  # msgBox2 = new Elements.MessageBox(200, -200, 100, 100, "test")
  # msgBox2.setDefaultCloseBtn()
  # msgBox2.setZIndex(1)
  # gameFrame.addChild(msgBox2)

  # cameraHudFrame.addChild(new Elements.MessageBox(0, 0, 100, 100, "test"))

  # msgBox.addUpdateCallback ->
  #   hudCtx.clearRect(msgBox.x-3, msgBox.y-3, msgBox.w+6, msgBox.h+6)
  #   msgBox.draw(hudCtx)

  UI = new UserInterface()
  CurrentMission = new Menu()

  sheet = SHEET
  if sheet == null
    # Should never get here
    console.log("Sheet not loaded!")
  else
    console.log("Sheet loaded!")
    drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)


  ##################################################################################
  # Create static buttons

  btnSpacing = config.buttonSpacing

  # Set fullscreen button
  fullscreenBtn = new Elements.DOMButton('fullscreen',
    config.spriteNames.FULL_SCREEN, SHEET).setRight(btnSpacing)
    .setBottom(btnSpacing)
  fullscreenBtn.addState('unfullscreen', config.spriteNames.UNFULL_SCREEN)
  fullscreenBtn.setClickHandler ->
    if document.mozFullScreenElement or document.webkitFullScreenElement or
        document.fullScreenElement
      console.log "Already full screen!"
      if document.cancelFullScreen
        document.cancelFullScreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else if document.webkitCancelFullScreen
        document.webkitCancelFullScreen()
      # sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)
      fullscreenBtn.setState('fullscreen')
    else
      console.log "Not at full screen"
      body = document.body
      if body.requestFullScreen
        body.requestFullScreen()
      else if body.mozRequestFullScreen
        body.mozRequestFullScreen()
      else if body.webkitRequestFullscreen
        body.webkitRequestFullscreen()
      fullscreenBtn.setState('unfullscreen')
      # sheet.drawSprite(SpriteNames.UNFULL_SCREEN, 8, 8, fsCtx, false)
  # Disable fullscreen button on IE (since it doesn't support those features)
  if BROWSER == Browser.IE
    fullscreenBtn.disable()

  # Set mute button
  muteBtn = new Elements.DOMButton('muted', config.spriteNames.MUTED, SHEET)
    .setRight(btnSpacing).setBottom(btnSpacing*2 + fullscreenBtn.h)
  muteBtn.addState('unmuted', config.spriteNames.UNMUTED)
  muteBtn.setClickHandler ->
    if bgmusic.getMute()
      bgmusic.setMute(false)
      muteBtn.setState('unmuted')
    else
      bgmusic.setMute(true)
      muteBtn.setState('muted')

  # Set feedback button
  feedbackBtn = new Elements.DOMButton('feedback',
    config.spriteNames.FEEDBACK, SHEET).setRight(btnSpacing*2 + fullscreenBtn.w)
    .setBottom(btnSpacing)
  feedbackBtn.setClickHandler ->
    feedback.jqmShow()


  ##################################################################################
  # Set event handlers

  window.onresize = ->
    # console.log("New Size: #{window.innerWidth} x #{window.innerHeight}")
    updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas)

    if screen.height > bgCanvas.height or screen.width > bgCanvas.width
      bgCanvas.height = screen.height
      bgCanvas.width = screen.width
      drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)
      surface.style.width = screen.width + 'px'
      surface.style.height = screen.height + 'px'
    if not document.mozFullScreenElement and
        not document.webkitFullScreenElement and
        not document.fullScreenElement
      # sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)
      fullscreenBtn.setState('fullscreen')

    bgCanvas.style.left = (0.5+(canvas.width - bgCanvas.width)/2) << 0 + "px"
    bgCanvas.style.top = (0.5+(canvas.height - bgCanvas.height)/2) << 0 + "px"

    # msgBox.draw(hudCtx)
    frameElement.resize()
    frameElement.setDirty()
    frameElement.drawChildren()
    cameraHudFrame.resize()

    # console.log("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

  document.body.addEventListener('keydown', (e) ->
    if e.keyCode == KeyCodes.HOME
      camera.setTarget(CurrentMission.getHomeTarget())
    else if e.keyCode == KeyCodes.SPACE
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
  )

  # Catch accidental leaving
  window.onbeforeunload = (e) ->
    # No progress can be lost in the menu
    if (not (CurrentMission instanceof Menu))
      if (not e)
        e = window.event
      e.cancelBubble = true
      e.returnValue = "Progress my be lost, are you sure you want to leave?"
      if (e.stopPropagation)
        e.stopPropagation()
        e.preventDefault()

  prevPos = {x: 0, y: 0}
  drag = false

  # hudCanvas.addEventListener('mousemove', (e) ->
  surface.addEventListener('mousemove', (e) ->
    x = e.clientX
    y = e.clientY
    UI.onMouseMove(x, y)
    CurrentMission.onMouseMove(x, y)
    pointer = frameElement.mouseMove(x, y)#msgBox.mouseMove(x, y)
    if pointer is null
      # Nothing on HUD frame is being hovered over
      pointer = cameraHudFrame.mouseMove(x, y)
      if pointer is null
        pointer = gameFrame.mouseMove(x, y)
      else
        gameFrame.mouseOut()
    else
      # Something on HUD frame is being hovered over, mouse out of other frames
      gameFrame.mouseOut()
      cameraHudFrame.mouseOut()
    if pointer isnt null
      # hudCanvas.style.cursor = pointer
      surface.style.cursor = pointer
    else
      # hudCanvas.style.cursor = 'auto'
      surface.style.cursor = 'auto'
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
  # hudCanvas.addEventListener('click', (e) ->
  surface.addEventListener('click', (e) ->
    UI.onMouseClick(e.clientX, e.clientY)
    # if msgBox.containsPoint(e.clientX, e.clientY)
    # msgBox.click(e.clientX, e.clientY)
    x = e.clientX
    y = e.clientY
    if frameElement.click(x, y)
      frameElement.mouseMove(x, y)
    else if cameraHudFrame.click(x, y)
      cameraHudFrame.mouseMove(x, y)
    else if gameFrame.click(x, y)
      gameFrame.mouseMove(x, y)

    CurrentMission.onMouseClick(e.clientX, e.clientY)
  )

  # hudCanvas.addEventListener('mousedown', (e) ->
  surface.addEventListener('mousedown', (e) ->
    if not frameElement.mouseDown(e.clientX, e.clientY) and
        not cameraHudFrame.mouseDown(e.clientX, e.clientY)
      drag = true
      prevPos = {x: e.clientX, y: e.clientY}
      gameFrame.mouseDown(e.clientX, e.clientY)
  )

  # hudCanvas.addEventListener('mouseup', (e) ->
  surface.addEventListener('mouseup', (e) ->
    drag = false
    frameElement.mouseUp()
    cameraHudFrame.mouseUp()
    gameFrame.mouseUp()
  )

  # hudCanvas.addEventListener('mouseout', (e) ->
  surface.addEventListener('mouseout', (e) ->
    # frameElement.mouseOut()
    # cameraHudFrame.mouseOut()
    # gameFrame.mouseOut()
    drag = false)

  mouseWheelHandler = (e) ->
    delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
    nz = camera.zoom + delta * window.config.ZOOM_SPEED
    camera.setZoom(nz)

  document.body.addEventListener('DOMMouseScroll', mouseWheelHandler)

  document.body.addEventListener('mousewheel', mouseWheelHandler)


  ##################################################################################
  # Draw loop

  draw = ->
    ctx.clearRect(0, 0, camera.width, camera.height)
    tooltipCtx.clearRect(0, 0, camera.width, camera.height)
    UI.draw(ctx, hudCtx)
    CurrentMission.draw(ctx, hudCtx)
    cameraHudFrame.drawChildren()
    frameElement.drawChildren()
    gameFrame.drawChildren()
    bgCanvas.style.left = Math.floor(camera.x /
      window.config.BG_PAN_SPEED_FACTOR - camera.width/2) + "px"
    bgCanvas.style.top = Math.floor(camera.y /
      window.config.BG_PAN_SPEED_FACTOR - camera.height/2) + "px"
    camera.update()

    # Don't forget to update the animation
    AnimatedSprite.drawCounter++

  # Only call draw once if testing
  if TESTING
    draw()
  else
    setInterval draw, 30
