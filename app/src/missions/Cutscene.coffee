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

    @map.station.addStation()
    @map.outpost.addOutpost()
    @map.outpost._availableResources = 1
    @map.probe.addShips(window.config.units.probe, 1)
    @map.fungus_start.setFungus(2)

    @map.planets[8].addShips(window.config.units.probe, 1)
    @map.planets[6].addShips(window.config.units.probe, 1)
    @map.planets[7].addShips(window.config.units.probe, 1)
    @map.planets[5].addShips(window.config.units.probe, 1)

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

  destroy: ->
    cameraHudFrame.removeChild(@foundA1Message)

    Logger.logEvent("Leaving The Mission from cutscene")
    Logger.send()

  _initMenus: ->
    @m1 = @_getM("Getting ready to move into uncharted territory",
      () =>
        @m1.close()
        @phase = @phases.MOVE_HIDDEN
    )
    @m1.open()

    @m2 = @_getM("Hey what's that?",
      () =>
        @m2.close()
        @phase = @phases.MOVE_TO_PROBE
    )

    @m3 = @_getM("AAAAHHHHH!",
      () =>
        @m3.close()
        @phase = @phases.DESTROY
    )

  _getM: (message, onNext) ->
    m = new Elements.MessageBox(0, 200, 250, 100, message,
      {
        textAlign: 'left',
        vAlign: 'top',
        font: window.config.windowStyle.defaultText.font,
        lineHeight: 17
        visible: false
      })

    next = new Elements.Button(250 - 10, 10, 16, 16, onNext)
    next.setDrawFunc(
      (ctx) =>
        loc = m.getActualLocation(next.x, next.y)
        SHEET.drawSprite(SpriteNames.CLOSE, loc.x, loc.y, ctx, false)
    )
    m.addChild(next)
    cameraHudFrame.addChild(m)

    return m

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
      when @phases.MOVE_TO_PROBE
        endTurn()
        if @map.probe.fungusStrength() > 0
          @phase = @phases.READ_3
          @m3.open()
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
  hasInput: -> true

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
