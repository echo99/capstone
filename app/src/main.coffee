# The main script for the game

#_require util/SpriteSheet
#_require util/AtlasParser

# WIDTH = 720
# HEIGHT = 500
WIDTH = 600
HEIGHT = 400


# console.log("5/2: " + (5/2))
# console.log("5*0.5: " + (5 * 0.5))

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


# Execute after document is loaded
$ ->
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
  
  bgCtx.fillStyle = "rgb(0,0,0)"
  bgCtx.fillRect(0,0,WIDTH,HEIGHT)
  # ctx.fillStyle = "rgb(255,0,0)"
  # ctx.fillRect(20,20,30,30)
  # ctx.fillRect(100,100,30,30)

  # onGetJson = (data) ->
  #   alert(data)
  #   jsonData = JSON.parse(data.response)
  #   alert(jsonData)
  #   sheet = new SpriteSheet('assets/images/atlas.png')
  #   as = new AtlasParser(sheet, jsonData)
  #   as.parseDataToSheet
  #   sheet.drawSprite('starry_background.png', 0, 0, ctx)

  sheet = null

  onGetJson = (data) ->
    sheet = new SpriteSheet('assets/images/atlas.png')
    onLoadImage = ->
      as = new AtlasParser(sheet, data)
      as.parseDataToSheet()
      halfCanWidth = Math.floor(canvas.width/2);
      halfCanHeight = Math.floor(canvas.height/2);

      drawBackground(bgCtx, sheet, 'starry_background.png')


      # sheet.drawSprite('starry_background.png', canvas.width/2, canvas.height/2, bgCtx)

      # xPos = 300
      # yPos = 300

      # sheet.drawSprite('planet_blue_1.png', xPos, yPos, bgCtx, 2)
      # sheet.drawSprite('station_gathering.png', xPos, yPos, bgCtx, 2)
      # sheet.drawSprite('building_attack_ship.png', xPos, yPos, bgCtx, 2)
      # sheet.drawSprite('starry_background.png', canvas.width/2, canvas.height/2, ctx)
    sheet.loadImage(onLoadImage)
    
  $.getJSON('assets/images/atlas.json', {}, onGetJson)


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

    bgCanvas.style.left = Math.floor((canvas.width - bgCanvas.width)/2) + "px"
    bgCanvas.style.top = Math.floor((canvas.height - bgCanvas.height)/2) + "px"

    console.log("New bg pos: #{bgCanvas.left} x #{bgCanvas.top}")

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

  ships = [
      orbitRadius: 200
      angularVelocity: Math.PI / 150
      sptName: 'colony_ship.png'
      angle: 0
      orientation: 'right'
    ,
      orbitRadius: 120
      angularVelocity: Math.PI / 90
      sptName: 'attack_ship.png'
      angle: Math.PI
      orientation: 'up'
    ,
      orbitRadius: 100
      angularVelocity: Math.PI / 90
      sptName: 'defense_ship.png'
      angle: 0
      orientation: 'up'
    ,
      orbitRadius: 300
      angularVelocity: Math.PI / 300
      sptName: 'probe.png'
      angle: 0
      orientation: 'right'
  ]

  draw = ->
    # ctx.fillStyle = "rgb(0,0,0)"
    # ctx.fillRect(box.x-box.radius,box.y-box.radius,box.diameter,box.diameter)
    # ctx.clearRect(box.x-box.radius,box.y-box.radius,box.diameter,box.diameter)
    ctx.clearRect(0,0,canvas.width,canvas.height)
    # ctx.fillRect(0,0,canvas.width,canvas.height)
    # ctx.fillStyle = "rgb(255,0,0)"
    # box.angle+=0.2
    # # box.x++
    # # if box.x > 256
    # #   box.x = 0
    # # save the context
    # ctx.save()
    # # translate it to the boxes x and boxes y, basically your taking the canvas
    # # and moving it to each box.
    # ctx.translate(box.x, box.y)
    # #ctx.scale(2,2)
    # # now rotate it
    # ctx.rotate(box.angle)
    # # -5 is half of the box width and height 0,0 is the boxes location,
    # # im drawing it at half the width and height to set the rotation origin to
    # # the center of the box.
    # ctx.fillRect(-box.halfwidth,-box.halfheight, box.w, box.h)
    # # now restore
    # ctx.restore()

    if sheet != null
      ctx.save()
      ctx.translate(box.x, box.y)
      sheet.drawSprite('planet_blue_2.png', 0, 0, ctx, 2)
      lastAngle = 0
      for ship in ships
        ship.angle += ship.angularVelocity
        ctx.rotate(ship.angle-lastAngle)
        if ship.orientation == 'up'
          sheet.drawSprite(ship.sptName, -ship.orbitRadius, 0, ctx)
        else
          sheet.drawSprite(ship.sptName, 0, -ship.orbitRadius, ctx)
        lastAngle = ship.angle
      ctx.restore()
      sheet.drawSprite('title.png', box.x, 100, ctx)

  # Animate
  setInterval draw, 30