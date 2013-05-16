# Update the size of the frame and the canvases when the window size changes
#
# @param [Element] frame
# @param [Element] canvases
# @param [*] width
# @param [...*] height
updateCanvases = (frame, canvases, width, height) ->

###*
* @suppress {duplicate}
* @param {function(CanvasRenderingContext2D, Object=, Number=)} _drawFunc
###
Elements.UIElement::setDrawFunc = (_drawFunc) ->
