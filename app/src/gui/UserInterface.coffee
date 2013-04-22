# This class is resposible for drawing the game state and handling user
# input related to the game directly.
class UserInterface
  @planetButtons: []
  @hoveredPlanetButton: null
  @lastMousePos: {x: 0, y: 0}

  # Creates a new UserInterface
  constructor: () ->

  initialize: () ->
    @planetButtons = []
    for p in game.getPlanets()
      pos = p.location()
      r = window.config.planetRadius
      el = new Elements.RadialElement(pos.x, pos.y, r)
      #b = new Elements.Button(-r, -r, r*2, r*2, @planetButtonCallback)
      #el.addChild(b)
      @planetButtons.push(el)

  planetButtonCallback: () ->
    console.log('click')

  # Draws the game and HUD
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->
    # Note: there are alot of things that need to check for hovering and many
    #       of which draw tool tips if they are
    # visited planets = set
    visited = []
    # for each planet
    ctx.strokeStyle = window.config.connectionStyle.normal.stroke
    ctx.lineWidth = window.config.connectionStyle.normal.lineWidth
    for p in game.getPlanets()
      pos = camera.getScreenCoordinates(p.location())
    #   add this planet to visited planets
      visited.push(p)
    #   for each neighbor
      for neighbor in p._adjacentPlanets
    #     if neighbor is not in visited planets
        if neighbor not in visited
    #       draw connection to the neighbor
          nPos = camera.getScreenCoordinates(neighbor.location())
          ctx.beginPath()
          ctx.moveTo(pos.x, pos.y)
          ctx.lineTo(nPos.x, nPos.y)
          ctx.stroke()

    # for each planet
    for p in game._planets
    #   draw planet
      SHEET.drawSprite(SpriteNames.PLANET_BLUE, p._x, p._y, ctx)
    #   if structure
    #     draw structure
    #   if units
      if p._probes > 0
    #     draw units
        SHEET.drawSprite(SpriteNames.PROBE, p._x+100, p._y-50, ctx)
    #   for each control group
    #     if control group is hovered over
    #       draw expanded view
    #     else
    #       draw unexpanded view
    #
    # If all planets are off screen
    #   draw text in middle of screen that says something like:
    #   "Pres HOME to return to map"
    #
    # draw HUD
    #
    # for each button
    #   if button is visible (certian buttons aren't always visible)
    #     if button is hovered over
    #       draw hover image
    #     else
    #       draw regular image
    if @hoveredPlanetButton
    # if the button is a planet
      ctx.strokeStyle = window.config.selectionStyle.stroke
      ctx.lineWidth = window.config.selectionStyle.lineWidth
      x = @hoveredPlanetButton.x
      y = @hoveredPlanetButton.y
      pos = camera.getScreenCoordinates({x: x, y: y})
      r = (window.config.planetRadius + window.config.selectionStyle.radius) *
          camera.getZoom()
      ctx.beginPath()
      ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
      ctx.stroke()
    # if there are selected units
      ctx.textAlign = "left"
      ctx.font = window.config.toolTipStyle.font
      ctx.fillStyle = window.config.toolTipStyle.color
      x = @lastMousePos.x + window.config.toolTipStyle.xOffset
      y = @lastMousePos.y + window.config.toolTipStyle.yOffset
      ctx.fillText("Move selected units", x, y)

  # The UI expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->
    @lastMousePos = {x: x, y: y}
    # for each button
    for b in @planetButtons
    #   set button to not hover
    #   if (x, y) on button
      pos = camera.getWorldCoordinates({x: x, y: y})
      if b.containsPoint(pos.x, pos.y)
        @hoveredPlanetButton = b
        return
    #     set button to hover
    @hoveredPlanetButton = null

  # The UI expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->
    # for each button
    #   if button is hovered over
    #     perform button action
    pos = camera.getWorldCoordinates({x: x, y: y})
    if @hoveredPlanetButton and
       @hoveredPlanetButton.containsPoint(pos.x, pos.y)
      console.log("clicked planet")