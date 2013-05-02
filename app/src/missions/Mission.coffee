# The Mission class defines a guarenteed layout for each mission. It also
# defines behavior that is common between or frequently used by missions.
class Mission
  #@todo include methods/fields for displaying an end-game screen so that
  #      it can be shared between all the missions that use it.

  # Creates a new mission and sets it up. This should not need to be
  # overwitten.
  constructor: ->
    @reset()

  # Removes any Elements that were created and does any other cleanup that might
  # need to be done before the mission is left.
  destroy: ->

  # Does all the setup that the mission needs. Creating planets, placing
  # initial units and fungus, etc.
  reset: ->

  # Draws all the mission specfic things
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->

  # The mission expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->

  # The mission expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->

  # The mission expects this to be called after the end of a turn
  onEndTurn: ->