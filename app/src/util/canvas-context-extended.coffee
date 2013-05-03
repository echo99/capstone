
# Set the font of the canvas context
#
# @param [Object] font
# @option font [String] style
# @option font [String] weight
# @option font [Number] sizeVal Integral size of font
# @option font [String] unit Unit for font size
# @option font [String] family
CanvasRenderingContext2D::setFont = (font) ->
  {style, weight, sizeVal, unit, family} = font
  @fontStyle = style if style?
  @fontWeight = weigth if weight?
  # @fontSize = size if size?
  @fontSizeVal = sizeVal if sizeVal?
  @fontUnit = unit if unit?
  @fontFamily = family if family?

  @fontSizeVal ?= 10
  @fontUnit ?= "px"
  @fontFamily ?= "sans-serif"
  @_setFont()

  # style="italic",weight="bold",size="10px",family="sans-serif"

# @private Sets the canvas context's font
CanvasRenderingContext2D::_setFont = ->
  fontStr = ""
  if @fontStyle?
    fontStr += @fontStyle + " "
  if @fontWeight?
    fontStr += @fontWeight + " "
  fontStr += @fontSizeVal + @fontUnit + " " + @fontFamily
  @font = fontStr

# Get the font style
CanvasRenderingContext2D::getFontStyle = ->
  return @fontStyle if @fontStyle? else null

# Get the font weight
CanvasRenderingContext2D::getFontWeight = ->
  return @fontWeight if @fontWeight? else null

# Get the font size value
CanvasRenderingContext2D::getFontSizeVal = ->
  return @fontSizeVal if @fontSizeVal? else null

# Get the font size unit
CanvasRenderingContext2D::getFontUnit = ->
  return @fontUnit if @fontUnit? else null

# Get the font family
CanvasRenderingContext2D::getFontFamily = ->
  return @fontFamily if @fontFamily? else null

# Set the font style
CanvasRenderingContext2D::setFontStyle = (@fontStyle) ->
  @_setFont()

# Set the font weight
CanvasRenderingContext2D::setFontWeight = (@fontWeight) ->
  @_setFont()

# Set the font size value
CanvasRenderingContext2D::setFontSizeVal = (@fontSizeVal) ->
  @_setFont()

# Set the font size unit
CanvasRenderingContext2D::setFontUnit = (@fontUnit) ->
  @_setFont()

# Set the font family
CanvasRenderingContext2D::setFontFamily = (@setFontFamily) ->
  @_setFont()
