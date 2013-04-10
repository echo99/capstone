#_require Sprite
#_require SpriteSheet

class AtlasParser
  constructor: (@spritesheet, @jsonData) ->

  parseDataToSheet: ->
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
      sprite = new Sprite(spriteName, frame.x, frame.y, frame.w, frame.h, cx, cy)
      sheet.addSprite(sprite)
