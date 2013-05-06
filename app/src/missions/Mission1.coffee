#_require Mission

# This mission acts as our games main menu
class Mission1 extends Mission
  # @see Mission#reset
  reset: ->
    # Create planets:
    #game.setup(10, null)
    #return
    newGame(10000, 10000)
    @home = new Planet(0,0)
    @home.addShips(window.config.units.probe, 2)
    game.addPlanet(@home)

    attack1 = new Planet(-1000, -1000)
    attack1.addShips(window.config.units.attackShip, 2)
    game.addPlanet(attack1)

    attack2 = new Planet(-1500, 1000)
    attack2.addShips(window.config.units.attackShip, 4)
    game.addPlanet(attack2)

    p1 = new Planet(0, -800)
    game.addPlanet(p1)

    p2 = new Planet(400, -500)
    game.addPlanet(p2)

    p3 = new Planet(-400, -500)
    game.addPlanet(p3)

    p4 = new Planet(300, 450)
    game.addPlanet(p4)

    p5 = new Planet(-500, 500)
    game.addPlanet(p5)

    p6 = new Planet(-1100, 700)
    game.addPlanet(p6)

    game.setNeighbors(@home, p2)
    game.setNeighbors(@home, p3)
    game.setNeighbors(@home, p4)
    game.setNeighbors(@home, p5)
    game.setNeighbors(p1, p3)
    game.setNeighbors(p1, p2)
    game.setNeighbors(p3, attack1)
    game.setNeighbors(p5, p6)
    game.setNeighbors(p6, attack2)

    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize()

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
    return @home.location()

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