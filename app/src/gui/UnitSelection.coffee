
# Keeps track of and updates the which units are selected
class UnitSelection
  total: 0
  totalProbes: 0
  totalColonies: 0
  totalAttacks: 0
  totalDefenses: 0
  onlyProbe: false
  lastMousePos: {x: 0, y: 0}
  planetsWithSelectedUnits: []
  totalDisplay: null
  selectAllHovered: null

  #constructor: ->

  # Initializes the class
  initialize: (onlyProbe=false) ->
    for p in game.getPlanets()
      @_initUnitSelection(p)
      @updateSelection(p)
    @setOnlyProbe(onlyProbe)

  destroy: () ->
    @deselectAllUnits()
    for p in game.getPlanets()
      units = p.unitSelection
      @_destroyStacks(units.probes)
      @_destroyStacks(units.colonies)
      @_destroyStacks(units.attacks)
      @_destroyStacks(units.defenses)
    frameElement.removeChild(@totalDisplay)

  _destroyStacks: (stacks) ->
    for row in stacks
      for stack in row
        stack.destroy()

  setOnlyProbe: (@onlyProbe) ->
    if @totalDisplay != null
      frameElement.removeChild(@totalDisplay)
    loc = window.config.selectionStyle.location
    w = window.config.selectionStyle.width
    if @onlyProbe
      h = window.config.selectionStyle.probeHeight
    else
      h = window.config.selectionStyle.height
    @totalDisplay = new Elements.BoxElement(loc.x+w/2, loc.y+h/2, w, h)
    @totalDisplay.setDrawFunc(@_drawSelection)
    frameElement.addChild(@totalDisplay)

  # Initilizes the data structure that tracks which units are selected
  _initUnitSelection: (planet) ->
    loc = window.config.unitDisplay.location
    pLoc = planet.location()
    location = {x: loc.x + pLoc.x, y: loc.y + pLoc.y}

    units = {probes: [], colonies: [], attacks: [], defenses: []}
    unitButtons = {probe: null, colony: null, attack: null, defense: null}

    updateSelectedPlanets = (count) =>
      planet.selectedUnits += count
      if planet.selectedUnits == 0
        @planetsWithSelectedUnits =
          @planetsWithSelectedUnits.filter((el, i, arr) => el != planet)
      else
        if planet not in @planetsWithSelectedUnits
          @planetsWithSelectedUnits.push(planet)

    probeCallback = (count) =>
      @totalProbes += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true

    probe_location = location
    @_initUnits(probe_location, units.probes, planet, probeCallback)
    unitButtons.probe = @_getUnitButton(probe_location,
                                        window.config.units.probe,
                                        units.probes,
                                        planet,
                                        probeCallback)
    gameFrame.addChild(unitButtons.probe)

    colonyCallback = (count) =>
      @totalColonies += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true

    colony_location = {x: location.x, y: location.y+80}
    @_initUnits(colony_location, units.colonies, planet, colonyCallback)
    unitButtons.colony = @_getUnitButton(colony_location,
                                         window.config.units.colonyShip,
                                         units.colonies,
                                         planet,
                                         colonyCallback)
    gameFrame.addChild(unitButtons.colony)

    attackCallback =  (count) =>
      @totalAttacks += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true

    attack_location = {x: location.x+160, y: location.y+160}
    @_initUnits(attack_location, units.attacks, planet, attackCallback)
    unitButtons.attack = @_getUnitButton(attack_location,
                                         window.config.units.attackShip,
                                         units.attacks,
                                         planet,
                                         attackCallback)
    gameFrame.addChild(unitButtons.attack)

    defenseCallback = (count) =>
      @totalDefenses += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true

    defense_location = {x: location.x+160, y: location.y+240}
    @_initUnits(defense_location, units.defenses, planet, defenseCallback)
    unitButtons.defense = @_getUnitButton(defense_location,
                                          window.config.units.defenseShip,
                                          units.defenses,
                                          planet,
                                          defenseCallback)
    gameFrame.addChild(unitButtons.defense)

    planet.unitSelection = units
    planet.unitButtons = unitButtons
    planet.selectedUnits = 0

  # Initalizes on set of ships in the data structure that tracks
  # unit selection
  _initUnits: (location, stacks, planet, callback) ->
    space = window.config.unitDisplay.spacing
    for row in [0..window.config.unitDisplay.rows - 1]
      stacks.push([])
      for col in [0..window.config.unitDisplay.columns - 1]
        locX = location.x + space * col
        locY = location.y + space * row
        stacks[row].push(new Stack(locX, locY, callback, planet))

  _getUnitButton: (location, unit, unitSelection, planet, callback) ->
    buttonSettings = window.config.unitDisplay.button
    button = new Elements.Button(
      buttonSettings.smallLoc.x, buttonSettings.smallLoc.y,
      buttonSettings.smallW, buttonSettings.smallH,
      () =>
        if @_countUnits(unitSelection) ==
           planet.numShips(unit)
          for row in unitSelection
            for stack in row
              if stack.selected and stack.getCount() > 0
                stack.selected = false
                callback(-stack.getCount())
        else
          for row in unitSelection
            for stack in row
              if not stack.selected and stack.getCount() > 0
                stack.selected = true
                callback(stack.getCount())
    )
    button.setHoverHandler(
      () => @selectAllHover = unit)
    button.setMouseOutHandler(() => @selectAllHover = null)

    bigButton = new Elements.Button(
      buttonSettings.bigLoc.x, buttonSettings.bigLoc.y,
      buttonSettings.bigW, buttonSettings.bigH,
      () =>
        if @_countUnits(unitSelection) ==
           planet.numShips(unit)
          for row in unitSelection
            for stack in row
              if stack.selected and stack.getCount() > 0
                stack.selected = false
                callback(-stack.getCount())
        else
          for row in unitSelection
            for stack in row
              if not stack.selected and stack.getCount() > 0
                stack.selected = true
                callback(stack.getCount())
    )
    bigButton.setHoverHandler(
      () => @selectAllHover = unit)
    bigButton.setMouseOutHandler(() => @selectAllHover = null)

    element = new Elements.BoxElement(
      location.x + buttonSettings.offset.x,
      location.y + buttonSettings.offset.y,
      buttonSettings.bigW,
      buttonSettings.bigH
      )
    element.setDrawFunc(
      (ctx) =>
        if camera.getZoom() < window.config.displayCutoff
          #if button.visible
          button.close()
          bigButton.open()
          @_closeAllStacks()
        else
          #if bigButton.visible
          bigButton.close()
          button.open()
          @_openAllStacks()
        ###
        loc = camera.getScreenCoordinates({x: element.x, y: element.y})

        w = element.w * camera.getZoom()
        h = element.h * camera.getZoom()
        x = loc.x - w / 2
        y = loc.y - h / 2

        ctx.strokeRect(x, y, w, h)
        ###
    )

    button.setDrawFunc(
      (ctx) =>
        winStyle = window.config.windowStyle
        style = window.config.unitDisplay

        loc = camera.getScreenCoordinates(
          element.getActualLocation(button.x, button.y))

        if camera.onScreen(loc)
          w = button.w * camera.getZoom()
          h = button.h * camera.getZoom()
          x = loc.x - w / 2
          y = loc.y - h / 2

          num = @_countUnits(unitSelection)
          ctx.setFont(window.config.windowStyle.lageText.fontObj)
          ctx.textAlign = 'center'
          ctx.textBaseline = 'middle'
          ctx.fillStyle = winStyle.lageText.color

          size = ctx.getFontSizeVal()

          ctx.setFontSizeVal(Math.floor(size * camera.getZoom()))

          text = num + "/" + planet.numShips(unit)
          ctx.fillText(text, loc.x, loc.y)

          ctx.strokeStyle = style.stroke
          ctx.lineJoin = style.lineJoin
          ctx.lineWidth = style.lineWidth
          if button.isHovered()
            ctx.strokeRect(x, y, w, h)
    )

    bigButton.setDrawFunc(
      (ctx) =>
        winStyle = window.config.windowStyle
        style = window.config.unitDisplay

        loc = camera.getScreenCoordinates(
          element.getActualLocation(bigButton.x, bigButton.y))

        if camera.onScreen(loc)
          w = bigButton.w * camera.getZoom()
          h = bigButton.h * camera.getZoom()
          x = loc.x - w / 2
          y = loc.y - h / 2

          num = @_countUnits(unitSelection)
          ctx.setFont(window.config.windowStyle.lageText.fontObj)
          ctx.textAlign = 'left'
          ctx.textBaseline = 'middle'
          ctx.fillStyle = winStyle.lageText.color

          size = ctx.getFontSizeVal()
          ctx.setFontSizeVal(Math.floor(size * 3 * camera.getZoom()))

          text = num + "/" + planet.numShips(unit)
          ctx.fillText(text, x, loc.y)

          ctx.fillStyle = window.config.unitDisplay.fill
          ctx.strokeStyle = style.stroke
          ctx.lineJoin = style.lineJoin
          ctx.lineWidth = style.lineWidth
          if bigButton.isHovered()
            ctx.strokeRect(x, y, w, h)

          dist = buttonSettings.imgOffset * camera.getZoom()
          zoom = camera.getZoom() * 2
          if num == planet.numShips(unit)
            ctx.fillRect(x + (w - h), y, h, h)
          switch unit
            when window.config.units.probe
              SHEET.drawSprite(SpriteNames.PROBE, loc.x+dist, loc.y, ctx, false,
                               zoom)
            when window.config.units.colonyShip
              SHEET.drawSprite(SpriteNames.COLONY_SHIP, loc.x+dist, loc.y, ctx,
                               false, zoom)
            when window.config.units.attackShip
              SHEET.drawSprite(SpriteNames.ATTACK_SHIP, loc.x+dist, loc.y, ctx,
                               false, zoom)
            when window.config.units.defenseShip
              SHEET.drawSprite(SpriteNames.DEFENSE_SHIP, loc.x+dist, loc.y, ctx,
                               false, zoom)
    )
    bigButton.visible = false
    element.addChild(button)
    element.addChild(bigButton)
    return element

  _clearStacks: (stacks) ->
    for row in stacks
      for stack in row
        stack.clear()

  deselectAllUnits: () ->
    for p in @planetsWithSelectedUnits
      units = p.unitSelection
      @_clearStacks(units.probes)
      @_clearStacks(units.colonies)
      @_clearStacks(units.attacks)
      @_clearStacks(units.defenses)
      p.selectedUnits = 0
    @planetsWithSelectedUnits = []
    @total = 0
    @totalProbes = 0
    @totalColonies = 0
    @totalAttacks = 0
    @totalDefenses = 0
    @totalDisplay.dirty = true

  _countUnits: (stacks) ->
    count = 0
    for row in stacks
      for stack in row
        if stack.isSelected()
          count += stack.getCount()
    return count

  getNumberOfProbes: (planet) ->
    return @_countUnits(planet.unitSelection.probes)

  getNumberOfColonies: (planet) ->
    return @_countUnits(planet.unitSelection.colonies)

  getNumberOfAttacks: (planet) ->
    return @_countUnits(planet.unitSelection.attacks)

  getNumberOfDefenses: (planet) ->
    return @_countUnits(planet.unitSelection.defenses)


  # This expects to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->
    @lastMousePos = {x: x, y: y}

  # This expects to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->

  _closeAllStacks: () ->
    for p in game.getPlanets()
      units = p.unitSelection
      @_closeStacks(units.probes)
      @_closeStacks(units.colonies)
      @_closeStacks(units.attacks)
      @_closeStacks(units.defenses)

  _closeStacks: (stacks) ->
    for row in stacks
      for stack in row
        stack.b.close()
        stack.open = false

  _openAllStacks: () ->
    for p in game.getPlanets()
      units = p.unitSelection
      @_openStacks(units.probes)
      @_openStacks(units.colonies)
      @_openStacks(units.attacks)
      @_openStacks(units.defenses)

  _openStacks: (stacks) ->
    for row in stacks
      for stack in row
        if stack.count > 0
          stack.b.open()
          stack.open = true

  # Draws the units next to each planet
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [CanvasRenderingContext2D] hudCtx The hud context
  draw: (ctx, hudCtx) ->
    found = false
    for p in game.getPlanets()
      units = p.unitSelection
      @_drawStacks(ctx, units.probes)
      @_drawStacks(ctx, units.colonies)
      @_drawStacks(ctx, units.attacks)
      @_drawStacks(ctx, units.defenses)

      @_drawPlanetUnits(ctx, p)

      tooltipCtx.textAlign = "left"
      tooltipCtx.font = window.config.toolTipStyle.font
      tooltipCtx.fillStyle = window.config.toolTipStyle.color

      found = @_drawToolTip(units.probes) or
              @_drawToolTip(units.colonies) or
              @_drawToolTip(units.attacks) or
              @_drawToolTip(units.defenses)

    x = @lastMousePos.x + window.config.toolTipStyle.xOffset
    y = @lastMousePos.y + window.config.toolTipStyle.yOffset

    switch @selectAllHover
      when window.config.units.probe
        tooltipCtx.fillText("Select/Deselect all probes", x, y)
      when window.config.units.colonyShip
        tooltipCtx.fillText("Select/Deselect all colony ships", x, y)
      when window.config.units.attackShip
        tooltipCtx.fillText("Select/Deselect all attack ships", x, y)
      when window.config.units.defenseShip
        tooltipCtx.fillText("Select/Deselect all defense ships", x, y)

  _drawToolTip: (stacks) ->
    for row in stacks
      for stack in row
        if stack.isHovered()
          x = @lastMousePos.x + window.config.toolTipStyle.xOffset
          y = @lastMousePos.y + window.config.toolTipStyle.yOffset
          if stack.isSelected()
            tooltipCtx.fillText("Deselect units", x, y)
          else
            tooltipCtx.fillText("Select units", x, y)
          return true
    return false

  # Draws the highlighting for a stack of ships
  _drawStacks: (ctx, stacks) ->
    for row in stacks
      for stack in row
        stack.draw(ctx)

  # Draws the hud that shows total selected units
  _drawSelection: (ctx) =>
    winStyle = window.config.windowStyle
    w = @totalDisplay.w
    h = @totalDisplay.h
    loc = {x: @totalDisplay.x-w/2, y: @totalDisplay.y-h/2}
    ctx.clearRect(loc.x - winStyle.lineWidth / 2 - 1,
                  loc.y - winStyle.lineWidth / 2 - 1,
                  w + winStyle.lineWidth + 2,
                  window.config.selectionStyle.height + winStyle.lineWidth + 2)
    ctx.fillStyle = winStyle.fill
    ctx.strokeStyle = winStyle.stroke
    ctx.lineJoin = winStyle.lineJoin
    ctx.lineWidth = winStyle.lineWidth
    ctx.font = winStyle.titleText.font

    ctx.fillRect(loc.x, loc.y, w, h)
    ctx.strokeRect(loc.x, loc.y, w, h)

    ctx.beginPath()
    ctx.moveTo(loc.x, loc.y+23)
    ctx.lineTo(loc.x+w, loc.y+23)
    ctx.stroke()

    ctx.fillStyle = winStyle.titleText.color
    ctx.textAlign = 'left'
    ctx.textBaseline = 'middle'
    ctx.fillText("Selected Units", loc.x+6, loc.y+13)
    ctx.fillStyle = winStyle.valueText.color

    SHEET.drawSprite(SpriteNames.PROBE, loc.x+30, loc.y+50, ctx, false)
    ctx.fillText(@totalProbes, loc.x+60, loc.y+55)

    if not @onlyProbe
      SHEET.drawSprite(SpriteNames.COLONY_SHIP, loc.x+30, loc.y+90, ctx, false)
      ctx.fillText(@totalColonies, loc.x+60, loc.y+95)

      SHEET.drawSprite(SpriteNames.ATTACK_SHIP,
                       loc.x+30, loc.y+130, ctx, false)
      ctx.fillText(@totalAttacks, loc.x+60, loc.y+135)

      SHEET.drawSprite(SpriteNames.DEFENSE_SHIP,
                       loc.x+30, loc.y+170, ctx, false)
      ctx.fillText(@totalDefenses, loc.x+60, loc.y+175)

  # Draws the one type of ship
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [Object] location Where to draw the ships
  # @param [AnimatedSprite] sprite The sprite to draw
  # @param [Array<Array<Stack>>] stacks The list of stacks
  _drawShips: (ctx, sprite, stacks) ->
    x = 0
    y = 0
    win = window.config.windowStyle
    dis = window.config.unitDisplay
    for row in stacks
      for stack in row
        if not stack.open then continue
        count = stack.getCount()
        if count > 0
          locX = stack.x
          locY = stack.y
          SHEET.drawSprite(sprite, locX, locY, ctx)
        x++
      y++
      x = 0

  _drawShipNums: (ctx, stacks) ->
    x = 0
    y = 0
    win = window.config.windowStyle
    dis = window.config.unitDisplay
    ctx.font = win.defaultText.font
    ctx.fillStyle = win.defaultText.color
    ctx.textAlign = 'left'
    for row in stacks
      for stack in row
        if not stack.open then continue
        count = stack.getCount()
        if count > 0
          locX = stack.x
          locY = stack.y
          offset = window.config.unitDisplay.numberOffset
          coords = camera.getScreenCoordinates(
            {x: locX+offset.x, y: locY+offset.y})
          if camera.onScreen(coords)
            ctx.fillText(stack.getCount(), coords.x, coords.y)
        x++
      y++
      x = 0

  # Draws all the units around the given planet
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [Planet] planet The planet to draw units for
  _drawPlanetUnits: (ctx, planet) ->
    l = window.config.unitDisplay.location
    x = l.x
    y = l.y
    location = {x: x, y: y}
    pLoc = planet.location()
    location.x += pLoc.x
    location.y += pLoc.y

    units = planet.unitSelection

    @_drawShips(ctx, SpriteNames.PROBE, units.probes)
    @_drawShips(ctx, SpriteNames.COLONY_SHIP, units.colonies)
    @_drawShips(ctx, SpriteNames.ATTACK_SHIP, units.attacks)
    @_drawShips(ctx, SpriteNames.DEFENSE_SHIP, units.defenses)

    @_drawShipNums(ctx, units.probes)
    @_drawShipNums(ctx, units.colonies)
    @_drawShipNums(ctx, units.attacks)
    @_drawShipNums(ctx, units.defenses)

  endTurn: () ->
    @deselectAllUnits()

  # Updates the stacks of of the given planet's units
  #
  # @param [Planet] planet The planet whose unit stacks to update
  updateSelection: (planet) ->
    units = planet.unitSelection
    names = window.config.units
    @_allocate(units.probes, planet.numShips(names.probe))
    if planet.numShips(names.probe) == 0
      console.log('no probes')
      planet.unitButtons.probe.close()
    else
      console.log('probes')
      planet.unitButtons.probe.open()
    @_allocate(units.colonies, planet.numShips(names.colonyShip))
    if planet.numShips(names.colonyShip) == 0
      planet.unitButtons.colony.close()
    else
      planet.unitButtons.colony.open()
    @_allocate(units.attacks, planet.numShips(names.attackShip))
    if planet.numShips(names.attackShip) == 0
      planet.unitButtons.attack.close()
    else
      planet.unitButtons.attack.open()
    @_allocate(units.defenses, planet.numShips(names.defenseShip))
    if planet.numShips(names.defenseShip) == 0
      planet.unitButtons.defense.close()
    else
      planet.unitButtons.defense.open()

  # Distributes the number givin into the given list of stacks
  #
  # @param [Array<Array<Stack>>] list The stack list to update
  # @param [Number] count the number to distrubute
  _allocate: (list, count) ->
    for row in list
      for stack in row
        stack.setCount(0)

    while count > 0
      @_getNextStack(list).addOne()
      count--

  # Finds the next stack in a list that needs to be incremented
  #
  # @param [Array<Array<Stack>>] list the list of stacks to check
  # @return [Stack] The next stack to increment
  _getNextStack: (list) ->
    rows = list.length
    cols = list[0].length
    for row in [0..rows-1]
      for col in [0..cols-1]
        s = list[row][col]
        nextR = row
        nextC = col+1
        if col >= cols-1
          nextC = 0
          nextR++
        if (s.getCount() == 0 or
            (list[rows-1][cols-1].getCount() != 0 and (s.getCount() == 1 or
             s.getCount() % 5 != 0 or
             ((row == rows-1 and col == cols-1) or
              s.getCount() == list[nextR][nextC].getCount()))))
          return s

# A class to represent a stack of units
class Stack
  @selected: false
  @hovered: false
  @open: false

  # Constructs a new stack with a default count of 0
  constructor: (@x, @y, @callback, @planet, @count=0) ->
    @w = window.config.unitDisplay.width
    @h = window.config.unitDisplay.height
    @b = new Elements.Button(x, y, @w, @h, @toggleSelection)
    @b.setHoverHandler(() => @hovered = true)
    @b.setMouseOutHandler(() => @hovered = false)
    @b.visible = false
    gameFrame.addChild(@b)

  destroy: ->
    gameFrame.removeChild(@b)

  clear: ->
    @selected = false
    @hovered = false

  # Draws the selection of the stack
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [Number] x The x location of the stack
  # @param [Number] y The y location of the stack
  draw: (ctx) ->
    if not @open then return
    x = @x - @w / 2
    y = @y - @h / 2
    coords = camera.getScreenCoordinates({x: x, y: y})
    if camera.onScreen(coords)
      z = camera.getZoom()
      if @selected
        ctx.fillStyle = window.config.unitDisplay.fill
        ctx.fillRect(coords.x, coords.y, @w*z, @h*z)
      if @hovered
        ctx.strokeStyle = window.config.connectionStyle.unit.stroke
        ctx.lineWidth = window.config.connectionStyle.unit.lineWidth
        loc = camera.getScreenCoordinates({x: @x, y: @y})
        pLoc = camera.getScreenCoordinates(@planet.location())
        ctx.beginPath()
        ctx.moveTo(loc.x, loc.y)
        ctx.lineTo(pLoc.x, pLoc.y)
        ctx.stroke()

        ctx.strokeStyle = window.config.unitDisplay.stroke
        ctx.lineWidth = window.config.unitDisplay.lineWidth
        ctx.lineJoin = window.config.unitDisplay.lineJoin
        ctx.strokeRect(coords.x, coords.y, @w*z, @h*z)

  # Sets the count of the stack
  #
  # @param [Number] count the number to set
  setCount: (@count) ->
    if @count == 0
      @b.close()
      @open = false
    else
      @b.open()
      @open = true

  # Gets the current count of the stack
  #
  # @return [Number] the current count of the stack
  getCount: () ->
    return @count

  # Adds one to the count of the stack
  addOne: () ->
    if not @open and camera.getZoom() > window.config.displayCutoff
      @b.open()
      @open = true
    @count++

  # Test if this stack is selected
  #
  # @return [Boolean] true if the stack is selected
  isSelected: () ->
    return @selected

  # Toggles whether this stack is selected
  toggleSelection: () =>
    @selected = not @selected
    if @selected
      @callback(@count)
    else
      @callback(-@count)

  # Test if this stack is hovered over
  #
  # @return [Boolean] true if the stack is hovered over
  isHovered: () ->
    return @hovered

  # Toggles whether this stack is hovered over
  toggleHover: () =>
    @hovered = not @hovered
