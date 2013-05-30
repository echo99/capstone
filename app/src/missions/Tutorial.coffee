#_require Mission
#_require ../util/ArrowElement

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
      TUT: 2
      #SELECT_PROBE_1: 3
      #MOVE_PROBE_1: 4
      END: 100

    @phase = @phases.INTRO

    h = @home.location()
    @select_home_1_arrow = new ArrowElement(
      {x: h.x - 75, y: h.y - 75},
      {x: h.x - 125, y: h.y - 125}, 5, 30)
    @select_home_1_arrow.close()

    @select_probe_0_arrow = new ArrowElement(
      {x: h.x - 250, y: h.y - 100},
      {x: h.x - 300, y: h.y - 150}, 5, 30)
    @select_probe_0_arrow.close()

    h = @home2.location()
    @select_home_2_arrow = new ArrowElement(
      {x: h.x - 75, y: h.y - 75},
      {x: h.x - 125, y: h.y - 125}, 5, 30)
    @select_home_2_arrow.close()

    p = @map.planets[3].location()
    @select_probe_3_arrow = new ArrowElement(
      {x: p.x - 250, y: p.y - 100},
      {x: p.x - 300, y: p.y - 150}, 5, 30)
    @select_probe_3_arrow.close()

    @move_planet_3_arrow = new ArrowElement(
      {x: p.x - 75, y: p.y - 75},
      {x: p.x - 125, y: p.y - 125}, 5, 30)
    @move_planet_3_arrow.close()

    p = @map.planets[5].location()
    @select_probe_5_arrow = new ArrowElement(
      {x: p.x - 250, y: p.y - 100},
      {x: p.x - 300, y: p.y - 150}, 5, 30)
    @select_probe_5_arrow.close()

    @move_planet_5_arrow = new ArrowElement(
      {x: p.x - 75, y: p.y - 75},
      {x: p.x - 125, y: p.y - 125}, 5, 30)
    @move_planet_5_arrow.close()

    p = @map.planets[6].location()
    @select_probe_6_arrow = new ArrowElement(
      {x: p.x - 250, y: p.y - 100},
      {x: p.x - 300, y: p.y - 150}, 5, 30)
    @select_probe_6_arrow.close()

    @move_planet_6_arrow = new ArrowElement(
      {x: p.x - 75, y: p.y - 75},
      {x: p.x - 125, y: p.y - 125}, 5, 30)
    @move_planet_6_arrow.close()

    @build_probe_arrow = new ArrowElement(
      {x: 340, y: 50},
      {x: 290, y: 50}, 5, 30, true)
    @build_probe_arrow.close()

    @build_colony_arrow = new ArrowElement(
      {x: 340, y: 110},
      {x: 290, y: 110}, 5, 30, true)
    @build_colony_arrow.close()

    @build_attack_arrow = new ArrowElement(
      {x: 540, y: 50},
      {x: 590, y: 50}, 5, 30, true)
    @build_attack_arrow.close()

    @endArrow = new ArrowElement(
      {x: 50, y: camera.height - 30},
      {x: 50, y: camera.height - 30 - 50}, 3, 30, true)
    @endArrow.close()

    @currentArrow = null

    @startTime = currentTime()

  destroy: ->
    @select_probe_0_arrow.destroy()
    @select_probe_3_arrow.destroy()
    @select_probe_5_arrow.destroy()
    @select_probe_6_arrow.destroy()
    @move_planet_3_arrow.destroy()
    @move_planet_5_arrow.destroy()
    @move_planet_6_arrow.destroy()
    @select_home_1_arrow.destroy()
    @select_home_2_arrow.destroy()
    @build_probe_arrow.destroy()
    @build_colony_arrow.destroy()
    @build_attack_arrow.destroy()
    @endArrow.destroy()
    cameraHudFrame.removeChild(@m1)
    cameraHudFrame.removeChild(@m2)
    cameraHudFrame.removeChild(@m3)
    cameraHudFrame.removeChild(@m4)
    cameraHudFrame.removeChild(@m5)
    cameraHudFrame.removeChild(@m6)
    cameraHudFrame.removeChild(@m7)
    cameraHudFrame.removeChild(@m8)
    cameraHudFrame.removeChild(@m9)
    cameraHudFrame.removeChild(@skipButton)
    cameraHudFrame.removeChild(@optionsMenu)
    cameraHudFrame.removeChild(@menuButton)

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
        @m3.open()
        @phase = @phases.TUT
      300, 80
    )
    @m3 = @_getM("In order to explore the map we need probes, lets move the one " +
                 "we have and build another one.", null, 250, 65)
    @m4 = @_getM("Notice that one of the Stations doesn't have many resources " +
                  "remaining...",
      () =>
        @m4.close()
        @m5.open()
    )

    @m5 = @_getM("This can be fixed with an Outpost, which requires a colony " +
                 "ship and a probe to build...",
      () =>
        @m5.close()
        @m6.open()
      250, 65
    )

    @m6 = @_getM("We already have a probe so lets make a colony ship."
      null
      #300, 65
    )

    @m7 = @_getM("Good, that's going to take a few turns to finish so lets " +
                 "continue to explore with our probe."
      null
        250, 65
    )

    @m8 = @_getM("Now our other Station has enough resouces for an attack ship. " +
                 "Because we'll encounter the fungus soon we should make one."
      null
        300, 65
    )

    @m9 = @_getM("Lets keep moving the probe as well.",
      null
    )

    @skipButton = @createSkipButton(
      () =>
        newMission(Challenge)
    )

    restart = () => newMission(Cutscene)
    @optionsMenu = @_createMenu(window.config.MainMenu.mission.menu,
      restart, start=false, restart=true, quit=true, cancel=false, close=true)
    @menuButton = @createCameraHUDMenuButton(@optionsMenu)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->
    if @phase > @phases.MOVE
      switch UI.turns
        when 0
          @_checkMoveProbeArrows()
        when 1
          if not @m4.visible and not @m5.visible and not @m6.visible
            @m3.close()
            @m4.open()
          if @m6.visible or @m7.visible
            @_checkTurn1Arrows()
          else
            @endArrow.close()
        when 2
          if not @m8.visible and not @m9.visible
            @m7.close()
            @m8.open()
          if @m8.visible or @m9.visible
            @_checkTurn2Arrows()
        when 3
          @endArrow.close()

    UI.refreshEndTurnButton()

  _checkTurn2Arrows: ->
    if UI.selectedPlanet != @home2 and
       @home2.buildUnit() != window.config.units.attackShip
      @select_home_2_arrow.open()
      @build_attack_arrow.close()
      @select_probe_5_arrow.close()
      @move_planet_6_arrow.close()
      @endArrow.close()
      camera.setTarget(@home2.location())
    else if @home2.buildUnit() != window.config.units.attackShip
      @select_home_2_arrow.close()
      @build_attack_arrow.open()
      @select_probe_5_arrow.close()
      @move_planet_6_arrow.close()
      @endArrow.close()
    else if @_probeSelected(@map.planets[5])
      @select_home_2_arrow.close()
      @build_attack_arrow.close()
      @select_probe_5_arrow.close()
      @move_planet_6_arrow.open()
      @endArrow.close()
    else if @map.planets[5].numShips(window.config.units.probe) > 0
      @select_home_2_arrow.close()
      @build_attack_arrow.close()
      @select_probe_5_arrow.open()
      @move_planet_6_arrow.close()
      @endArrow.close()
      @m8.close()
      @m9.open()
      camera.setTarget(@map.planets[5].location())
    else
      @select_home_2_arrow.close()
      @build_attack_arrow.close()
      @select_probe_5_arrow.close()
      @move_planet_6_arrow.close()
      @endArrow.open()

  _checkTurn1Arrows: ->
    if UI.selectedPlanet != @home and
       @home.buildUnit() != window.config.units.colonyShip
      @select_home_1_arrow.open()
      @build_colony_arrow.close()
      @select_probe_3_arrow.close()
      @move_planet_5_arrow.close()
      @endArrow.close()
    else if @home.buildUnit() != window.config.units.colonyShip
      @select_home_1_arrow.close()
      @build_colony_arrow.open()
      @select_probe_3_arrow.close()
      @move_planet_5_arrow.close()
      @endArrow.close()
    else if @_probeSelected(@map.planets[3])
      @select_home_1_arrow.close()
      @build_colony_arrow.close()
      @select_probe_3_arrow.close()
      @move_planet_5_arrow.open()
      @endArrow.close()
    else if @map.planets[3].numShips(window.config.units.probe) > 0
      @select_home_1_arrow.close()
      @build_colony_arrow.close()
      @select_probe_3_arrow.open()
      @move_planet_5_arrow.close()
      @endArrow.close()
      @m6.close()
      @m7.open()
      camera.setTarget(@map.planets[3].location())
    else
      @select_home_1_arrow.close()
      @build_colony_arrow.close()
      @select_probe_3_arrow.close()
      @move_planet_5_arrow.close()
      @endArrow.open()

  _checkMoveProbeArrows: ->
    if @_probeSelected(@home)
      @select_probe_0_arrow.close()
      @move_planet_3_arrow.open()
      @select_home_1_arrow.close()
      @build_probe_arrow.close()
      @endArrow.close()
    else if @home.numShips(window.config.units.probe) > 0
      @select_probe_0_arrow.open()
      @move_planet_3_arrow.close()
      @select_home_1_arrow.close()
      @build_probe_arrow.close()
      @endArrow.close()
    else if UI.selectedPlanet != @home and not @home.isBuilding()
      @select_probe_0_arrow.close()
      @move_planet_3_arrow.close()
      @select_home_1_arrow.open()
      @build_probe_arrow.close()
      @endArrow.close()
    else if @home.buildUnit() != window.config.units.probe
      @select_probe_0_arrow.close()
      @move_planet_3_arrow.close()
      @select_home_1_arrow.close()
      @build_probe_arrow.open()
      @endArrow.close()
    else
      @select_probe_0_arrow.close()
      @move_planet_3_arrow.close()
      @select_home_1_arrow.close()
      @build_probe_arrow.close()
      @endArrow.open()

  _probeSelected: (planet) ->
    units = planet.unitSelection
    for row in units.probes
      for stack in row
        if stack.isSelected() and stack.getCount() > 0
          return true

  # @see Mission#canEndTurn
  canEndTurn: ->
    @endArrow.element.visible
    #@phase > @phases.MOVE

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
