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
    @home = game.setup(10)
    @home.addStation()

    # Test stuff
    @home.getAdjacentPlanets()[0].addOutpost()
    @home.addShips(window.config.units.probe, 8)
    @home.addShips(window.config.units.colonyShip, 10)
    @home.addShips(window.config.units.attackShip, 10)
    @home.addShips(window.config.units.defenseShip, 10)
    # End test stuff

    UI.initialize()
    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)

  _initMenus: ->
    @victoryMenu = @createVictoryMenu(
      () =>
        console.log('restart extermination')
        newMission(Extermination)
      () =>
        console.log('to next mission')
        newMission(Menu)
    )
    @failMenu = @createFailMenu(
      () =>
        console.log('restart extermination')
        newMission(Extermination)
    )

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
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    hasFungus = false
    for p in game.getPlanets()
      if p.fungusStrength() > 0
        hasFungus = true

    if not hasFungus
      UI.endGame()
      @victoryMenu.open()

    if not @home.hasStation()
      UI.endGame()
      @failMenu.open()