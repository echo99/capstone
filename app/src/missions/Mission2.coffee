#_require Mission

class Mission2 extends Mission
  settings2: window.config.Missions.two
  # @see Mission#reset
  reset: ->
    # Create planets:
    newGame(10000, 10000)
    @home = new Planet(0, 0, 10, 1)
    @home.addShips(window.config.units.probe, @settings2.startingProbes)
    @home.addShips(window.config.units.colonyShip, @settings2.startingColonyShips)
    @home.addShips(window.config.units.attackShip, @settings2.startingAttackShips)
    game.addPlanet(@home)
    ###
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
    ###
    p1 = new Planet(-600, -700, 15, 1)
    game.addPlanet(p1)

    p2 = new Planet(700, -300, 5, 1)
    game.addPlanet(p2)

    p3 = new Planet(-200, 800, 10, 1)
    game.addPlanet(p3)
    ###
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
    ###
    game.setNeighbors(@home, p1)
    game.setNeighbors(@home, p2)
    game.setNeighbors(@home, p3)
    ###
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
    ###
    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize(false, true, true)

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)

  _initMenus: ->
    @victoryMenu = @createVictoryMenu(
      () =>
        newMission(Mission2)
      () =>
        # TODO: save progress
        newMission(Mission2)
    )
    @failMenu = @createFailMenu(
      () =>
        newMission(Mission2)
    )

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    # TODO: show number of resources gathered

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    totalResources = 0
    possibleResources = 0
    hasColonyShip = false
    hasProbe = false
    for p in game.getPlanets()
      if p.hasOutpost()
        totalResources += p.availableResources()
        possibleResources += p.resources()
      if p.numShips(window.config.units.probe) > 0
        hasProbe = true
      if p.numShips(window.config.units.colonyShip) > 0
        hasColonyShip = true
      for g in p.getControlGroups()
        if g.probes() > 0
          hasProbe = true
        if g.colonyShips() > 0
          hasColonyShips = true

    if totalResources >= @settings2.resourceGoal
      UI.endGame()
      @victoryMenu.open()
    else if not (hasColonyShip and hasProbe) and
            possibleResources + totalResources < @settings2.resourceGoal
      UI.endGame()
      @failMenu.open()
