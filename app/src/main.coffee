# The main script for the game

#_require util/canvas-context-extended
#_require util/SpriteSheet
#_require util/AtlasParser
#_require missions/Menu
#_require gui/UserInterface
#_require util/Camera
#_require gui/uielements
#_require backend/Game
#_require util/EventRecorder

# The chance that this game will be recorded
RECORD_CHANCE = 1
# Set playback to a string holding a file name that is a recorded game
# to play that game back instead of playing the game yourself
playback = ""
###
$.getJSON('recorded_games/replay.json', {}, (data) ->
  console.log("data: ", data.file)
  playback = data.file
)
###

window.player_id = null

# Load the atlas and dom before doing anything else
IMAGE_LOADED = false
DOM_LOADED = false
soundLoaded = false

BROWSER = BrowserDetect.browser
Browser =
  CHROME: 'Chrome'
  FIREFOX: 'Firefox'
  IE: 'Explorer'

TESTING = window.TESTING?
# debug("Testing flag: " + TESTING)

# Other music:
# - assets/audio/empty_space_stage1.ogg
# - assets/audio/empty_space_stage2.ogg
manifest = [
    src: 'assets/audio/dark_space.ogg|assets/audio/dark_space.mp3'
    id: 'bgmusic3'
]

bgmusic = null
muteBtn = null

numToLoad = manifest.length
numLoaded = 0

createjs.Sound.addEventListener "loadComplete", ->
  numLoaded++
  if numLoaded >= numToLoad
    # Play music once all sounds have been loaded
    debug('Finished loading sounds!')
    bgmusic = createjs.Sound.play('bgmusic3', createjs.Sound.INTERRUPT_NONE,
      10, 0, -1, 0.5)
    soundLoaded = true
    # Enable mute button if it was already created
    if muteBtn?
      muteBtn.enable()

createjs.Sound.registerManifest(manifest)

# Load image and image data as soon as possible
SHEET = null
$.getJSON 'assets/images/atlas.json', {}, (data) ->
  SHEET = new SpriteSheet('assets/images/atlas.png')
  SHEET.loadImage ->
    as = new AtlasParser(SHEET, data)
    as.parseDataToSheet()
    IMAGE_LOADED = true
    if DOM_LOADED
      main()

# Execute after document is loaded
$ ->
  DOM_LOADED = true
  if IMAGE_LOADED
    main()

KeyCodes =
  HOME: 36  # for repositioning the camera
  SPACE: 32 # for advancing the turn
  PLUS: 187 # zoom in
  MINUS: 189 # zoom out
  ADD: 107 # zoom in
  SUB: 109 # zoom out
  STATION: 81 # select next idle station
  CHEAT: 67
  W: 87 # move camera up
  UP: 38 # move camera up
  A: 65 # move left
  LEFT: 37 # move left
  S: 83 # move down
  DOWN: 40 # move down
  D: 68 # move right
  RIGHT: 39 #move right
  U: 85 # show unit stats

cheat = false

currentTime = ->
  new Date().getTime()

getMinutes = (ms) ->
  return (ms / 1000) / 60

gameStart = null

timeSinceStart = ->
  return currentTime() - gameStart

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

stats = null

WIN7 = false

determineWin7 = ->
  debug(navigator.userAgent)
  pat = /^\S+ \((.*?)\)/
  match = navigator.userAgent.match(pat)
  osStr = match[1]
  pat = /Windows NT (\d+\.\d+)/
  match = osStr.match(pat)
  if match
    version = match[1]
    # Windows 7 is Windows NT 6.1
    if version == '6.1'
      WIN7 = true
      debug('You are using Windows 7')

determineWin7()

newMission = (mission, desc=false) ->
  if CurrentMission
    CurrentMission.destroy()
    UI.destroy()
    if UI == null
      UI = new UserInterface()
  CurrentMission = new mission(desc)
  #window.onresize()

newGame = (w, h, move=false) ->
  game = new Game(w, h, move)

endTurn = () ->
  Logger.send()
  if CurrentMission.canEndTurn()
    game.endTurn()
    UI.endTurn()
    CurrentMission.onEndTurn()

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
# @suppress (checkTypes)
updateCanvases = (frame, canvases..., width, height) ->
  frameWidth = width
  frameHeight = height
  frame.width = frameWidth
  frame.height = frameHeight
  for canvas in canvases
    canvas.width = frameWidth
    canvas.height = frameHeight
  camera.setSize(frameWidth, frameHeight)

# The main method for the game
main = ->
  seed = Math.seedrandom()
  recording = false
  if playback
    eventPlay = new EventPlayback(playback)
  else if Math.random() < RECORD_CHANCE
    window.player_id = currentTime()
    eventRec = new EventRecorder(seed, window.player_id)
    recording = true
    Math.seedrandom(seed)

  Logger.start()
  Logger.logEvent("Setting up frames")
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
  if playback
    updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas,
      eventPlay.initWidth, eventPlay.initHeight)
  else
    updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas,
      window.innerWidth, window.innerHeight)
  # we should just make the bg larger than we'll ever need it to be
  bgCanvas.width = screen.width * 2
  bgCanvas.height = screen.height * 2
  # debug(screen.width)
  surface.style.width = screen.width + 'px'
  surface.style.height = screen.height + 'px'
  # debug(topSurface.style.width)
  bgCtx = bgCanvas.getContext('2d')
  ctx = canvas.getContext('2d')
  hudCtx = hudCanvas.getContext('2d')
  tooltipCtx = tooltipCanvas.getContext('2d')

  # debug(ctx.font)
  # ctx.setFont({family: 'Arial'})
  # debug(ctx.font)
  # ctx.setFontSizeVal(20)
  # debug(ctx.font)

  # feedback = $('#comments').jqm()
  feedback = $('#comments').jqm(
    ajax: 'fbcomments.html'
    ajaxUpdate: false
    modal: true
  )
  feedbackElem = document.getElementById('comments')

  stats = $('#unit-stats').jqm(
    modal: true
    # @suppress (checkTypes)
    onShow: (hash) ->
      surface.blur()
      # hash.w.css('opacity',0.88).show()
      hash.w.show()
    # @suppress (checkTypes)
    onHide: (hash) ->
      surface.focus()
      hash.w.hide()
      hash.o.remove()
  )

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
  # nframeElement.drawChildren()
  # frameElement.addChild(new Elements.TextElement(300, 500, 160, 80,
  #   "some text here", {clickable: false, fontColor: 'rgb(100,255,255)',
  #   font: '15px sans-serif'}))
  # debug(frameElement.toString())

  # msgBox2 = new Elements.MessageBox(200, -200, 100, 100, "test")
  # msgBox2.setDefaultCloseBtn()
  # msgBox2.setZIndex(1)
  # gameFrame.addChild(msgBox2)

  # cameraHudFrame.addChild(new Elements.MessageBox(0, 0, 100, 100, "test"))

  # msgBox.addUpdateCallback ->
  #   hudCtx.clearRect(msgBox.x-3, msgBox.y-3, msgBox.w+6, msgBox.h+6)
  #   msgBox.draw(hudCtx)
  UI = new UserInterface()
  CurrentMission = newMission(Menu)#new Menu()

  sheet = SHEET
  if sheet == null
    # Should never get here
    debug("Sheet not loaded!")
  else
    debug("Sheet loaded!")
    drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)

  # Set global variables for debugging
  if DEBUG
    window.hudFrame = frameElement
    window.gameFrame = gameFrame
    window.cameraHudFrame = cameraHudFrame
    window.UI = UI
    window.CurrentMission = CurrentMission

  ##################################################################################
  # Create static buttons

  btnSpacing = config.buttonSpacing

  # Set fullscreen button
  fullscreenBtn = new Elements.DOMButton('fullscreen',
    config.spriteNames.FULL_SCREEN, SHEET).setRight(btnSpacing)
    .setBottom(btnSpacing)
  fullscreenBtn.addState('unfullscreen', config.spriteNames.UNFULL_SCREEN)
  fullscreenBtn.setClickHandler ->
    if document.mozFullScreenElement or document.webkitFullscreenElement or
        document.fullScreenElement
      debug "Already full screen!"
      if document.cancelFullScreen
        document.cancelFullScreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else if document.webkitCancelFullScreen
        document.webkitCancelFullScreen()
      # sheet.drawSprite(SpriteNames.FULL_SCREEN, 8, 8, fsCtx, false)
      Logger.logEvent("Clicked FULLSCREEN")
      fullscreenBtn.setState('fullscreen')
    else
      debug "Not at full screen"
      body = document.body
      if body.requestFullScreen
        body.requestFullScreen()
      else if body.mozRequestFullScreen
        body.mozRequestFullScreen()
      else if body.webkitRequestFullscreen
        body.webkitRequestFullscreen()
      fullscreenBtn.setState('unfullscreen')
      Logger.logEvent("Clicked UNFULLSCREEN")
      # sheet.drawSprite(SpriteNames.UNFULL_SCREEN, 8, 8, fsCtx, false)
  # Disable fullscreen button on IE (since it doesn't support those features)
  # Also disable on Windows 7 Chrome due to bug
  if BROWSER == Browser.IE or (WIN7 and BROWSER == Browser.CHROME)
    fullscreenBtn.disable()

  # Set mute button
  muteBtn = new Elements.DOMButton('muted', config.spriteNames.MUTED, SHEET)
    .setRight(btnSpacing).setBottom(btnSpacing*2 + fullscreenBtn.h)
  muteBtn.addState('unmuted', config.spriteNames.UNMUTED)
  muteBtn.setState('unmuted')
  muteBtn.setClickHandler ->
    if bgmusic.getMute()
      Logger.logEvent("Clicked UNMUTE")
      bgmusic.setMute(false)
      muteBtn.setState('unmuted')
    else
      Logger.logEvent("Clicked MUTE")
      bgmusic.setMute(true)
      muteBtn.setState('muted')
  unless soundLoaded
    muteBtn.disable()

  # Set feedback button
  feedbackBtn = new Elements.DOMButton('feedback',
    config.spriteNames.FEEDBACK, SHEET).setRight(btnSpacing*2 + fullscreenBtn.w)
    .setBottom(btnSpacing)
  feedbackBtn.setClickHandler ->
    Logger.logEvent("Clicked FEEDBACK")
    feedback.jqmShow()
    # if BROWSER == Browser.IE
    #   feedbackElem.style.display = 'inline-block'
    # try
    #   feedback.jqmShow()
    # catch e
    #   console.warn(e)

  # Fill in unit stats table
  statSprites =
    'probe-sprite':
      'prefix': 'probe'
      'sprite': SpriteNames.PROBE
      'unit': config.units.probe
    'colony-ship-sprite':
      'prefix': 'colony-ship'
      'sprite': SpriteNames.COLONY_SHIP
      'unit': config.units.colonyShip
    'attack-ship-sprite':
      'prefix': 'attack-ship'
      'sprite': SpriteNames.ATTACK_SHIP
      'unit': config.units.attackShip
    'defense-ship-sprite':
      'prefix': 'defense-ship'
      'sprite': SpriteNames.DEFENSE_SHIP
      'unit': config.units.defenseShip
    'fungus-sprite':
      'prefix': 'fungus'
      'sprite': SpriteNames.PLANET_BLUE_FUNGUS
      'unit': config.units.fungus

  for id, data of statSprites
    sptName = data['sprite']
    if sptName?
      canv = document.getElementById(id)
      spt = SHEET.getSprite(sptName)
      scale = Math.min(32 / spt.w, 32 / spt.h )
      canv.width = 32
      canv.height = 32
      SHEET.drawSprite(sptName, 16, 16, canv.getContext('2d'), false, scale)
    unit = data['unit']
    prefix = data['prefix']
    atkField = document.getElementById("#{prefix}-atk")
    atkField.appendChild(document.createTextNode("ATK: #{unit.attack*100}%"))
    defField = document.getElementById("#{prefix}-def")
    defField.appendChild(document.createTextNode("DEF: #{unit.defense*100}%"))

  # for playback mouse position drawing
  mousedown = false
  mousepos = {x: 0, y: 0}

  ##################################################################################
  # Set event handlers

  # Start with surface unfocused
  surfaceFocused = false

  onResize = ->
    if recording
      eventRec.recordEvent("onResize",
        {width: window.innerWidth, height: window.innerHeight})

    # debug("New Size: #{window.innerWidth} x #{window.innerHeight}")
    updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas,
      window.innerWidth, window.innerHeight)

    if screen.height > bgCanvas.height or screen.width > bgCanvas.width
      bgCanvas.height = screen.height
      bgCanvas.width = screen.width
      drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)
      surface.style.width = screen.width + 'px'
      surface.style.height = screen.height + 'px'
    if not document.mozFullScreenElement and
        not document.webkitFullscreenElement and
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

    # debug("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

  keyDownListener = (e) ->
    if surfaceFocused
      if recording
        eventRec.recordEvent("keyDown", {keyCode: e.keyCode})

      if CurrentMission.canPlay()
        if e.keyCode == KeyCodes.HOME
          Logger.logEvent("Pressed HOME")
          camera.setTarget(CurrentMission.getHomeTarget())
        else if e.keyCode == KeyCodes.STATION
          Logger.logEvent("Pressed Q")
          UI.gotoNextStation()
        else if e.keyCode == KeyCodes.U
          # Should probably have a button for this instead
          stats.jqmShow()

      if CurrentMission.canEndTurn()
        if e.keyCode == KeyCodes.SPACE
          Logger.logEvent("Pressed SPACE")
          endTurn()

      if CurrentMission.canMove()
        if e.keyCode == KeyCodes.PLUS or e.keyCode == KeyCodes.ADD
          Logger.logEvent("Pressed +")
          nz = camera.getZoom() + window.config.ZOOM_SPEED
          camera.setZoom(nz)
        else if e.keyCode == KeyCodes.MINUS or e.keyCode == KeyCodes.SUB
          Logger.logEvent("Pressed -")
          nz = camera.getZoom() - window.config.ZOOM_SPEED
          camera.setZoom(nz)
        else if e.keyCode == KeyCodes.W or e.keyCode == KeyCodes.UP
          Logger.logEvent("Pressed up")
          camera.moveCameraByScreenDistance(0, 20)
        else if e.keyCode == KeyCodes.A or e.keyCode == KeyCodes.LEFT
          Logger.logEvent("Pressed left")
          camera.moveCameraByScreenDistance(20, 0)
        else if e.keyCode == KeyCodes.S or e.keyCode == KeyCodes.DOWN
          Logger.logEvent("Pressed down")
          camera.moveCameraByScreenDistance(0, -20)
        else if e.keyCode == KeyCodes.D or e.keyCode == KeyCodes.RIGHT
          Logger.logEvent("Pressed right")
          camera.moveCameraByScreenDistance(-20, 0)

    else
      # Surface not focused
      if e.keyCode == KeyCodes.U
        stats.jqmHide()

    #if e.keyCode == KeyCodes.CHEAT
    #  Logger.logEvent("Pressed CHEAT")
    #  cheat = not cheat

  # Catch accidental leaving
  onBeforeUnload = (e) ->
    Logger.logEvent("Trying to leave")
    Logger.send(false)
    if eventRec
      eventRec.send(false)
    # No progress can be lost in the menu
    if (not (CurrentMission instanceof Menu))
      if (not e)
        e = window.event
      e.cancelBubble = true
      if (e.stopPropagation)
        e.stopPropagation()
        e.preventDefault()
        return "Warning: Progress my be lost."
    return null

  prevPos = {x: 0, y: 0}
  drag = false

  mouseMoveHandler = (e) ->
    if recording
      eventRec.recordEvent("mouseMove",
        {clientX: e.clientX, clientY: e.clientY})

    x = e.clientX
    y = e.clientY
    UI.onMouseMove(x, y)
    CurrentMission.onMouseMove(x, y)
    if not CurrentMission.canPlay()
      pointer = null
    else
      pointer = frameElement.mouseMove(x, y)#msgBox.mouseMove(x, y)
    if pointer is null
      # Nothing on HUD frame is being hovered over
      pointer = cameraHudFrame.mouseMove(x, y)
      if pointer is null and CurrentMission.canPlay()
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
      # debug "Difx: #{difx}, dify: #{dify}"
      # newX = camera.x + difx #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      # newY = camera.y + dify #/ window.config.PAN_SPEED_FACTOR / camera.zoom
      # camera.setPosition(newX, newY)
      prevPos = {x: x, y: y}
      camera.moveCameraByScreenDistance(difx, dify)
      # coords = camera.getWorldCoordinates({x: x, y: x})
      # camera.setPosition(coords.x, coords.y)
      # camera.setPosition(camera.x+difx/camera.zoom, camera.y+dify/camera.zoom)

    if CurrentMission.canMove()
      mousepos = {x: x, y: y}

  clickHandler = (e) ->
    if recording
      eventRec.recordEvent("click",
        {clientX: e.clientX, clientY: e.clientY})

    UI.onMouseClick(e.clientX, e.clientY)
    # if msgBox.containsPoint(e.clientX, e.clientY)
    # msgBox.click(e.clientX, e.clientY)
    x = e.clientX
    y = e.clientY
    if CurrentMission.canPlay()
      if frameElement.click(x, y)
        frameElement.mouseMove(x, y)
      else if cameraHudFrame.click(x, y)
        cameraHudFrame.mouseMove(x, y)
      else if gameFrame.click(x, y)
        gameFrame.mouseMove(x, y)
    else
      if cameraHudFrame.click(x, y)
        cameraHudFrame.mouseMove(x, y)

    CurrentMission.onMouseClick(e.clientX, e.clientY)

  mouseDownHandler = (e) ->
    # Give focus to the surface
    surface.focus()

    if recording
      eventRec.recordEvent("mouseDown",
        {clientX: e.clientX, clientY: e.clientY})

    # The order here is important
    #  - cameraHudFrame always works
    #  - the other frames only work if canPlay() is true
    #  - if no frames are pressed then the camera is draged if canMove() is true
    c = cameraHudFrame.mouseDown(e.clientX, e.clientY)

    f = false
    if not c and CurrentMission.canPlay()
      f = frameElement.mouseDown(e.clientX, e.clientY)

    g = false
    if not c and not f and CurrentMission.canPlay()
      g = gameFrame.mouseDown(e.clientX, e.clientY)

    if not c and not f and not g and CurrentMission.canMove()
      drag = true
      prevPos = {x: e.clientX, y: e.clientY}
      mousedown = true

    if e.preventDefault
      e.preventDefault()

  mouseUpHandler = (e) ->
    if recording
      eventRec.recordEvent("mouseUp", {})

    cameraHudFrame.mouseUp()

    if CurrentMission.canPlay()
      frameElement.mouseUp()
      gameFrame.mouseUp()

    if CurrentMission.canMove()
      drag = false
      mousedown = false

  mouseOutHandler = (e) ->
    if recording
      eventRec.recordEvent("mouseOut", {})

    # frameElement.mouseOut()
    # cameraHudFrame.mouseOut()
    # gameFrame.mouseOut()
    drag = false

  mouseWheelHandler = (e) ->
    if recording
      eventRec.recordEvent("mouseWheel",
        {wheelDelta: e.wheelDelta, detail: e.detail})

    if CurrentMission.canMove()
      delta = Math.max(-1, Math.min(1, (e.wheelDelta or -e.detail)))
      nz = camera.zoom + delta * window.config.ZOOM_SPEED
      camera.setZoom(nz)

  focusHandler = (e) ->
    if recording
      eventRec.recordEvent("focus", {})
    surfaceFocused = true

  blurHandler = (e) ->
    if recording
      eventRec.recordEvent("blur", {})
    surfaceFocused = false

  #window.onresize = onResize

  if playback
    eventPlay.registerEvent("onResize", (width, height) ->
      updateCanvases(frame, canvas, hudCanvas, camerahudCanvas, tooltipCanvas,
        width, height)
      frameElement.resize()
      frameElement.setDirty()
      frameElement.drawChildren()
      cameraHudFrame.resize())
    eventPlay.registerEvent("keyDown", keyDownListener)
    eventPlay.registerEvent("mouseMove", mouseMoveHandler)
    eventPlay.registerEvent("click", clickHandler)
    eventPlay.registerEvent("mouseDown", mouseDownHandler)
    eventPlay.registerEvent("mouseUp", mouseUpHandler)
    eventPlay.registerEvent("mouseOut", mouseOutHandler)
    eventPlay.registerEvent("mouseWheel", mouseWheelHandler)
    eventPlay.registerEvent("focus", focusHandler)
    eventPlay.registerEvent("blur", blurHandler)
  else
    window.onresize = onResize
    document.body.addEventListener('keydown', keyDownListener, false)
    window.onbeforeunload = onBeforeUnload
    surface.addEventListener('mousemove', mouseMoveHandler, false)
    surface.addEventListener('click', clickHandler, false)
    surface.addEventListener('mousedown', mouseDownHandler, false)
    surface.addEventListener('mouseup', mouseUpHandler, false)
    surface.addEventListener('mouseout', mouseOutHandler, false)
    surface.addEventListener('DOMMouseScroll', mouseWheelHandler, false)
    surface.addEventListener('mousewheel', mouseWheelHandler, false)
    surface.addEventListener('focus', focusHandler, false)
    surface.addEventListener('blur', blurHandler, false)

    document.body.addEventListener('touchmove',
      (e) =>
        #mouseMoveHandler(e)
        e.preventDefault()
      false
    )
    ###
    document.body.addEventListener('touchstart',
      (e) =>
        Logger.logEvent("touchstart", e)
        mouseDownHandler(e)
    )
    document.body.addEventListener('touchend', mouseUpHandler)
    ###

  ##################################################################################
  # Draw loop

  draw = ->
    ctx.clearRect(0, 0, camera.width, camera.height)
    tooltipCtx.clearRect(0, 0, camera.width, camera.height)
    UI.draw(ctx, hudCtx)
    CurrentMission.draw(ctx, hudCtx)
    cameraHudFrame.updateChildren()
    frameElement.updateChildren()
    gameFrame.updateChildren()
    cameraHudFrame.drawChildren()
    frameElement.drawChildren()
    gameFrame.drawChildren()

    if playback
      if mousedown
        tooltipCtx.fillStyle = "rgb(255, 0, 0)"
      else
        tooltipCtx.fillStyle = "rgb(0, 255, 0)"
      tooltipCtx.beginPath()
      tooltipCtx.arc(mousepos.x, mousepos.y, 3, 0, 2*Math.PI)
      tooltipCtx.fill()

      tooltipCtx.font = "13px Arial"
      tooltipCtx.fillStyle = "rgb(255, 255, 255)"
      tooltipCtx.textAlign = 'right'
      tooltipCtx.textBaseline = 'middle'
      tooltipCtx.fillText(timeSinceStart() + " ms", window.innerWidth - 5, 50)

      if eventPlay.replayDone
        tooltipCtx.font = "40px Arial"
        tooltipCtx.textAlign = 'center'
        tooltipCtx.fillText("End of recording", camera.width/2, camera.height/2)

      tooltipCtx.strokeStyle = "rgb(255, 255, 255)"
      tooltipCtx.strokeRect(0, 0, camera.width, camera.height)

      window.resizeTo(camera.width+16, camera.height+65)

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
    Logger.logEvent("Beginning draw loop")
    draw()
    setInterval draw, 30

    gameStart = currentTime()
    if playback
      setInterval eventPlay.next, 1
