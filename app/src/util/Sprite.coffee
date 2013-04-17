# A simple sprite class for keeping track of a sprite's properties
#
class Sprite

  # Create a new sprite
  #
  # @param [String] name Name of sprite
  # @param [Number] x x-location of sprite on sprite sheet
  # @param [Number] y y-location of sprite on sprite sheet
  # @param [Number] w Width of sprite
  # @param [Number] h Height of sprite
  # @param [Number] cx Center x-offset
  # @param [Number] cy Center y-offset
  #
  constructor: (@name, @x, @y, @w, @h, @cx, @cy) ->


class AnimatedSprite
  @drawCounter: 0
  prevCounter: -1
  currentFrame: 0

  # Create a new animated sprite
  #
  # @param [Array<Sprite>] sprites
  # @param [Number] interval (Optional)
  #
  constructor: (@sprites, @interval = 1) ->

  # Returns the sprite of the current frame while also incrementing it
  #
  # @return [Sprite]
  #
  getCurrentFrame: ->
    if @prevCounter != AnimatedSprite.drawCounter
      @prevCounter = AnimatedSprite.drawCounter
      if AnimatedSprite.drawCounter % @interval == 0
        @currentFrame = (@currentFrame + 1) % @sprites.length
    return @sprites[@currentFrame]
