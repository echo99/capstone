#_require Mission

# This mission acts as our games main menu
class Mission1 extends Mission
  # @see Mission#reset
  reset: ->
    # Create planets:
    #game.setup(10, null)
    #return
    newGame(10000, 10000)

    UI.initialize()
    camera.setZoom(0.5)
    #camera.setTarget(@home.location())

    @_initMenus()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)

  _initMenus: ->
    @victoryMenu = @createVictoryMenu(
      () =>
        newMission(Mission1)
      () =>
        newMission(Mission2)
    )
    @failMenu = @createFailMenu(
      () =>
        newMission(Mission1)
    )

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  getHomeTarget: ->
    return {x: 0, y: 0}

  # @see Mission#onEndTurn
  onEndTurn: ->
    # TODO: check for end game
    ###
    if @home.numShips(window.config.units.probe) > 10
      UI.endGame()
      @victoryMenu.open()
    if @home.numShips(window.config.units.defenseShip) > 10
      UI.endGame()
      @failMenu.open()
    ###