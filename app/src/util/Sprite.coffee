class Sprite
  ###
  A simple sprite class for keeping track of a sprite's properties
  ###
  constructor: (@name, @x, @y, @w, @h, @cx, @cy) ->
    ###
    Create a new Sprite

    @param string name - Name of sprite
    @param int x - x-location of sprite on sprite sheet
    @param int y - y-location of sprite on sprite sheet
    @param int w - Width of sprite
    @param int h - Height of sprite
    @param double cx - Center x-offset
    @param double cy - Center y-offset
    ###

  draw: (img, x, y, ctx) -> 
    ctx.drawImage(img, @x, @y, @w, @h, x + @cx, y + @cy, @w, @h)


class AnimatedSprite extends Sprite
  frames: []
  currentFrame: 0

  draw: (img, x, y, ctx) ->
    curSprite = frames[currentFrame]
    curSprite.draw(img, x, y, ctx)
    currentFrame++
    if currentFrame >= frames.length
      currentFrame = 0

  getCurrentFrame: ->
    return currentFrame

