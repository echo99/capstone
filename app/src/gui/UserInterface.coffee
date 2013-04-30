#_require UnitSelection

# This class is resposible for drawing the game state and handling user
# input related to the game directly.
# TODO:
#   - End turn button
#   - Deselect all units button
#   - Menu button, with option for not displaying it because the main menu doesn't
#     need it
#   - Display number of units selected locally. This will also be a button that
#     toggles selecting all of the unit type.
#   - Display planet resources. Turn this off for main menu.
#   - Display control groups
class UserInterface
  planetButtons: []
  hoveredPlanet: null
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
      b.setMouseOutHandler(@planetButtonOutCallback)
      gameFrame.addChild(b)
      @planetButtons.push(b)
    @unitSelection.initialize(onlyProbe)
    b = new Elements.Button(5 + 73/2, camera.height + 5 - 20/2, 73, 20)
    b.hovered = false
    b.setClickHandler(() =>
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
    )
    b.setHoverHandler(() =>
      b.hovered = true
      b.setDirty()
    )
    b.setMouseOutHandler(() =>
      b.hovered = false
      b.setDirty()
    )
    b.setDrawFunc((ctx) =>
      b.y = camera.height-5-20
      if b.hovered
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_HOVER, b.x, b.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_IDLE, b.x, b.y, ctx, false)
    )
    b.setZIndex(100)
    frameElement.addChild(b)

  planetButtonCallback: (planet) =>
    return () =>
      if @unitSelection.total > 0
        for p in @unitSelection.planetsWithSelectedUnits
          console.log("moving from " +
            "(" + p.location().x + ", " + p.location().y + ")" + " to " +
            "(" + planet.location().x + ", " + planet.location().y + ")")
          p.moveShips(@unitSelection.getNumberOfAttacks(p),
                      @unitSelection.getNumberOfDefenses(p),
                      @unitSelection.getNumberOfProbes(p),
                      @unitSelection.getNumberOfColonies(p), planet)
          @unitSelection.updateSelection(p)
        @unitSelection.deselectAllUnits()
      else
        console.log("opening structure menu...")
        console.log(planet)

  planetButtonHoverCallback: (planet) =>
    return () =>
      @hoveredPlanet = planet

  planetButtonOutCallback: () =>
    @hoveredPlanet = null

  # Draws the game and HUD
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->
    # Note: there are alot of things that need to check for hovering and many
    #       of which draw tool tips if they are
    visited = []
    ctx.strokeStyle = window.config.connectionStyle.normal.stroke
    ctx.lineWidth = window.config.connectionStyle.normal.lineWidth
    for p in game.getPlanets()
      pos = camera.getScreenCoordinates(p.location())
      visited.push(p)
      for neighbor in p.getAdjacentPlanets()
        if neighbor not in visited
          # draw connection to the neighbor
          nPos = camera.getScreenCoordinates(neighbor.location())
          ctx.beginPath()
          ctx.moveTo(pos.x, pos.y)
          ctx.lineTo(nPos.x, nPos.y)
          ctx.stroke()

    for p in game.getPlanets()
      loc = p.location()
      vis = p.visibility()
      if vis == window.config.visibility.invisible
        if p.fungusStrength() > 0
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE, loc.x, loc.y, ctx)
      else
        if p.fungusStrength() > 0
          SHEET.drawSprite(SpriteNames.PLANET_BLUE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_BLUE, loc.x, loc.y, ctx)
    #  @drawPlanetStructure(ctx, p)
    #  @drawPlanetUnits(ctx, p)
    @unitSelection.draw(ctx, hudCtx)

    # # Draw stuff attached to the game frame
    # gameFrame.drawChildren()

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
    if @hoveredPlanet
      # if the button is a planet
      ctx.strokeStyle = window.config.selectionStyle.stroke
      ctx.lineWidth = window.config.selectionStyle.lineWidth
      loc = @hoveredPlanet.location()
      pos = camera.getScreenCoordinates(loc)
      r = (window.config.planetRadius + window.config.selectionStyle.radius) *
          camera.getZoom()
      ctx.beginPath()
      ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
      ctx.stroke()
      ctx.textAlign = "left"
      ctx.font = window.config.toolTipStyle.font
      ctx.fillStyle = window.config.toolTipStyle.color
      x = @lastMousePos.x + window.config.toolTipStyle.xOffset
      y = @lastMousePos.y + window.config.toolTipStyle.yOffset
      if @unitSelection.total > 0
        ctx.fillText("Move selected units", x, y)
      else
        ctx.fillText("Open structure menu", x, y)

  # The UI expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->
    @lastMousePos = {x: x, y: y}
    #@hoveredPlanetButton = null
    #for b in @planetButtons
      #pos = camera.getWorldCoordinates({x: x, y: y})
      #if b.containsPoint(pos.x, pos.y)
        #@hoveredPlanetButton = b
    @unitSelection.onMouseMove(x, y)

  # The UI expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->
    # for each button
    #   if button is hovered over
    #     perform button action
    # pos = camera.getWorldCoordinates({x: x, y: y})
    #if @hoveredPlanetButton and
    #   @hoveredPlanetButton.containsPoint(pos.x, pos.y)
    @unitSelection.onMouseClick(x, y)

  endTurn: () ->
    for p in game.getPlanets()
      @unitSelection.updateSelection(p)
