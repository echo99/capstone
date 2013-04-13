#_require Sprite
#_require SpriteSheet

class AtlasParser
  ###
  A utility class that parses atlas data in JSON format and adds the data into
  the corresponding sprite sheet.
  ###

  constructor: (@spritesheet, @jsonData) ->
    ###
    Create a new AtlasParser

    @param SpriteSheet spritesheet - The SpriteSheet object asoociated with the
      atlas data
    @param JSONObject jsonData - The atlas data in JSON format
    ###

  parseDataToSheet: ->
    ###
    Parse the atlas data attached to this AtlasParser and send it to the
    attached spritesheet
    ###
    sheet = @spritesheet
    frames = @jsonData.frames
    for spriteName, spriteData of frames
      frame = spriteData.frame
      sptSrcSize = spriteData.spriteSourceSize
      srcSize = spriteData.sourceSize
      cx = 0
      cy = 0
      if sptSrcSize.w == srcSize.w and sptSrcSize.h == srcSize.h
        # Sprite was not trimmed
        cx = - frame.w / 2 # should we round it to an int?
        cy = - frame.h / 2
      else
        # Sprite was trimmed
        cx = sptSrcSize.x - (srcSize.w / 2)
        cy = sptSrcSize.y - (srcSize.h / 2)
      sprite = new Sprite(spriteName, frame.x, frame.y, frame.w, frame.h,
        cx, cy)
      sheet.addSprite(sprite)

