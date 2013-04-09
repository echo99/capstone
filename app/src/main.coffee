# The main script for the game
WIDTH = 600
HEIGHT = 400

# Execute after document is loaded
$ ->
  canvas = document.getElementById('canvas')
  ctx = canvas.getContext('2d')
  ctx.fillStyle = "rgb(0,0,0)"
  ctx.fillRect(0,0,WIDTH,HEIGHT)
  # ctx.fillStyle = "rgb(255,0,0)"
  # ctx.fillRect(20,20,30,30)
  # ctx.fillRect(100,100,30,30)

  box =
    x: WIDTH/2
    y: HEIGHT/2
    w: 40
    h: 40
    halfwidth: 20
    halfheight: 20
    radius: Math.ceil(20*1.5)
    diameter: Math.ceil(40*1.5)
    angle: 2

  draw = ->
    ctx.fillStyle = "rgb(0,0,0)"
    ctx.fillRect(box.x-box.radius,box.y-box.radius,box.diameter,box.diameter)
    # ctx.fillRect(0,0,canvas.width,canvas.height)
    ctx.fillStyle = "rgb(255,0,0)"
    box.angle+=0.2
    # box.x++
    # if box.x > 256
    #   box.x = 0
    # save the context
    ctx.save()
    # translate it to the boxes x and boxes y, basically your taking the canvas and moving it to each box.
    ctx.translate(box.x, box.y);
    #ctx.scale(2,2);
    # now rotate it
    ctx.rotate(box.angle);
    # -5 is half of the box width and height 0,0 is the boxes location, im drawing it at half the width and height to set the rotation origin to the center of the box.
    ctx.fillRect(-box.halfwidth,-box.halfheight, box.w, box.h); 
    # now restore
    ctx.restore();

  # Animate box
  setInterval draw, 30


  # Some fun messing around with fullscreen
  maxWidth = 0
  maxHeight = 0
  updatedSize = false
  redrawfullscreenchange = ->
    if document.mozFullScreenElement
      console.log('yeah!')
      # canvas.width = window.innerWidth
      # canvas.height = window.innerHeight + 155
      # canvas.width = window.screen.availWidth
      # canvas.height = window.screen.availHeight
      canvas.width = screen.width
      canvas.height = screen.height
      box.x = canvas.width/2
      box.y = canvas.height/2
      ctx.fillStyle = "rgb(0,0,0)"
      ctx.fillRect(0,0,canvas.width,canvas.height)
      # ctx.fillRect(20,20,30,30)
      # ctx.fillRect(100,100,30,30)
      # ctx.fillRect(canvas.width-50,canvas.height-50,30,30)
    else
      console.log('no!')
      canvas.width = WIDTH
      canvas.height = HEIGHT
      box.x = canvas.width/2
      box.y = canvas.height/2
      ctx.fillStyle = "rgb(0,0,0)"
      ctx.fillRect(0,0,canvas.width,canvas.height)
      # ctx.fillStyle = "rgb(255,0,0)"
      # ctx.fillRect(20,20,30,30)
      # ctx.fillRect(100,100,30,30)  
  #document.addEventListener('webkitfullscreenchange mozfullscreenchange fullscreenchange', unfullscreen)
  document.addEventListener('mozfullscreenchange', redrawfullscreenchange)
  canvasclick = -> 
    # eheight: 619 -> 774 (diff of 155)
    if document.mozFullScreenElement
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
      if canvas.requestFullScreen
        canvas.requestFullScreen()
      else if canvas.mozRequestFullScreen
        canvas.mozRequestFullScreen()
      else if canvas.webkitRequestFullscreen
        canvas.webkitRequestFullscreen()
      # maxWidth = window.outerWidth
      # maxHeight = window.outerHeight
      # console.log(window.screen.availWidth + ' x ' + window.screen.availHeight)
  canvas.addEventListener('mousedown', canvasclick)
  