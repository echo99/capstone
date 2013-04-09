#_require Sprite

class SpriteSheet
  img: null
  sprites: {}

  constructor: (@path) ->

  getSprite: (name) ->
    return if name in @sprites then @sprites[name] else null
