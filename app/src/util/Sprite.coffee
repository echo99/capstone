class Sprite
  ###
  # A simple sprite class for keeping track of a sprite's properties
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

class AnimatedSprite
  @drawCounter: 0
  prevCounter: -1
  currentFrame: 0

  constructor: (@sprites, @interval = 1) ->
   
  getCurrentFrame: ->
    if @prevCounter != AnimatedSprite.drawCounter
      @prevCounter = AnimatedSprite.drawCounter
      if AnimatedSprite.drawCounter % @interval == 0
        @currentFrame = (@currentFrame + 1) % @sprites.length
    return @sprites[@currentFrame]
