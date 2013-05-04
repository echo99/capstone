
# Keeps track of and updates the which units are selected
# TODO:
#   - Make display change when zoomed out too far
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

    updateSelectedPlanets = (count) =>
      planet.selectedUnits += count
      if planet.selectedUnits == 0
        @planetsWithSelectedUnits =
          @planetsWithSelectedUnits.filter((el, i, arr) => el != planet)
      else
        if planet not in @planetsWithSelectedUnits
          @planetsWithSelectedUnits.push(planet)

    probe_location = location
    @_initUnits(probe_location, units.probes, planet, (count) =>
      @totalProbes += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true)

    colony_location = {x: location.x, y: location.y+80}
    @_initUnits(colony_location, units.colonies, planet, (count) =>
      @totalColonies += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true)

    attack_location = {x: location.x, y: location.y+160}
    @_initUnits(attack_location, units.attacks, planet, (count) =>
      @totalAttacks += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true)

    defense_location = {x: location.x, y: location.y+240}
    @_initUnits(defense_location, units.defenses, planet, (count) =>
      @totalDefenses += count
      @total += count
      updateSelectedPlanets(count)
      @totalDisplay.dirty = true)

    planet.unitSelection = units
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

      found = @_drawToolTip(ctx, units.probes) or
              @_drawToolTip(ctx, units.colonies) or
              @_drawToolTip(ctx, units.attacks) or
              @_drawToolTip(ctx, units.defenses)

  _drawToolTip: (ctx, stacks) ->
    for row in stacks
      for stack in row
        if stack.isHovered()
          ctx.textAlign = "left"
          ctx.font = window.config.toolTipStyle.font
          ctx.fillStyle = window.config.toolTipStyle.color
          x = @lastMousePos.x + window.config.toolTipStyle.xOffset
          y = @lastMousePos.y + window.config.toolTipStyle.yOffset
          if stack.isSelected()
            ctx.fillText("Deselect units", x, y)
          else
            ctx.fillText("Select units", x, y)
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
        count = stack.getCount()
        if count > 0
          locX = stack.x
          locY = stack.y
          SHEET.drawSprite(sprite, locX, locY, ctx)
          ctx.font = win.defaultText.font
          ctx.fillStyle = win.defaultText.color
          ctx.textAlign = 'left'
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
    #   for each control group
    #     if control group is hovered over
    #       draw expanded view
    #     else
    #       draw unexpanded view
    #

  # Updates the stacks of of the given planet's units
  #
  # @param [Planet] planet The planet whose unit stacks to update
  updateSelection: (planet) ->
    units = planet.unitSelection
    names = window.config.units
    @_allocate(units.probes, planet.numShips(names.probe))
    @_allocate(units.colonies, planet.numShips(names.colonyShip))
    @_allocate(units.attacks, planet.numShips(names.attackShip))
    @_allocate(units.defenses, planet.numShips(names.defenseShip))

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

  # Constructs a new stack with a default count of 0
  constructor: (@x, @y, @callback, @planet, @count=0) ->
    @w = window.config.unitDisplay.width
    @h = window.config.unitDisplay.height
    @b = new Elements.Button(x, y, @w, @h, @toggleSelection)
    @b.setHoverHandler(() => @hovered = true)
    @b.setMouseOutHandler(() => @hovered = false)
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
    if @count == 0
      @b.visible = false
      return
    else
      @b.visible = true
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

  # Gets the current count of the stack
  #
  # @return [Number] the current count of the stack
  getCount: () ->
    return @count

  # Adds one to the count of the stack
  addOne: () ->
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
