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

    a1 = new Planet(-1000, -1000)
    a1.addShips(window.config.units.attackShip, 2)
    game.addPlanet(a1)

    a2 = new Planet(-1150, 1250)
    a2.addShips(window.config.units.attackShip, 4)
    game.addPlanet(a2)

    f1 = new Planet(-1500, -1300)
    f1.setFungus(1)
    game.addPlanet(f1)

    f2 = new Planet(-1950, -100)
    f2.setFungus(1)
    game.addPlanet(f2)

    f3 = new Planet(-1600, 850)
    f3.setFungus(1)
    game.addPlanet(f3)

    f4 = new Planet(670, 900)
    f4.setFungus(1)
    game.addPlanet(f4)

    f5 = new Planet(-850, -50)
    f5.setFungus(1)
    game.addPlanet(f5)

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

    p7 = new Planet(-1500, 300)
    game.addPlanet(p7)

    p8 = new Planet(-1300, -500)
    game.addPlanet(p8)

    game.setNeighbors(@home, p2)
    game.setNeighbors(@home, p3)
    game.setNeighbors(@home, p4)
    game.setNeighbors(@home, p5)

    game.setNeighbors(a1, f1)
    game.setNeighbors(a1, f5)
    game.setNeighbors(a1, p3)
    game.setNeighbors(a1, p8)
    game.setNeighbors(a2, p6)
    game.setNeighbors(a2, f3)

    game.setNeighbors(f1, p8)
    game.setNeighbors(f2, p7)
    game.setNeighbors(f2, p8)
    game.setNeighbors(f3, p6)
    game.setNeighbors(f3, p7)
    game.setNeighbors(f4, p4)
    game.setNeighbors(f5, p3)
    game.setNeighbors(f5, p5)
    game.setNeighbors(f5, p6)
    game.setNeighbors(f5, p7)
    game.setNeighbors(f5, p8)

    game.setNeighbors(p1, p3)
    game.setNeighbors(p1, p2)
    game.setNeighbors(p5, p6)
    game.setNeighbors(p6, p7)
    game.setNeighbors(p7, p8)

    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize(false, true, false)

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
    hasFungus = false
    hasProbe = false
    hasAttackShips = false
    for p in game.getPlanets()
      if p.fungusStrength() > 0
        hasFungus = true
      if p.numShips(window.config.units.probe) > 0
        hasProbe = true
      if p.numShips(window.config.units.attackShip) > 0
        hasAttackShips = true
      for g in p.getControlGroups()
        if g.probes() > 0
          hasProbe = true
        if g.attackShips() > 0
          hasAttackShips = true

    if not hasFungus
      # TODO: save progress
      UI.endGame()
      @victoryMenu.open()
    else if not hasProbe or not hasAttackShips
      console.log("has probe: " + hasProbe)
      console.log("has attack ships: " + hasAttackShips)
      UI.endGame()
      @failMenu.open()
