
# Keeps track of and updates the which units are selected
class UnitSelection
  @total_probes: 0
  @total_colony: 0
  @total_attack: 0
  @total_defense: 0

  #constructor: ->

  # Initializes the class
  initialize: () ->
    for p in game.getPlanets()
      p.unitSelection = {
        probes: [
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()],
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()]
        ]
        colony: [
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()],
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()]
        ]
        attack: [
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()],
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()]
        ]
        defense: [
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()],
          [new Stack(), new Stack(), new Stack(), new Stack(), new Stack()]
        ]
      }
      @updateSelection(p)

  # This expects to be called when the mouse moves
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseMove: (x, y) ->

  # This expects to be called when the mouse clicks
  #
  # @param [Number] x The x position of the mouse
  # @param [Number] y The y position of the mouse
  onMouseClick: (x, y) ->

  # Draws the units next to each planet
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  draw: (ctx) ->
    for p in game._planets
      @_drawPlanetUnits(ctx, p)
    winStyle = window.config.windowStyle
    loc = window.config.selectionStyle.location
    w = window.config.selectionStyle.width
    h = window.config.selectionStyle.height
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
    ctx.fillText("Selected Units", loc.x+7, loc.y+17)
    ctx.fillStyle = winStyle.valueText.color
    ctx.fillText("1", 110, 105)
    SHEET.drawSprite(SpriteNames.PROBE, 70, 100, ctx, false)


  # Draws the one typ of ship
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [Object] location Where to draw the ships
  # @param [AnimatedSprite] sprite The sprite to draw
  # @param [Array<Array<Stack>>] stacks The list of stacks
  _drawShips: (ctx, location, sprite, stacks) ->
    x = 0
    y = 0
    win = window.config.windowStyle
    dis = window.config.unitDisplay
    for row in stacks
      for stack in row
        count = stack.getCount()
        if count > 0
          locX = location.x + dis.spacing * x
          locY = location.y + dis.spacing * y
          SHEET.drawSprite(sprite, locX, locY, ctx)
          ctx.font = win.defaultText.font
          ctx.fillStyle = win.defaultText.color
          ctx.textAlign = 'left'
          coords = camera.getScreenCoordinates({x: locX+10, y: locY+20})
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

    probe_location = location
    @_drawShips(ctx, probe_location, SpriteNames.PROBE, units.probes)

    colony_location = {x: location.x, y: location.y+80}
    @_drawShips(ctx, colony_location, SpriteNames.COLONY_SHIP, units.colony)

    attack_location = {x: location.x, y: location.y+160}
    @_drawShips(ctx, attack_location, SpriteNames.ATTACK_SHIP, units.attack)

    defense_location = {x: location.x, y: location.y+240}
    @_drawShips(ctx, defense_location, SpriteNames.DEFENSE_SHIP, units.defense)
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
    @_allocate(units.probes, planet._probes)
    @_allocate(units.colony, planet._colonys)
    @_allocate(units.attack, planet._attackShips)
    @_allocate(units.defense, planet._defenseShips)

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
  constructor: (@count=0) ->

  # Draws the selection of the stack
  #
  # @param [CanvasRenderingContext2D] ctx The game context
  # @param [Number] x The x location of the stack
  # @param [Number] y The y location of the stack
  draw: (ctx, x, y) ->
    w = window.config.unitDisplay.width
    h = window.config.unitDisplay.height
    x = x - w / 2
    y = y - h / 2
    if @selected
      ctx.fillStyle = window.config.unitDisplay.fill
      ctx.fillRect(x, y, w, h)
    if @hovered
      ctx.strokeStyle = window.config.unitDisplay.stroke
      ctx.lineWidth = window.config.unitDisplay.lineWidth
      ctx.strokeRect(x, y, w, h)

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
  toggleSelection: () ->
    @selected = not @selected
