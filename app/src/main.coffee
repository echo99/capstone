# The main script for the game
WIDTH = 600
HEIGHT = 400

# Execute after document is loaded
$ ->
  canvas = document.getElementById('canvas')
  ctx = canvas.getContext('2d')
  ctx.fillStyle = "rgb(0,0,0)"
  ctx.fillRect(0,0,WIDTH,HEIGHT)
  ctx.fillStyle = "rgb(255,0,0)"
  ctx.fillRect(20,20,30,30)
  ctx.fillRect(100,100,30,30)


  # Some fun messing around with fullscreen
  # maxWidth = 0
  # maxHeight = 0
  # updatedSize = false
  # unfullscreen = ->
  #   if document.mozFullScreenElement
  #     console.log('yeah!')
  #     # canvas.width = window.innerWidth
  #     # canvas.height = window.innerHeight + 155
  #     # canvas.width = window.screen.availWidth
  #     # canvas.height = window.screen.availHeight
  #     ctx.fillStyle = "rgb(255,0,0)"
  #     ctx.fillRect(20,20,30,30)
  #     ctx.fillRect(100,100,30,30)  
  #   else
  #     console.log('no!')
  #     canvas.width = WIDTH
  #     canvas.height = HEIGHT
  #     ctx.fillStyle = "rgb(0,0,0)"
  #     ctx.fillRect(0,0,WIDTH,HEIGHT)
  #     ctx.fillStyle = "rgb(255,0,0)"
  #     ctx.fillRect(20,20,30,30)
  #     ctx.fillRect(100,100,30,30)  
  # #document.addEventListener('webkitfullscreenchange mozfullscreenchange fullscreenchange', unfullscreen)
  # document.addEventListener('mozfullscreenchange', unfullscreen)
  # fullscreen = -> 
  #   # eheight: 619 -> 774 (diff of 155)
  #   if document.mozFullScreenElement
  #     # if not updatedSize
  #     #   unfullscreen()
  #     # updateSize = true
  #     # maxWidth = window.innerWidth
  #     # maxHeight = window.innerHeight
  #     # console.log(maxWidth + ' x ' + maxHeight)
  #   else
  #     # updatedSize = false
  #     if canvas.requestFullScreen
  #       canvas.requestFullScreen()
  #     else if canvas.mozRequestFullScreen
  #       canvas.mozRequestFullScreen()
  #     else if canvas.webkitRequestFullscreen
  #       canvas.webkitRequestFullscreen()
  #     # maxWidth = window.outerWidth
  #     # maxHeight = window.outerHeight
  #     # console.log(window.screen.availWidth + ' x ' + window.screen.availHeight)
  # canvas.addEventListener('mousedown', fullscreen)
  