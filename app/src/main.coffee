# The main script for the game
WIDTH = 600
HEIGHT = 400

# Execute after document is loaded
$ ->
  canvas = document.getElementById('canvas')
  ctx = canvas.getContext('2d')
  ctx.fillStyle = "rgb(0,0,0)";
  ctx.fillRect(0,0,WIDTH,HEIGHT)