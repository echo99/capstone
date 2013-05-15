#_require Mission
#_require ../util/ArrowElement

class Mission1 extends Mission
  # @see Mission#reset
  reset: ->
    @attempts = localStorage["mission_1_attempts"]
    if not @attempts
      @attempts = 0
    @attempts++
    localStorage["mission_1_attempts"] = Number(@attempts)
    Logger.logEvent("Starting Mission 1", {attempt: @attempts})

    @foundA1 = false
    @foundA2 = false
    @failures = {not_failed: -1, no_probe: 0, no_ships: 1}
    @failure = @failures.not_failed

    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'Mission 1',
      'eventAction': 'Start'
      #'eventLabel': 'Mission 1'
      'dimension1': 'Mission 1',
      'metric1': 1
    })
    Math.random = randSave

    # Create planets:
    newGame(10000, 10000)
    @home = new Planet(0,0)
    @home.addShips(window.config.units.probe, 1)
    game.addPlanet(@home)

    @a1 = new Planet(-1000, -1000)
    game.addPlanet(@a1)

    @a2 = new Planet(-1150, 1250)
    game.addPlanet(@a2)

    f1 = new Planet(-1500, -1300)
    #f1.setFungus(1)
    game.addPlanet(f1)

    f2 = new Planet(-1950, -100)
    f2.setFungus(1)
    game.addPlanet(f2)

    f3 = new Planet(-1600, 850)
    #f3.setFungus(1)
    game.addPlanet(f3)

    f4 = new Planet(670, 900)
    f4.setFungus(1)
    game.addPlanet(f4)

    f5 = new Planet(-850, -50)
    #f5.setFungus(1)
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

    game.setNeighbors(@a1, f1)
    game.setNeighbors(@a1, f5)
    game.setNeighbors(@a1, p3)
    game.setNeighbors(@a1, p8)
    game.setNeighbors(@a2, p6)
    game.setNeighbors(@a2, f3)

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

    camera.setZoom(0.1)
    camera.setZoomTarget(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize(false, true, false)

    @phases =
      SELECT_PROBE: 1
      SELECT_PLANET: 2
      END_TURN: 3
      THE_REST: 4
      FIRST_TURN: 5
    @phase = @phases.FIRST_TURN
    @probeArrow = new ArrowElement({x: -250, y: -100}, {x: -300, y: -150}, 5, 30)
    @planetArrow1 = new ArrowElement({x: 350, y: -550}, {x: 300, y: -600}, 5, 30)
    @planetArrow2 = new ArrowElement({x: -450, y: -550}, {x: -500, y: -600}, 5, 30)
    @planetArrow3 = new ArrowElement({x: -550, y: 450}, {x: -600, y: 400}, 5, 30)
    @endArrow = new ArrowElement(
      {x: 50, y: camera.height - 30},
      {x: 50, y: camera.height - 30 - 50}, 3, 30, true)

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)
    cameraHudFrame.removeChild(@optionsMenu)
    frameElement.removeChild(@menuButton)
    @probeArrow.destroy()

    Logger.logEvent("Leaving Mission 1")
    Logger.send()

  _initMenus: ->
    restart = () => newMission(Mission1)
    next = () => newMission(Mission2)
    @victoryMenu = @createVictoryMenu(restart, next)
    @failMenu = @createFailMenu(restart)
    @optionsMenu = @createOptionMenu(restart)
    @menuButton = @createMenuButton(@optionsMenu)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    switch @failure
      when @failures.no_probe
        ctx.textAlign = 'center'
        ctx.textBaseline = 'top'
        ctx.font = window.config.windowStyle.defaultText.font
        ctx.fillStyle = window.config.windowStyle.defaultText.color
        ctx.fillText("No more probes", camera.width / 2, camera.height / 2 + 50)
      when @failures.no_ships
        ctx.textAlign = 'center'
        ctx.textBaseline = 'top'
        ctx.font = window.config.windowStyle.defaultText.font
        ctx.fillStyle = window.config.windowStyle.defaultText.color
        ctx.fillText("No more attack ships",
                     camera.width / 2, camera.height / 2 + 50)

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->
    if @phase == @phases.FIRST_TURN
      if @_probeInControlGroup()
        @planetArrow1.close()
        @planetArrow2.close()
        @planetArrow3.close()
        @probeArrow.close()
        @endArrow.open()
      else if @_probeSelected()
        @planetArrow1.open()
        @planetArrow2.open()
        @planetArrow3.open()
        @probeArrow.close()
        @endArrow.close()
      else
        @planetArrow1.close()
        @planetArrow2.close()
        @planetArrow3.close()
        @probeArrow.open()
        @endArrow.close()
    else
      @planetArrow1.close()
      @planetArrow2.close()
      @planetArrow3.close()
      @probeArrow.close()
      @endArrow.close()

  _probeInControlGroup: ->
    for p in game.getPlanets()
      for g in p.getControlGroups()
        if g.probes() > 0
          return true

  _probeSelected: ->
    for p in game.getPlanets()
      units = p.unitSelection
      for row in units.probes
        for stack in row
          if stack.isSelected() and stack.getCount() > 0
            return true

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    if @home.numShips(window.config.units.probe) == 0
      @phase = @phases.THE_REST

    if @a1.visibility() == window.config.visibility.visible and not @foundA1
      @foundA1 = true
      @a1.addShips(window.config.units.attackShip, 1)
      UI.endTurn()
      UI.turns--
      Logger.logEvent("Player found single attack ship")
    if @a2.visibility() == window.config.visibility.visible and not @foundA2
      @foundA2 = true
      @a2.addShips(window.config.units.attackShip, 2)
      UI.endTurn()
      UI.turns--
      Logger.logEvent("Player found two attack ships")

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
      current = localStorage["progress"]
      if current < 2
        localStorage["progress"] = 2
        Logger.logEvent("Player completed Mission 1 for the first time",
                        {attempts: @attempts})
      if not @gameEnded
        @endTime = currentTime()
        randSave = Math.random
        Math.seedrandom()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 1',
          'eventAction': 'Complete',
          'eventLabel': 'Victory',
          'dimension1': 'Mission 1',
          'metric5': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 1',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Victory'
        })
        Math.random = randSave

        Logger.logEvent("Player successfully completed Mission 1",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns})
      @gameEnded = true
      UI.endGame()
      @victoryMenu.open()
    else if not hasProbe or (not hasAttackShips and @foundA1 and @foundA2)
      if not hasProbe
        @failure = @failures.no_probe
        Logger.logEvent("Player lost their probe")
      else if not hasAttackShips
        @failure = @failures.no_ships
        Logger.logEvent("Player lost their attack ships")
      if not @gameEnded
        @endTime = currentTime()
        randSave = Math.random
        Math.seedrandom()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission 1',
          'eventAction': 'Complete'
          'eventLabel': 'Fail'
          'dimension1': 'Mission 1',
          'metric6': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson 1',
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Fail'
        })
        Math.random = randSave
        Logger.logEvent("Player failed Mission 1",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns})
      @gameEnded = true
      UI.endGame()
      @failMenu.open()
