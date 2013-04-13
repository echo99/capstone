# The main script for the game

#_require util/SpriteSheet
#_require util/AtlasParser
#_require gui/MainMenu

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

# WIDTH = 720
# HEIGHT = 500
WIDTH = 600
HEIGHT = 400

Orientation = 
  UP: 1
  DOWN: 2
  LEFT: 3
  RIGHT: 4

SpriteNames = 
  BACKGROUND: 'starry_background.png'
  ATTACK_SHIP: 'attack_ship.png'
  DEFENSE_SHIP: 'defense_ship.png'
  COLONY_SHIP: 'colony_ship.png'
  PROBE: 'probe.png'
  PLANETS: ['planet_blue.png']
  TITLE: 'title.png'

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
      spritesheet.drawSprite(name, xPos, yPos, ctx)

main = ->
  frame = document.getElementById('frame')
  canvas = document.getElementById('canvas-fg')
  bgCanvas = document.getElementById('canvas-bg')
  frame.width = window.innerWidth
  frame.height = window.innerWidth
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  bgCanvas.width = screen.width
  bgCanvas.height = screen.height
  bgCtx = bgCanvas.getContext('2d')
  ctx = canvas.getContext('2d')

  sheet = SHEET
  if sheet == null
    # Should never get here
    console.log("Sheet not loaded!")
  else
    console.log("Sheet loaded!")
    drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)

  # xhr = new XMLHttpRequest()
  # xhr.open('GET', 'assets/images/atlas.json', false)
  # xhr.onload = (data) ->
  #   jsonData = JSON.parse(data.response)
  #   alert(jsonData)
  #   sheet = new SpriteSheet('assets/images/atlas.png')
  #   as = new AtlasParser(sheet, jsonData)
  #   as.parseDataToSheet
  #   sheet.drawSprite('starry_background.png', 0, 0, ctx)
  # xhr.send()

  # Some fun messing around with fullscreen
  maxWidth = 0
  maxHeight = 0

  canvasclick = ->
    # eheight: 619 -> 774 (diff of 155)
    if document.mozFullScreenElement or document.webkitFullScreenElement
      # Already at full screen!
      console.log "Already full screen!"
      # if not updatedSize
      #   unfullscreen()
      # updateSize = true
      # maxWidth = window.innerWidth
      # maxHeight = window.innerHeight
      # console.log(maxWidth + ' x ' + maxHeight)
    else
      console.log "Not at full screen"
      # updatedSize = false
      if frame.requestFullScreen
        frame.requestFullScreen()
      else if frame.mozRequestFullScreen
        frame.mozRequestFullScreen()
      else if frame.webkitRequestFullscreen
        frame.webkitRequestFullscreen()
      # maxWidth = window.outerWidth
      # maxHeight = window.outerHeight
      # console.log(window.screen.availWidth + ' x '
      #   + window.screen.availHeight)
  frame.addEventListener('mousedown', canvasclick)

  window.onresize = ->
    console.log("New Size: #{window.innerWidth} x #{window.innerHeight}")
    frame.width = window.innerWidth
    frame.height = window.innerHeight
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
    box.x = canvas.width/2
    box.y = canvas.height/2

    if screen.height > bgCanvas.height or screen.width > bgCanvas.width
      bgCanvas.height = screen.height
      bgCanvas.width = screen.width
      drawBackground(bgCtx, sheet, SpriteNames.BACKGROUND)

    bgCanvas.style.left = Math.floor((canvas.width - bgCanvas.width)/2) + "px"
    bgCanvas.style.top = Math.floor((canvas.height - bgCanvas.height)/2) + "px"

    console.log("New bg pos: #{bgCanvas.style.left} x #{bgCanvas.style.top}")

  box =
    x: canvas.width/2
    y: canvas.height/2
    w: 40
    h: 40
    halfwidth: 20
    halfheight: 20
    radius: Math.ceil(20*1.5)
    diameter: Math.ceil(40*1.5)
    angle: 2

  mm = MainMenu.get(ctx, sheet)
  mm.startAnim()
  # ships = [
  #     orbitRadius: 200
  #     angularVelocity: Math.PI / 150
  #     sptName: SpriteNames.COLONY_SHIP
  #     angle: 0
  #     orientation: Orientation.RIGHT
  #   ,
  #     orbitRadius: 120
  #     angularVelocity: Math.PI / 90
  #     sptName: SpriteNames.ATTACK_SHIP
  #     angle: Math.PI
  #     orientation: Orientation.UP
  #   ,
  #     orbitRadius: 100
  #     angularVelocity: Math.PI / 90
  #     sptName: SpriteNames.DEFENSE_SHIP
  #     angle: 0
  #     orientation: Orientation.UP
  #   ,
  #     orbitRadius: 300
  #     angularVelocity: Math.PI / 300
  #     sptName: SpriteNames.PROBE
  #     angle: 0
  #     orientation: Orientation.RIGHT
  # ]

  # draw = ->
  #   ctx.clearRect(0,0,canvas.width,canvas.height)

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

  # # Animate
  # setInterval draw, 30