#_require Sprite

# A class for handling atlases and sprite sheets
#
class SpriteSheet
  img: null
  sprites: {}

  # Create a new SpriteSheet
  #
  # @param [String] path Path to sprite sheet image
  #
  constructor: (@path) ->

  # Load the image from path, executing the callback function when done
  #
  # @param [Function] callback Function to call once image is loaded
  #
  loadImage: (callback) ->
    @_loadAtlasImage(callback)

  # Do the actual image loading (is this abstraction even needed?)
  #
  # @param [Function] callback Function to call once image is loaded
  #
  # @private
  _loadAtlasImage: (callback) ->
    @img = new Image()
    @img.onload = callback
    @img.src = @path

  # Add a sprite definition to the sprite sheet
  #
  # @param [Sprite] sprite Sprite object to add
  #
  addSprite: (sprite) ->
    name = sprite.name
    if name of @sprites
      console.warn("Overwritting existing sprite: #{name}")
    @sprites[name] = sprite

  # Returns the sprite with the given name from the sprite sheet if it exists
  #
  # @param [AnimatedSprite] animName Name of sprite
  # @return [Sprite] sprite, if found, else null
  #
  getSprite: (animName) ->
    name = animName.getCurrentFrame()
    return if name of @sprites then @sprites[name] else null

  # Draws the specified sprite to the canvas context
  #
  # @param [AnimatedSprite] animName Name of sprite
  # @param [Number] x x-position to draw sprite
  # @param [Number] y y-position to draw sprite
  # @param [CanvasRenderingContext2D] ctx - Context to draw on
  # @param [Boolean] useCamera Whether to transform the sprite by the camera
  # @param [Number] scale (Optional) Scale to draw sprite at
  #
  drawSprite: (animName, x, y, ctx, useCamera=true, scale=1) ->
    name = animName.getCurrentFrame()
    if name of @sprites
      sprite = @sprites[name]
      # ctx.drawImage(@img, sprite.x, sprite.y, sprite.w, sprite.h,
      #   x + sprite.cx, y + sprite.cy, sprite.y, sprite.h)
      # console.log("Drawing image '#{name}' at (#{x}, #{y})")
      # console.log("Sprite: #{sprite.x}, #{sprite.y}, "
      #   + "#{sprite.w}, #{sprite.h}")
      # console.log("        #{sprite.cx}, #{sprite.cy}")

      # sprite.draw(@img, x, y, ctx)
      if useCamera
        trans = camera.getScreenCoordinates({x: x, y: y})
        x = (0.5 + trans.x) << 0
        y = (0.5 + trans.y) << 0
        scale = camera.zoom
        # TODO: change bound check so it checks for sprite collision with
        #       the camera rectangle, not whether the center collides
        if camera.onScreen(trans)
          ctx.drawImage(@img, sprite.x, sprite.y, sprite.w, sprite.h,
              x + sprite.cx*scale, y + sprite.cy*scale, sprite.w*scale,
              sprite.h*scale)
      else
        ctx.drawImage(@img, sprite.x, sprite.y, sprite.w, sprite.h,
            x + sprite.cx*scale, y + sprite.cy*scale, sprite.w*scale,
            sprite.h*scale)
    else
      console.error("No sprite by name of #{name}")
