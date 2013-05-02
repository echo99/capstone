#_require Mission

# This mission acts as our games main menu
class Extermination extends Mission
  #settings: window.config.MainMenu

  # @see Mission#reset
  reset: ->
    # Create planets:
    #game.setup(10, null)
    #return
    newGame(10000, 10000)
    @Planets =
      a: new Planet(0, 0, 50, 1)
      b: new Planet(300, 450, 70, 3)
      c: new Planet(300, -450, 25, 2)

    game.addPlanet(@Planets.a)
    game.addPlanet(@Planets.b)
    game.addPlanet(@Planets.c)

    # Add connections to game
    game.setNeighbors(@Planets.a, @Planets.b)
    game.setNeighbors(@Planets.a, @Planets.c)
    game.setNeighbors(@Planets.b, @Planets.c)

    # Add initial units
    @Planets.a.addShips(window.config.units.probe, 1)
    @Planets.a._station = true
    @Planets.a._unitConstructing = window.config.units.colonyShip
    @Planets.a._turnsToComplete = 5
    @Planets.b._outpost = true

    UI.initialize()
    camera.setZoom(0.5)
    camera.setTarget(@Planets.a.location())

    game.setup(0, null)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->
    # if drawing a prompt
    #   check mouse position against the button positions

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  getHomeTarget: ->
    # TODO: come up with smarter target
    return @Plants.a.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    # TODO: check for end game
    if @Planets.b.numShips(window.config.units.probe) > 0
      newMission(Menu)