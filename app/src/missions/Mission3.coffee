#_require Mission

class Mission3 extends Mission
  settings3: window.config.Missions.three
  # @see Mission#reset
  reset: ->
    @attempts = localStorage["mission_3_attempts"]
    if not @attempts
      @attempts = 0
    @attempts++
    localStorage["mission_3_attempts"] = Number(@attempts)
    Logger.logEvent("Starting Mission 3", {attempt: @attempts})

    @failed = false

    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'Mission 3',
      'eventAction': 'Start'
      #'eventLabel': 'Mission 3'
      'dimension1': 'Mission 3',
      'metric1': 1
    })

    # Create planets:
    newGame(10000, 10000)
    @home = new Planet(0, 0, @settings3.homeResources, 1)
    @home._availableResources = @settings3.homeAvailable
    @home.addOutpost()
    @home.addShips(window.config.units.probe, @settings3.startingProbes)
    @home.addShips(window.config.units.defenseShip, @settings3.startingDefenseShips)
    game.addPlanet(@home)

    f1 = new Planet(-2270, -1000, 15, 1)
    f1.setFungus(5)
    game.addPlanet(f1)

    f2 = new Planet(1900, -1270, 20, 1)
    f2.setFungus(5)
    game.addPlanet(f2)

    f3 = new Planet(2270, 750, 14, 1)
    f3.setFungus(5)
    game.addPlanet(f3)

    o1 = new Planet(-700, -1100, @settings3.o1Resources, 1)
    o1._availableResources = @settings3.o1Available
    o1.addOutpost()
    game.addPlanet(o1)

    o2 = new Planet(270, -1100, @settings3.o2Resources, 1)
    o2._availableResources = @settings3.o2Available
    o2.addOutpost()
    game.addPlanet(o2)

    o3 = new Planet(-500, -10, @settings3.o3Resources, 1)
    o3._availableResources = @settings3.o3Available
    o3.addOutpost()
    game.addPlanet(o3)

    o4 = new Planet(550, 170, @settings3.o4Resources, 1)
    o4._availableResources = @settings3.o4Available
    o4.addOutpost()
    game.addPlanet(o4)

    p1 = new Planet(-2050, -560, 11, 1)
    game.addPlanet(p1)

    p2 = new Planet(-1600, -260, 5, 1)
    game.addPlanet(p2)

    p3 = new Planet(-1050, -550, 1, 1)
    game.addPlanet(p3)

    p4 = new Planet(-1250, 170, 7, 2)
    game.addPlanet(p4)

    p5 = new Planet(-400, -670, 6, 1)
    game.addPlanet(p5)

    p6 = new Planet(-700, 520, 0, 0)
    game.addPlanet(p6)

    p7 = new Planet(180, -500, 3, 1)
    game.addPlanet(p7)

    p8 = new Planet(-50, 550, 8, 1)
    game.addPlanet(p8)

    p9 = new Planet(600, -700, 2, 1)
    game.addPlanet(p9)

    p10 = new Planet(1170, -720, 10, 1)
    game.addPlanet(p10)

    p11 = new Planet(1420, -1130, 3, 1)
    game.addPlanet(p11)

    p12 = new Planet(1900, -750, 4, 1)
    game.addPlanet(p12)

    p13 = new Planet(1900, -100, 9, 1)
    game.addPlanet(p13)

    p14 = new Planet(1770, 480, 3, 1)
    game.addPlanet(p14)

    p15 = new Planet(1500, -10, 1, 1)
    game.addPlanet(p15)

    p16 = new Planet(1170, 100, 18, 1)
    game.addPlanet(p16)

    p17 = new Planet(1170, 730, 13, 1)
    game.addPlanet(p17)

    p18 = new Planet(-1600, -920, 11, 1)
    game.addPlanet(p18)

    p19 = new Planet(-2000, 160, 9, 1)
    game.addPlanet(p19)

    game.setNeighbors(@home, o3)
    game.setNeighbors(@home, o4)
    game.setNeighbors(@home, p5)
    game.setNeighbors(@home, p7)
    game.setNeighbors(@home, p8)

    game.setNeighbors(o1, p3)
    game.setNeighbors(o1, p5)
    game.setNeighbors(o2, p7)
    game.setNeighbors(o2, p9)
    game.setNeighbors(o3, p3)
    game.setNeighbors(o3, p4)
    game.setNeighbors(o3, p5)
    game.setNeighbors(o3, p6)
    game.setNeighbors(o3, p8)
    game.setNeighbors(o4, p8)
    game.setNeighbors(o4, p16)
    game.setNeighbors(o4, p17)

    game.setNeighbors(f1, p1)
    game.setNeighbors(f2, p11)
    game.setNeighbors(f2, p12)
    game.setNeighbors(f3, p14)

    game.setNeighbors(p1, p2)
    game.setNeighbors(p2, p3)
    game.setNeighbors(p2, p4)
    game.setNeighbors(p2, p18)
    game.setNeighbors(p2, p19)
    game.setNeighbors(p3, p5)
    game.setNeighbors(p4, p6)
    game.setNeighbors(p5, p7)
    game.setNeighbors(p6, p8)
    game.setNeighbors(p7, p9)
    game.setNeighbors(p9, p10)
    game.setNeighbors(p10, p11)
    game.setNeighbors(p10, p12)
    game.setNeighbors(p10, p13)
    game.setNeighbors(p11, p12)
    game.setNeighbors(p12, p13)
    game.setNeighbors(p13, p14)
    game.setNeighbors(p13, p15)
    game.setNeighbors(p14, p17)
    game.setNeighbors(p14, p15)
    game.setNeighbors(p15, p16)
    game.setNeighbors(p16, p17)

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

    Logger.logEvent("Leaving Mission 3")
    Logger.send()

  _initMenus: ->
    restart = () => newMission(Mission3)
    next = () => newMission(Menu) # TODO: Mission4
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
    t = "Resources collected: " + totalResources + "/" + @settings3.resourceGoal
    ctx.fillText(t, camera.width / 2, camera.height - 10)

    if @failed
      ctx.textAlign = 'center'
      ctx.textBaseline = 'top'
      ctx.font = window.config.windowStyle.defaultText.font
      ctx.fillStyle = window.config.windowStyle.defaultText.color
      ctx.fillText("Impossible to get to " + @settings3.resourceGoal,
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
    for p in game.getPlanets()
      if p.hasOutpost() or p.hasStation()
        totalResources += p.availableResources()
        possibleResources += p.resources()

    if totalResources >= @settings3.resourceGoal
      current = localStorage["progress"]
      if current < 4
        localStorage["progress"] = 4
        Logger.logEvent("Player completed Mission 3 for the first time",
                        {attempts: @attempts})
      if not @gameEnded
        @endTime = currentTime()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 3',
          'eventAction': 'Complete',
          'eventLabel': 'Victory',
          'dimension1': 'Mission 3',
          'metric5': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 3',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Victory'
        })
        Logger.logEvent("Player successfully completed Mission 3",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns
                        resources: totalResources})
      @gameEnded = true
      UI.endGame()
      @victoryMenu.open()
    else if possibleResources + totalResources < @settings3.resourceGoal
      @failed = true
      if not @gameEnded
        @endTime = currentTime()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 3',
          'eventAction': 'Complete'
          'eventLabel': 'Fail'
          'dimension1': 'Mission 3',
          'metric6': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 3',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Fail'
        })
        Logger.logEvent("Player failed Mission 3",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns
                        resources: totalResources
                        max_possible: totalResources + possibleResources})
      @gameEnded = true
      UI.endGame()
      @failMenu.open()
