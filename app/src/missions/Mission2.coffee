#_require Mission

class Mission2 extends Mission
  settings2: window.config.Missions.two
  # @see Mission#reset
  reset: ->
    Logger.logEvent("Starting Mission 2")
    @failed = false

    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'Mission 2',
      'eventAction': 'Start'
      #'eventLabel': 'Mission 2'
      'dimension1': 'Mission 2',
      'metric1': 1
    })

    # Create planets:
    newGame(10000, 10000, true)
    @home = new Planet(0, 0, 0, 0)
    @home.addShips(window.config.units.probe, @settings2.startingProbes)
    @home.addShips(window.config.units.colonyShip, @settings2.startingColonyShips)
    @home.addShips(window.config.units.attackShip, @settings2.startingAttackShips)
    game.addPlanet(@home)

    f1 = new Planet(1100, 1600, 17, 2)
    f1.setFungus(7)
    game.addPlanet(f1)

    f2 = new Planet(1400, 0, 20, 1)
    f2.setFungus(8)
    game.addPlanet(f2)

    f3 = new Planet(1300, 850, 14, 1)
    f3.setFungus(9)
    game.addPlanet(f3)

    p1 = new Planet(-100, -700, 11, 1)
    game.addPlanet(p1)

    p2 = new Planet(-700, -300, 5, 1)
    game.addPlanet(p2)

    p3 = new Planet(-1000, 300, 1, 1)
    game.addPlanet(p3)

    p4 = new Planet(-450, 550, 7, 2)
    game.addPlanet(p4)

    p5 = new Planet(200, 800, 6, 1)
    game.addPlanet(p5)

    p6 = new Planet(900, 1100, 0, 0)
    game.addPlanet(p6)

    p7 = new Planet(400, 400, 3, 1)
    game.addPlanet(p7)

    p8 = new Planet(600, -290, 8, 1)
    game.addPlanet(p8)

    p9 = new Planet(900, 200, 2, 1)
    game.addPlanet(p9)

    p10 = new Planet(1200, -400, 10, 1)
    game.addPlanet(p10)

    p11 = new Planet(1100, -800, 3, 1)
    game.addPlanet(p11)

    p12 = new Planet(1200, 400, 4, 1)
    game.addPlanet(p12)

    p13 = new Planet(1800, 400, 9, 1)
    game.addPlanet(p13)

    game.setNeighbors(@home, p1)
    game.setNeighbors(@home, p2)
    game.setNeighbors(@home, p3)
    game.setNeighbors(@home, p4)
    game.setNeighbors(@home, p7)
    game.setNeighbors(@home, p8)

    game.setNeighbors(f1, p6)
    game.setNeighbors(f2, p9)
    game.setNeighbors(f2, p10)
    game.setNeighbors(f2, p12)
    game.setNeighbors(f3, p12)

    game.setNeighbors(p1, p2)
    game.setNeighbors(p2, p3)
    game.setNeighbors(p3, p4)
    game.setNeighbors(p4, p5)
    game.setNeighbors(p5, p6)
    game.setNeighbors(p5, p7)
    game.setNeighbors(p7, p9)
    game.setNeighbors(p8, p9)
    game.setNeighbors(p8, p10)
    game.setNeighbors(p9, p10)
    game.setNeighbors(p9, p12)
    game.setNeighbors(p10, p11)
    game.setNeighbors(p12, p13)

    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize(false, true, true)

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)
    cameraHudFrame.removeChild(@optionsMenu)
    frameElement.removeChild(@menuButton)

    Logger.logEvent("Leaving Mission 2")
    Logger.send()

  _initMenus: ->
    restart = () => newMission(Mission2)
    next = () => newMission(Mission3)
    @victoryMenu = @createVictoryMenu(restart, next)
    @failMenu = @createFailMenu(restart)
    @optionsMenu = @createOptionMenu(restart)
    @menuButton = @createMenuButton(@optionsMenu)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    totalResources = 0
    for p in game.getPlanets()
      if p.hasOutpost() or p.hasStation()
        totalResources += p.availableResources()

    ctx.textAlign = 'center'
    ctx.textBaseline = 'bottom'
    ctx.font = window.config.windowStyle.defaultText.font
    ctx.fillStyle = window.config.windowStyle.defaultText.color
    t = "Resources collected: " + totalResources + "/" + @settings2.resourceGoal
    ctx.fillText(t, camera.width / 2, camera.height - 10)

    if @failed
      ctx.textAlign = 'center'
      ctx.textBaseline = 'top'
      ctx.font = window.config.windowStyle.defaultText.font
      ctx.fillStyle = window.config.windowStyle.defaultText.color
      ctx.fillText("Impossible to get to 50",
                   camera.width / 2, camera.height / 2 + 50)

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
      if p.hasOutpost() or p.hasStation()
        totalResources += p.availableResources()
        possibleResources += p.resources()
      if p.numShips(window.config.units.probe) > 0
        hasProbe = true
      if p.numShips(window.config.units.colonyShip) > 0
        hasColonyShip = true
      for g in p.getControlGroups()
        if g.probes() > 0
          hasProbe = true
        if g.colonies() > 0
          hasColonyShip = true

    if totalResources >= @settings2.resourceGoal
      current = localStorage["progress"]
      if current < 3
        localStorage["progress"] = 3
      if not @gameEnded
        @endTime = currentTime()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 2',
          'eventAction': 'Complete',
          'eventLabel': 'Victory',
          'dimension1': 'Mission 2',
          'metric5': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 2',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Victory'
        })
        Logger.logEvent("Resources:", totalResources)
        Logger.logEvent("Player successfully completed Mission 2",
                        getMinutes(@endTime - @startTime))
      @gameEnded = true
      UI.endGame()
      @victoryMenu.open()
    else if not (hasColonyShip and hasProbe) and
            possibleResources + totalResources < @settings2.resourceGoal
      @failed = true
      if not @gameEnded
        @endTime = currentTime()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 2',
          'eventAction': 'Complete'
          'eventLabel': 'Fail'
          'dimension1': 'Mission 2',
          'metric6': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 2',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Fail'
        })
        Logger.logEvent("Resources:", totalResources)
        Logger.logEvent("Max possible:", totalResources + possibleResources)
        Logger.logEvent("colony ship?", hasColonyShip)
        Logger.logEvent("probe?", hasProbe)
        Logger.logEvent("Player faild Mission 2", getMinutes(@endTime - @startTime))
      @gameEnded = true
      UI.endGame()
      @failMenu.open()
