#_require UnitSelection

# This class is resposible for drawing the game state and handling user
# input related to the game directly.
class UserInterface
  planetButtons: []
  hoveredPlanetButton: null
  lastMousePos: {x: 0, y: 0}
  unitSelection: null

  # Creates a new UserInterface
  constructor: () ->
    @unitSelection = new UnitSelection()

  initialize: (onlyProbe=false) ->
    @planetButtons = []
    for p in game.getPlanets()
      pos = p.location()
      r = window.config.planetRadius
      b = new Elements.RadialButton(pos.x, pos.y, r, @planetButtonCallback(p))
      b.setHoverHandler(@planetButtonHoverCallback(p))
      gameFrame.addChild(b)
      @planetButtons.push(b)
    @unitSelection.initialize(onlyProbe)

  planetButtonCallback: (planet) =>
    return () =>
      console.log(planet._x + ", " + planet._y)
      if @unitSelection.total > 0
        console.log("moving units")
      else
        console.log("not moving units")

  planetButtonHoverCallback: (planet) =>
    return () =>
      console.log(planet._x + ", " + planet._y)
      console.log("hover")

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
    #  @drawPlanetStructure(ctx, p)
    #  @drawPlanetUnits(ctx, p)
    @unitSelection.draw(ctx, hudCtx)

    # Draw stuff attached to the game frame
    gameFrame.drawChildren()

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
      if @unitSelection.total > 0
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
    #   set button to not hover
    @hoveredPlanetButton = null
    # for each button
    for b in @planetButtons
    #   if (x, y) on button
      pos = camera.getWorldCoordinates({x: x, y: y})
      if b.containsPoint(pos.x, pos.y)
        @hoveredPlanetButton = b
    #     set button to hover
    @unitSelection.onMouseMove(x, y)

  # The UI expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->
    # for each button
    #   if button is hovered over
    #     perform button action
#    pos = camera.getWorldCoordinates({x: x, y: y})
#    if @hoveredPlanetButton and
#       @hoveredPlanetButton.containsPoint(pos.x, pos.y)
    @unitSelection.onMouseClick(x, y)