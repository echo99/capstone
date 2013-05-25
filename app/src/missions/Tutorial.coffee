#_require Mission

class Tutorial extends Mission
  # @see Mission#reset
  reset: ->
    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'The Mission Tutorial',
      'eventAction': 'Start'
      'dimension1': 'The Mission Tutorial',
      'metric1': 1
    })
    Math.random = randSave

    # Create planets:
    newGame(10000, 10000)

    @map = @_setupMissionMap()
    @home = @map.home
    @home.addShips(window.config.units.probe, 1)
    @home.addStation()

    @home2 = @map.home2
    @home2.addStation()

    @map.planets[5].setVisibility(window.config.visibility.discovered)
    @map.planets[6].setVisibility(window.config.visibility.discovered)
    @map.planets[7].setVisibility(window.config.visibility.discovered)
    @map.planets[8].setVisibility(window.config.visibility.discovered)
    @map.planets[9].setVisibility(window.config.visibility.discovered)
    @map.planets[9].setFungus(1)
    @map.planets[9]._lastSeenFungus = 1
    @map.planets[10].setVisibility(window.config.visibility.discovered)
    @map.planets[10].setFungus(1)
    @map.planets[10]._lastSeenFungus = 1
    @map.planets[11].setVisibility(window.config.visibility.discovered)
    @map.planets[11].setFungus(1)
    @map.planets[11]._lastSeenFungus = 1
    @map.planets[12].setVisibility(window.config.visibility.discovered)
    @map.planets[12].setFungus(1)
    @map.planets[12]._lastSeenFungus = 1
    @map.planets[13].setVisibility(window.config.visibility.discovered)
    @map.planets[13].setFungus(1)
    @map.planets[13]._lastSeenFungus = 1
    @map.planets[14].setVisibility(window.config.visibility.discovered)
    @map.planets[14].setFungus(1)

    #camera.setZoom(0.1)
    #camera.setZoomTarget(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    game.endTurn()
    UI.initialize()

    @phases =
      INTRO: 0
      MOVE: 1
      STEP_1: 2

    @phase = @phases.INTRO

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@m1)
    cameraHudFrame.removeChild(@skipButton)

    Logger.logEvent("Leaving The Mission from tutorial")
    Logger.send()

  _initMenus: ->
    @m1 = @_getM("Whatever this thing is, it's headed your way...",
      () =>
        @m1.close()
        @m2.open()
        @phase = @phases.MOVE
    )
    @m1.open()
    @m2 = @_getM("You can use the navigation keys to get a better look at the " +
                 "map:\n" +
                 "Move: Click and drag or WASD or arrows\n" +
                 "Zoom: Mouse wheel or +/-",
      () =>
        @m2.close()
        @phase = @phases.STEP_1
        UI.refreshEndTurnButton()
      300, 80
    )

    @skipButton = @createSkipButton(
      () =>
        newMission(Challenge)
    )

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  # @see Mission#canEndTurn
  canEndTurn: ->
    @phase > @phases.MOVE

  # @see Mission#canMove
  canMove: ->
    @phase > @phases.INTRO

  # @see Mission#canPlay
  canPlay: ->
    @phase > @phases.MOVE

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
