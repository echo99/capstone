#_require UnitSelection

# This class is resposible for drawing the game state and handling user
# input related to the game directly.
# TODO:
#   - Deselect all units button
#   - Menu button, with option for not displaying it because the main menu doesn't
#     need it
#   - Display number of units selected locally. This will also be a button that
#     toggles selecting all of the unit type.
#   - Display control groups
class UserInterface
  planetButtons: []
  hoveredPlanet: null
  selectedPlanet: null
  lastMousePos: {x: 0, y: 0}
  unitSelection: null
  switchedMenus: false

  # Creates a new UserInterface
  constructor: () ->
    @unitSelection = new UnitSelection()
    b = new Elements.Button(5 + 73/2, camera.height + 5 - 20/2, 73, 20)
    b.setClickHandler(() =>
      game.endTurn()
      UI.endTurn()
      CurrentMission.onEndTurn()
    )
    b.setMouseUpHandler(() =>
      b.setDirty()
    )
    b.setMouseDownHandler(() =>
      b.setDirty()
    )
    b.setMouseOutHandler(() =>
      b.setDirty()
    )
    b.setDrawFunc((ctx) =>
      b.y = camera.height-5-10
      if b.isPressed()
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_HOVER, b.x, b.y, ctx, false)
      else
        SHEET.drawSprite(SpriteNames.END_TURN_BUTTON_IDLE, b.x, b.y, ctx, false)
    )
    b.setZIndex(100)
    frameElement.addChild(b)

    @help = new Elements.MessageBox(0, 0, 300, 50,
      "Press HOME to return", {zIndex: 10})
    @help.visible = false
    cameraHudFrame.addChild(@help)

    winStyle = window.config.windowStyle
    stationStyle = window.config.stationMenuStyle
    loc = stationStyle.location
    w = stationStyle.width
    h = stationStyle.height
    @stationMenu = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @stationMenu.setDrawFunc(@_drawStationMenu)
    @stationMenu.setClearFunc(@_clearMenu(stationStyle))

    stationStyle = window.config.stationMenuStyle
    x = stationStyle.vert1x + winStyle.lineWidth
    y = winStyle.lineWidth / 2
    w = (stationStyle.vert2x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height / 2 - winStyle.lineWidth / 2) - y
    probeButton = @_getStationButton(x, y, w, h, window.config.units.probe)

    x = stationStyle.vert1x + winStyle.lineWidth
    y = stationStyle.height / 2 + winStyle.lineWidth / 2
    w = (stationStyle.vert2x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height - winStyle.lineWidth / 2) - y
    colonyButton = @_getStationButton(x, y, w, h, window.config.units.colonyShip)

    x = stationStyle.vert2x + winStyle.lineWidth / 2
    y = winStyle.lineWidth / 2
    w = (stationStyle.vert3x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height / 2 - winStyle.lineWidth / 2) - y
    attackButton = @_getStationButton(x, y, w, h, window.config.units.attackShip)

    x = stationStyle.vert2x + winStyle.lineWidth / 2
    y = stationStyle.height / 2 + winStyle.lineWidth / 2
    w = (stationStyle.vert3x - winStyle.lineWidth / 2) - x
    h = (stationStyle.height - winStyle.lineWidth / 2) - y
    defenseButton = @_getStationButton(x, y, w, h, window.config.units.defenseShip)

    @stationMenu.addChild(probeButton)
    @stationMenu.addChild(colonyButton)
    @stationMenu.addChild(attackButton)
    @stationMenu.addChild(defenseButton)
    @stationMenu.visible = false
    frameElement.addChild(@stationMenu)

    style = window.config.outpostMenuStyle
    loc = style.location
    w = style.width
    h = style.height
    @outpostMenu = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @outpostMenu.setDrawFunc(@_drawOutpostMenu)
    @outpostMenu.setClearFunc(@_clearMenu(window.config.outpostMenuStyle))
    @outpostMenu.visible = false
    frameElement.addChild(@outpostMenu)

  _getStationButton: (x, y, w, h, unit) ->
    button = new Elements.Button(x+w/2, y+h/2, w, h)
    button.setProperty("location",
      @stationMenu.getActualLocation(button.x, button.y))
    button.setClickHandler(() =>
      if @selectedPlanet.availableResources() < unit.cost
        console.log("Not making " + unit)
      else if @selectedPlanet.buildUnit() != null
        console.log("Busy, not making " + unit)
      else
        console.log("Makeing " + unit)
        @selectedPlanet.build(unit)
    )
    button.setMouseUpHandler(() =>
      button.setDirty()
    )
    button.setMouseOutHandler(() =>
      if button.isPressed()
        button.setDirty()
    )
    button.setDrawFunc((ctx) =>
      loc = button.getProperty("location")
      if @selectedPlanet.availableResources() < unit.cost
        ctx.strokeStyle = window.config.unitDisplay.red
      else if @selectedPlanet.buildUnit() != null
        ctx.strokeStyle = window.config.unitDisplay.orange
      else
        ctx.strokeStyle = window.config.unitDisplay.stroke
      ctx.lineWidth = window.config.unitDisplay.lineWidth
      ctx.lineJoin = window.config.unitDisplay.lineJoin
      x = loc.x
      y = loc.y
      w = button.w
      h = button.h
      if button.isHovered()
        ctx.strokeRect(x - w/2, y - h /2, w, h)
    )
    return button

  _clearMenu: (style) =>
    (ctx) =>
      winStyle = window.config.windowStyle
      w = style.width
      h = style.height
      ctx.clearRect(style.location.x - winStyle.lineWidth / 2 - 1,
                    style.location.y - winStyle.lineWidth / 2 - 1,
                    w + winStyle.lineWidth + 2,
                    h + winStyle.lineWidth + 2)

  _drawStationMenu: (ctx) =>
    winStyle = window.config.windowStyle
    stationStyle = window.config.stationMenuStyle
    w = stationStyle.width
    h = stationStyle.height
    loc = stationStyle.location
    @_clearMenu(stationStyle)(ctx)

    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth

    # Draw background
    ctx.fillRect(loc.x, loc.y, w, h)

    # Draw frame
    ctx.strokeRect(loc.x, loc.y, w, h)

    # Draw dividers
    ctx.beginPath()
    ctx.moveTo(loc.x, loc.y+h/2)
    ctx.lineTo(loc.x+stationStyle.horizLength, loc.y+h/2)

    ctx.moveTo(loc.x+stationStyle.vert2x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert2x, loc.y+h)

    ctx.moveTo(loc.x+stationStyle.vert3x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert3x, loc.y+h)
    ctx.stroke()

    ctx.lineWidth = winStyle.lineWidth * 2
    ctx.beginPath()
    ctx.moveTo(loc.x+stationStyle.vert1x, loc.y)
    ctx.lineTo(loc.x+stationStyle.vert1x, loc.y+h)
    ctx.stroke()

    # Draw title block
    ctx.font = winStyle.titleText.font
    ctx.fillStyle = winStyle.titleText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x+stationStyle.titleLoc.x
    y = loc.y+stationStyle.titleLoc.y
    ctx.fillText("Station", x, y)

    ctx.strokeStyle = winStyle.titleText.color
    ctx.lineWidth = winStyle.titleText.underlineWidth
    ctx.beginPath()
    ctx.moveTo(x, y + winStyle.titleText.height)
    ctx.lineTo(x + ctx.measureText("Station").width, y + winStyle.titleText.height)
    ctx.stroke()

    ctx.font = winStyle.defaultText.font
    ctx.fillStyle = winStyle.defaultText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    x = loc.x+stationStyle.availableLoc.x
    y = loc.y+stationStyle.availableLoc.y
    ctx.fillText("Resources avaliable:", x, y)

    # Draw currently buiding block
    x = loc.x+stationStyle.buildingLoc.x
    y = loc.y+stationStyle.buildingLoc.y
    ctx.fillText("Currently building:", x, y)

    # Draw unit blocks
    @_drawUnitBlock(ctx, "Probe", loc, window.config.units.probe,
                    stationStyle.probe, SpriteNames.PROBE)

    @_drawUnitBlock(ctx, "Colony Ship", loc, window.config.units.colonyShip,
                    stationStyle.colony, SpriteNames.COLONY_SHIP)

    @_drawUnitBlock(ctx, "Attack Ship", loc, window.config.units.attackShip,
                    stationStyle.attack, SpriteNames.ATTACK_SHIP)

    @_drawUnitBlock(ctx, "Defense Ship", loc, window.config.units.defenseShip,
                    stationStyle.defense, SpriteNames.DEFENSE_SHIP)

    # Draw variables
    ctx.fillStyle = winStyle.defaultText.value
    resources = @selectedPlanet.availableResources()
    x = loc.x+stationStyle.availableLoc.x +
        ctx.measureText("Resources avaliable:").width + 5
    y = loc.y+stationStyle.availableLoc.y
    ctx.fillText(resources, x, y)

    x = loc.x+stationStyle.buildingLoc.x
    y = loc.y+stationStyle.buildingLoc.y
    switch @selectedPlanet.buildUnit()
      when window.config.units.probe
        text = "Probe"
        sprite = SpriteNames.PROBE
      when window.config.units.colonyShip
        text = "Colony Ship"
        sprite = SpriteNames.COLONY_SHIP
      when window.config.units.attackShip
        text = "Attack Ship"
        sprite = SpriteNames.ATTACK_SHIP
      when window.config.units.defenseShip
        text = "Defense Ship"
        sprite = SpriteNames.DEFENSE_SHIP
      else
        text = ""
    w = ctx.measureText("Currently building:").width + 5
    ctx.fillText(text, x + w, y)
    if text != ""
      SHEET.drawSprite(sprite, x+w+40, y+35, ctx, false)
      turns = @selectedPlanet.buildStatus()
      text = turns + " turn"
      if turns > 1
        text += "s"
      text += " remaining"
      ctx.fillText(text, x, y+20)

  _drawUnitBlock: (ctx, title, loc, unit, unitConfig, sprite) =>
    x = loc.x + unitConfig.labelLoc.x
    y = loc.y + unitConfig.labelLoc.y
    ctx.fillText(title, x, y)
    if @selectedPlanet.availableResources() < unit.cost
      ctx.fillStyle = window.config.windowStyle.defaultText.red
    x = loc.x + unitConfig.costLoc.x
    y = loc.y + unitConfig.costLoc.y
    ctx.fillText("Cost: " + unit.cost, x, y)
    if @selectedPlanet.availableResources() < unit.cost
      ctx.fillStyle = window.config.windowStyle.defaultText.color
    x = loc.x + unitConfig.turnsLoc.x
    y = loc.y + unitConfig.turnsLoc.y
    ctx.fillText("Turns: " + unit.turns, x, y)
    x = loc.x + unitConfig.imgLoc.x
    y = loc.y + unitConfig.imgLoc.y
    SHEET.drawSprite(sprite, x, y, ctx, false)

  _drawOutpostMenu: (ctx) =>
    winStyle = window.config.windowStyle
    outpostStyle = window.config.outpostMenuStyle
    w = outpostStyle.width
    h = outpostStyle.height
    loc = outpostStyle.location
    @_clearMenu(outpostStyle)(ctx)

    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth

    # Draw background
    ctx.fillRect(loc.x, loc.y, w, h)

    # Draw frame
    ctx.strokeRect(loc.x, loc.y, w, h)

  initialize: (onlyProbe=false, @moveToDiscovered=true, @showResources=true) ->
    @planetButtons = []
    for p in game.getPlanets()
      pos = p.location()
      r = window.config.planetRadius
      b = new Elements.RadialButton(pos.x, pos.y, r, @planetButtonCallback(p))
      b.setHoverHandler(@planetButtonHoverCallback(p))
      b.setMouseOutHandler(@planetButtonOutCallback)
      b.setProperty("planet", p)
      gameFrame.addChild(b)
      @planetButtons.push(b)
    @unitSelection.initialize(onlyProbe)
    @controlGroups = []
    @_groupDisplays = []

  destroy: () ->
    for b in @planetButtons
      gameFrame.removeChild(b)
    @planetButtons = []
    @unitSelection.destroy()

  planetButtonCallback: (planet) =>
    return () =>
      if @unitSelection.total > 0
        for p in @unitSelection.planetsWithSelectedUnits
          attack = @unitSelection.getNumberOfAttacks(p)
          defense = @unitSelection.getNumberOfDefenses(p)
          probe = @unitSelection.getNumberOfProbes(p)
          colony = @unitSelection.getNumberOfColonies(p)
          console.log("moving " + attack + " attack ships, " +
            defense + " defense ships, " +
            probe + " probes, " +
            colony + " colony ships from " +
            "(" + p.location().x + ", " + p.location().y + ")" + " to " +
            "(" + planet.location().x + ", " + planet.location().y + ")")
          p.moveShips(attack, defense, probe, colony, planet)
          @unitSelection.updateSelection(p)
          @updateControlGroups()
        @unitSelection.deselectAllUnits()
      else
        @stationMenu.close()
        @outpostMenu.close()
        if @selectedPlanet == planet
          console.log("closing structure menu for " + planet.toString())
          @selectedPlanet = null
        else if planet.hasStation()
          console.log("opening station menu for " + planet.toString())
          @selectedPlanet = planet
          @stationMenu.open()
        else if planet.hasOutpost()
          console.log("opening outpost menu for " + planet.toString())
          @selectedPlanet = planet
          @outpostMenu.open()
        else
          @selectedPlanet = null
        @switchedMenus = true

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
    visited = []
    ctx.strokeStyle = window.config.connectionStyle.normal.stroke
    ctx.lineWidth = window.config.connectionStyle.normal.lineWidth
    for p in game.getPlanets()
      pos = camera.getScreenCoordinates(p.location())
      visited.push(p)
      for neighbor in p.getAdjacentPlanets()
        if neighbor not in visited and
           p.visibility() != window.config.visibility.undiscovered and
           neighbor.visibility() != window.config.visibility.undiscovered
          # draw connection to the neighbor
          nPos = camera.getScreenCoordinates(neighbor.location())
          ctx.beginPath()
          ctx.moveTo(pos.x, pos.y)
          ctx.lineTo(nPos.x, nPos.y)
          ctx.stroke()

    lost = true
    for p in game.getPlanets()
      loc = p.location()
      pos = camera.getScreenCoordinates(loc)
      if camera.onScreen(pos)
        lost = false
        @help.close()
      # Draw planet
      vis = p.visibility()
      if vis == window.config.visibility.discovered
        if p.fungusStrength() > 0
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_INVISIBLE, loc.x, loc.y, ctx)
      else if vis == window.config.visibility.visible
        if p.fungusStrength() > 0
          SHEET.drawSprite(SpriteNames.PLANET_BLUE_FUNGUS, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.PLANET_BLUE, loc.x, loc.y, ctx)

      # Draw resources
      if @showResources
        if vis != window.config.visibility.undiscovered
          r = p.resources()
          rate = p.rate()
          if r == null
            r = "?"
            rate = "?"
          ctx.font = window.config.windowStyle.defaultText.font
          if p.numShips(window.config.units.probe) > 0 or
             p.hasStation() or p.hasOutpost()
            ctx.fillStyle = window.config.windowStyle.defaultText.value
          else
            ctx.fillStyle = window.config.windowStyle.defaultText.color
          ctx.textAlign = 'left'
          ctx.textBaseline = 'middle'
          offset = 60 * camera.getZoom()
          tRes = "#{r}"
          tRat = "#{rate}"
          if camera.getZoom() > window.config.displayCutoff
            tRes = "Resources: " + tRes
            tRat = "Rate: " + tRat
          ctx.fillText(tRes, pos.x+offset, pos.y)
          ctx.fillText(tRat, pos.x+offset, pos.y+20)

      # Draw structure
      if p.hasOutpost()
        if p.resources() > 0
          SHEET.drawSprite(SpriteNames.OUTPOST_GATHERING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.OUTPOST_NOT_GATHERING, loc.x, loc.y, ctx)
      else if p.hasStation()
        console.log("has station")
        if p.isBuilding()
          switch p.buildUnit()
            when window.config.units.probe
              SHEET.drawSprite(SpriteNames.PROBE_CONSTRUCTION, loc.x, loc.y, ctx)
            when window.config.units.colonyShip
              SHEET.drawSprite(SpriteNames.COLONY_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
            when window.config.units.attackShip
              SHEET.drawSprite(SpriteNames.ATTACK_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
            when window.config.units.defenseShip
              SHEET.drawSprite(SpriteNames.DEFENSE_SHIP_CONSTRUCTION,
                               loc.x, loc.y, ctx)
          SHEET.drawSprite(SpriteNames.STATION_CONSTRUCTING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.STATION_NOT_CONSTRUCTING, loc.x, loc.y, ctx)

        if p.resources() > 0
          SHEET.drawSprite(SpriteNames.STATION_GATHERING, loc.x, loc.y, ctx)
        else
          SHEET.drawSprite(SpriteNames.STATION_NOT_GATHERING, loc.x, loc.y, ctx)
    @unitSelection.draw(ctx, hudCtx)

    if lost
      @help.open()

    if @hoveredPlanet
      # if the button is a planet
      ctx.textAlign = "left"
      ctx.font = window.config.toolTipStyle.font
      ctx.fillStyle = window.config.toolTipStyle.color
      x = @lastMousePos.x + window.config.toolTipStyle.xOffset
      y = @lastMousePos.y + window.config.toolTipStyle.yOffset
      hasAction = true
      if @unitSelection.total > 0
        ctx.fillText("Move selected units", x, y)
      else if @hoveredPlanet.hasOutpost()
        if @outpostMenu.visible and @hoveredPlanet == @selectedPlanet
          ctx.fillText("Close outpost menu", x, y)
        else
          ctx.fillText("Open outpost menu", x, y)
      else if @hoveredPlanet.hasStation()
        if @stationMenu.visible and @hoveredPlanet == @selectedPlanet
          ctx.fillText("Close station menu", x, y)
        else
          ctx.fillText("Open station menu", x, y)
      else if @hoveredPlanet.numShips(window.config.units.colonyShip) > 0
        # if @colonyMenu.visible and @hoveredPlanet = @selectedPlanet
        #   ctx.fillText("Close colony ship menu")
        ctx.fillText("Open colony ship menu", x, y)
      else
        hasAction = false

      if hasAction
        ctx.strokeStyle = window.config.selectionStyle.stroke
        ctx.lineWidth = window.config.selectionStyle.lineWidth
        loc = @hoveredPlanet.location()
        pos = camera.getScreenCoordinates(loc)
        r = (window.config.planetRadius + window.config.selectionStyle.radius) *
             camera.getZoom()
        ctx.beginPath()
        ctx.arc(pos.x, pos.y, r, 0, 2*Math.PI)
        ctx.stroke()

    if @switchedMenus
      @stationMenu.setDirty()
      @outpostMenu.setDirty()

  # The UI expects this to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->
    @lastMousePos = {x: x, y: y}
    @unitSelection.onMouseMove(x, y)

  # The UI expects this to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->
    @unitSelection.onMouseClick(x, y)

  updateControlGroups: () ->
    for c in @controlGroups
      gameFrame.removeChild(c)
    @controlGroups = []
    for g in @_groupDisplays
      frameElement.removeChild(g)
    @_groupDisplays = []
    for p in game.getPlanets()
      gs = {}
      for g in p.getControlGroups()
        next = g.next()
        if not gs[next]
          gs[next] = {}
          gs[next].groups = []
          gs[next].location = next.location()
          gs[next].prev = p
        gs[next].groups.push(g)
      for g of gs
        nextLoc = gs[g].location
        groups = gs[g].groups
        previous = gs[g].prev
        planetGameLoc = previous.location()
        vec = {x: nextLoc.x - planetGameLoc.x, y: nextLoc.y - planetGameLoc.y}
        dist = Math.sqrt(vec.x*vec.x + vec.y*vec.y)
        d = window.config.controlGroup.distance * camera.getZoom()
        controlGameLoc =
          x: vec.x / dist * d + planetGameLoc.x
          y: vec.y / dist * d + planetGameLoc.y
        controlHudLoc = camera.getScreenCoordinates(controlGameLoc)

        controlGroup = null # for groupDisplay's reference

        console.log('num: ' + groups.length)

        eW = window.config.controlGroup.expandedWidth
        eH = window.config.controlGroup.expandedHeight * groups.length +
            window.config.windowStyle.lineWidth * (groups.length - 1)
        groupDisplay = new Elements.BoxElement(controlHudLoc.x+w/2,
                                               controlHudLoc.y+h/2,
                                               eW, eH)
        clear = (ctx) =>
          winStyle = window.config.windowStyle
          ctx.fillStyle = winStyle.fill
          ctx.strokeStyle = winStyle.stroke
          ctx.lineJoin = winStyle.lineJoin
          ctx.lineWidth = winStyle.lineWidth

          loc = {x: groupDisplay.x-eW/2, y: groupDisplay.y-eH/2}
          ctx.clearRect(loc.x - winStyle.lineWidth/2 - 1,
                        loc.y - winStyle.lineWidth/2 - 1,
                        eW + winStyle.lineWidth + 2,
                        eH + winStyle.lineWidth + 2,)

        groupDisplay.setClearFunc(clear)
        groupDisplay.setDrawFunc(
          (ctx) =>
            clear(ctx)
            winStyle = window.config.windowStyle
            ctx.fillStyle = winStyle.fill
            ctx.strokeStyle = winStyle.stroke
            ctx.lineJoin = winStyle.lineJoin
            ctx.lineWidth = winStyle.lineWidth

            loc = camera.getScreenCoordinates(controlGameLoc)
            groupDisplay.moveTo(loc.x + eW/2, loc.y + eH/2)

            ctx.fillRect(loc.x, loc.y, eW, eH)
            ctx.strokeRect(loc.x, loc.y, eW, eH)

        )
        groupDisplay.setMouseOutHandler(
          () =>
            controlGroup.open()
            groupDisplay.close()
        )

        w = window.config.controlGroup.collapsedWidth
        h = window.config.controlGroup.collapsedHeight
        controlGroup = new Elements.BoxElement(controlGameLoc.x+w/2,
                                               controlGameLoc.y+h/2, w, h)
        controlGroup.setHoverHandler(
          () =>
            if not drag
              controlGroup.close()
              groupDisplay.open()
        )
        controlGroup.setDrawFunc(
          (ctx) =>
            winStyle = window.config.windowStyle
            ctx.fillStyle = winStyle.fill
            ctx.strokeStyle = winStyle.stroke
            ctx.lineJoin = winStyle.lineJoin
            ctx.lineWidth = winStyle.lineWidth * camera.getZoom()

            w = window.config.controlGroup.collapsedWidth * camera.getZoom()
            h = window.config.controlGroup.collapsedHeight * camera.getZoom()

            loc = camera.getScreenCoordinates(controlGameLoc)

            ctx.fillRect(loc.x, loc.y, w, h)
            ctx.strokeRect(loc.x, loc.y, w, h)

            ctx.font = window.config.windowStyle.defaultText.font
            ctx.fillStyle = window.config.windowStyle.defaultText.value
            ctx.textAlign = 'center'
            ctx.textBaseline = 'middle'
            if controlGroup.isHovered()
              ctx.fillText("Hovered", loc.x, loc.y)
            else
              ctx.fillText("C", loc.x, loc.y)
        )
        @controlGroups.push(controlGroup)
        gameFrame.addChild(controlGroup)
        @_groupDisplays.push(groupDisplay)
        frameElement.addChild(groupDisplay)
        groupDisplay.visible = false

  endTurn: () ->
    @updateControlGroups()

    for p in game.getPlanets()
      @unitSelection.updateSelection(p)

    # Reset planet button visiblility
    for b in @planetButtons
      p = b.getProperty("planet")
      vis = p.visibility()
      if vis == window.config.visibility.undiscovered or
         (vis == window.config.visibility.discovered and
         not @moveToDiscovered)
        b.visible = false
      else
        b.visible = true
    if @stationMenu
      @stationMenu.setDirty()
