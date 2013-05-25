#_require Mission

class Cutscene extends Mission
  # @see Mission#reset
  reset: ->
    @attempts = localStorage["mission_attempts"]
    if not @attempts
      @attempts = 0
    @attempts++
    localStorage["mission_attempts"] = Number(@attempts)
    Logger.logEvent("Starting The Mission", {attempt: @attempts})

    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'The Mission',
      'eventAction': 'Start'
      'dimension1': 'The Mission',
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

    @map.station.addStation()
    @map.station.addShips(window.config.units.probe, 2)
    @map.station.addShips(window.config.units.colonyShip, 1)
    @map.outpost.addOutpost()
    @map.outpost.addShips(window.config.units.probe, 1)
    @map.outpost._availableResources = 1
    @map.probe.addShips(window.config.units.probe, 1)
    @map.fungus_start.setFungus(2)

    @map.planets[5].setVisibility(window.config.visibility.discovered)
    @map.planets[6].setVisibility(window.config.visibility.discovered)
    @map.planets[7].setVisibility(window.config.visibility.discovered)
    @map.planets[8].setVisibility(window.config.visibility.discovered)

    camera.setZoom(0.1)
    camera.setZoomTarget(0.5)
    camera.setTarget(@map.probe.location())

    @_initMenus()

    game.endTurn()
    UI.initialize()

    @startTime = currentTime()
    @lastTime = @startTime

    @phases =
      READ_1: 0
      MOVE_HIDDEN: 1
      READ_2: 2
      MOVE_TO_PROBE: 3
      READ_3: 4
      DESTROY: 5

    @phase = @phases.READ_1

    @advancing_turn = false

  destroy: ->
    cameraHudFrame.removeChild(@m1)
    cameraHudFrame.removeChild(@m2)
    cameraHudFrame.removeChild(@m3)
    cameraHudFrame.removeChild(@skipButton)


    Logger.logEvent("Leaving The Mission from cutscene")
    Logger.send()

  _initMenus: ->
    @m1 = @_getM("We're getting ready to move into uncharted territory.",
      () =>
        @m1.close()
        @advancing_turn = true
        @phase = @phases.MOVE_HIDDEN
    )
    @m1.open()

    @m2 = @_getM("Hey what's that?",
      () =>
        @m2.close()
        @advancing_turn = true
        @phase = @phases.MOVE_TO_PROBE
    )

    @m3 = @_getM("It's spreading toward us! AAAAHHHHH!",
      () =>
        @m3.close()
        @advancing_turn = true
        @phase = @phases.DESTROY
    )

    @skipButton = @createSkipButton(
      () =>
        newMission(Tutorial)
    )

  _advanceTurn: ->
    if currentTime() - @lastTime > 1000
      endTurn()
      @lastTime = currentTime()

  # @see Mission#draw
  draw: (ctx, hudCtx) ->
    switch @phase
      when @phases.MOVE_HIDDEN
        endTurn()
        if @map.planets[12].fungusStrength() > 0
          @phase = @phases.READ_2
          @m2.open()
          @advancing_turn = false
      when @phases.MOVE_TO_PROBE
        endTurn()
        if @map.probe.fungusStrength() > 0
          @phase = @phases.READ_3
          @m3.open()
          @advancing_turn = false
      when @phases.DESTROY
        @_advanceTurn()

    if not @map.outpost.sendingResourcesTo() and
       @map.outpost.hasOutpost() and @map.station.hasStation()
      @map.outpost.sendResources(@map.station)

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  # @see Mission#hasInput
  #hasInput: -> true
  canPlay: -> false

  # @see Mission#canMove
  canMove: -> false

  # @see Mission#canEndTurn
  canEndTurn: -> @advancing_turn

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    if @map.planets[8].fungusStrength() > 0
      camera.setTarget(@map.planets[8].location())
    else if @map.planets[9].fungusStrength() > 0
      camera.setTarget(@map.planets[9].location())
    else if @map.planets[10].fungusStrength() > 0
      camera.setTarget(@map.planets[10].location())
    else if @map.planets[11].fungusStrength() > 0
      camera.setTarget(@map.planets[11].location())
    else if @map.planets[12].fungusStrength() > 0
      camera.setTarget(@map.planets[12].location())

    if not @map.station.hasStation() and not @map.outpost.hasOutpost()
      newMission(Tutorial)