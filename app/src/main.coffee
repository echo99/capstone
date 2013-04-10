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
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  bgCanvas.width = window.innerWidth
  bgCanvas.height = window.innerHeight
  bgCtx = bgCanvas.getContext('2d')
  ctx = canvas.getContext('2d')
  
  bgCtx.fillStyle = "rgb(0,0,0)"
  bgCtx.fillRect(0,0,WIDTH,HEIGHT)
  # ctx.fillStyle = "rgb(255,0,0)"
  # ctx.fillRect(20,20,30,30)
  # ctx.fillRect(100,100,30,30)

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

  draw = ->
    # ctx.fillStyle = "rgb(0,0,0)"
    # ctx.fillRect(box.x-box.radius,box.y-box.radius,box.diameter,box.diameter)
    ctx.clearRect(box.x-box.radius,box.y-box.radius,box.diameter,box.diameter)
    # ctx.fillRect(0,0,canvas.width,canvas.height)
    ctx.fillStyle = "rgb(255,0,0)"
    box.angle+=0.2
    # box.x++
    # if box.x > 256
    #   box.x = 0
    # save the context
    ctx.save()
    # translate it to the boxes x and boxes y, basically your taking the canvas
    # and moving it to each box.
    ctx.translate(box.x, box.y)
    #ctx.scale(2,2)
    # now rotate it
    ctx.rotate(box.angle)
    # -5 is half of the box width and height 0,0 is the boxes location,
    # im drawing it at half the width and height to set the rotation origin to
    # the center of the box.
    ctx.fillRect(-box.halfwidth,-box.halfheight, box.w, box.h)
    # now restore
    ctx.restore()

  # Animate box
  ctx.fillStyle = "rgb(255,0,0)"
  setInterval draw, 30

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
  updatedSize = false
  redrawfullscreenchange = ->
    if document.mozFullScreenElement or document.webkitFullScreenElement
      #console.log('yeah!')
      # canvas.width = window.innerWidth
      # canvas.height = window.innerHeight + 155
      # canvas.width = window.screen.availWidth
      # canvas.height = window.screen.availHeight
      frame.width = screen.width
      frame.height = screen.height
      canvas.width = screen.width
      canvas.height = screen.height
      bgCanvas.width = screen.width
      bgCanvas.height = screen.height

      drawBackground(bgCtx, sheet, 'starry_background.png')

      box.x = canvas.width/2
      box.y = canvas.height/2
      # ctx.fillStyle = "rgb(0,0,0)"
      # ctx.fillRect(0,0,canvas.width,canvas.height)
      # ctx.fillRect(20,20,30,30)
      # ctx.fillRect(100,100,30,30)
      # ctx.fillRect(canvas.width-50,canvas.height-50,30,30)
    else
      #console.log('no!')
      # canvas.width = WIDTH
      # canvas.height = HEIGHT

      #console.log("#{window.innerWidth} x #{window.innerHeight}")

      # This is kind of buggy. Sometimes does not properly reset dimensions to
      # browser viewport
      frame.width = window.innerWidth
      frame.height = window.innerHeight
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      bgCanvas.width = window.innerWidth
      bgCanvas.height = window.innerHeight

      drawBackground(bgCtx, sheet, 'starry_background.png')


      box.x = canvas.width/2
      box.y = canvas.height/2
      # ctx.fillStyle = "rgb(0,0,0)"
      # ctx.fillRect(0,0,canvas.width,canvas.height)
      # ctx.fillStyle = "rgb(255,0,0)"
      # ctx.fillRect(20,20,30,30)
      # ctx.fillRect(100,100,30,30)
  #document.addEventListener('webkitfullscreenchange mozfullscreenchange '
  #  +'fullscreenchange', unfullscreen)
  document.addEventListener('mozfullscreenchange', redrawfullscreenchange)
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