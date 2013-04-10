#_require Sprite

class SpriteSheet
  img: null
  sprites: {}

  constructor: (@path) ->
  
  loadImage: (callback) ->
    @_loadAtlasImage(callback)

  _loadAtlasImage: (callback) ->
    @img = new Image()
    @img.onload = callback
    @img.src = @path

  addSprite: (sprite) ->
    name = sprite.name
    if name of @sprites
      console.warn("Overwritting existing sprite: #{name}")
    @sprites[name] = sprite

  getSprite: (name) ->
    return if name of @sprites then @sprites[name] else null

  drawSprite: (name, x, y, ctx, scale = 1) ->
    if name of @sprites
      sprite = @sprites[name]
      # ctx.drawImage(@img, sprite.x, sprite.y, sprite.w, sprite.h,
      #   x + sprite.cx, y + sprite.cy, sprite.y, sprite.h)
      # console.log("Drawing image '#{name}' at (#{x}, #{y})")
      # console.log("Sprite: #{sprite.x}, #{sprite.y}, #{sprite.w}, #{sprite.h}")
      # console.log("        #{sprite.cx}, #{sprite.cy}")
      # ctx.scale()
      ctx.drawImage(@img, sprite.x, sprite.y, sprite.w, sprite.h,
              x + sprite.cx*scale, y + sprite.cy*scale, sprite.w*scale, sprite.h*scale)
      # ctx.drawImage(@img, 0, 0, 512, 512, 0, 0, 512, 512)
    else
      console.error("No sprite by name of #{name}")
