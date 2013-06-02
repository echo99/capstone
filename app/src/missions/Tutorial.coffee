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

    @select_colony_0_arrow = new ArrowElement(
      {x: h.x - 250, y: h.y - 0},
      {x: h.x - 300, y: h.y - 50}, 5, 30)
    @select_colony_0_arrow.close()

    @select_attack_0_arrow = new ArrowElement(
      {x: h.x - 80, y: h.y + 50},
      {x: h.x - 130, y: h.y - 0}, 5, 30)
    @select_attack_0_arrow.close()

    h = @home2.location()
    @select_home_2_arrow = new ArrowElement(
      {x: h.x - 75, y: h.y - 75},
      {x: h.x - 125, y: h.y - 125}, 5, 30)
    @select_home_2_arrow.close()

    @select_attack_1_arrow = new ArrowElement(
      {x: h.x - 80, y: h.y + 50},
      {x: h.x - 130, y: h.y - 0}, 5, 30)
    @select_attack_1_arrow.close()

    p = @map.planets[2].location()
    @move_planet_2_arrow = new ArrowElement(
      {x: p.x - 75, y: p.y - 75},
      {x: p.x - 125, y: p.y - 125}, 5, 30)
    @move_planet_2_arrow.close()

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

    @select_attack_6_arrow = new ArrowElement(
      {x: p.x - 80, y: p.y + 50},
      {x: p.x - 130, y: p.y - 0}, 5, 30)
    @select_attack_6_arrow.close()

    p = @map.planets[8].location()
    @move_planet_8_arrow = new ArrowElement(
      {x: p.x - 75, y: p.y - 75},
      {x: p.x - 125, y: p.y - 125}, 5, 30)
    @move_planet_8_arrow.close()

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

    @build_structure_arrow = new ArrowElement(
      {x: 325, y: 100},
      {x: 375, y: 100}, 5, 30, true)
    @build_structure_arrow.close()

    @send_resources_arrow = new ArrowElement(
      {x: 310, y: 25},
      {x: 360, y: 25}, 5, 30, true)
    @send_resources_arrow.close()

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
    @select_colony_0_arrow.destroy()
    @select_attack_0_arrow.destroy()
    @select_attack_1_arrow.destroy()
    @select_attack_6_arrow.destroy()
    @move_planet_2_arrow.destroy()
    @move_planet_3_arrow.destroy()
    @move_planet_5_arrow.destroy()
    @move_planet_6_arrow.destroy()
    @move_planet_8_arrow.destroy()
    @select_home_1_arrow.destroy()
    @select_home_2_arrow.destroy()
    @build_probe_arrow.destroy()
    @build_colony_arrow.destroy()
    @build_attack_arrow.destroy()
    @build_structure_arrow.destroy()
    @send_resources_arrow.destroy()
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
    cameraHudFrame.removeChild(@m10)
    cameraHudFrame.removeChild(@m11)
    cameraHudFrame.removeChild(@m12)
    cameraHudFrame.removeChild(@m13)
    cameraHudFrame.removeChild(@m14)
    cameraHudFrame.removeChild(@m15)
    cameraHudFrame.removeChild(@m16)
    cameraHudFrame.removeChild(@m17)
    cameraHudFrame.removeChild(@m18)
    cameraHudFrame.removeChild(@m19)
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

    @m10 = @_getM("We'll leave the probe there for now, lets just end the turn " +
                  "again to finish the colony ship.",
      null
      250, 65
    )

    @m11 = @_getM("Now we can build an Outpost. We should pick a planet that " +
                  "plenty of recources, lets try the one that hasn't been " +
                  "explored yet.",
      null
      300, 65
    )

    @m12 = @_getM("We should also start another attack ship.",
      null
    )

    @m13 = @_getM("This should have enough recources for a while, lets build " +
                  "the outpost here.",
      null
    )

    @m14 = @_getM("Lets move the attack ship up to where our probe is, and " +
                  "build another.",
      null
    )

    @m15 = @_getM("Lets end the turn again.",
      null
    )

    @m16 = @_getM("Now that the outpost is complete it can be used to send any " +
                  "resources that it gathers to the station.",
      null
      250, 65
    )

    @m17 = @_getM("Our other attack ship has also finished, so lets send it " +
                  "forward as well.",
      null
    )

    @m18 = @_getM("Don't forget to keep advancing new ships.",
      null
    )

    @m19 = @_getM("Now lets try sending in our attack ship.",
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
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m4.visible and not @m5.visible and not @m6.visible
            @m3.close()
            @m4.open()
          if @m6.visible or @m7.visible
            @_checkTurn1Arrows()
          else
            @endArrow.close()
        when 2
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m8.visible and not @m9.visible
            @m4.close()
            @m5.close()
            @m6.close()
            @m7.close()
            @m8.open()
          if @m8.visible or @m9.visible
            @_checkTurn2Arrows()
        when 3
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m10.visible
            @m8.close()
            @m9.close()
            @m10.open()
            camera.setTarget(@home.location())
          if @m10.visible
            @_checkTurn3Arrows()
        when 4
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m11.visible and not @m12.visible
            @m10.close()
            @m11.open()
          if @m11.visible or @m12.visible
            @_checkTurn4Arrows()
        when 5
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m13.visible and not @m14.visible
            @m11.close()
            @m12.close()
            @m13.open()
          if @m13.visible or @m14.visible
            @_checkTurn5Arrows()
        when 6
          if @map.planets[8].fungusStrength() != 0
            @map.planets[8].setFungus(0)
          if not @m15.visible
            @m13.close()
            @m14.close()
            @m15.open()
          if @m15.visible
            @_checkTurn3Arrows()
        when 7
          window.config.units.attackShip.attack = 1
          window.config.units.fungus.attack = 1
          if @map.planets[8].fungusStrength() != 2
            @map.planets[8].setFungus(2)
          if not @m16.visible and not @m17.visible
            @m15.close()
            @m16.open()
          if @m16.visible or @m17.visible
            @_checkTurn7Arrows()
        when 8
          if not @m18.visible and not @m19.visible
            @m16.close()
            @m17.close()
            @m18.open()
            camera.setTarget(@home2.location())
          if @m18.visible or @m19.visible
            @_checkTurn8Arrows()
        when 9
          window.config.units.attackShip.attack = 0.5
          window.config.units.fungus.attack = 0.5
          newMission(Challenge)

    UI.refreshEndTurnButton()

  _checkTurn8Arrows: ->
    if @_attackSelected(@home2)
      @select_attack_1_arrow.close()
      @move_planet_6_arrow.open()

      @select_attack_6_arrow.close()
      @move_planet_8_arrow.close()

      @endArrow.close()
    else if @home2.numShips(window.config.units.attackShip) > 0
      @select_attack_1_arrow.open()
      @move_planet_6_arrow.close()

      @select_attack_6_arrow.close()
      @move_planet_8_arrow.close()

      @endArrow.close()
    else if @_attackSelected(@map.planets[6])
      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_attack_6_arrow.close()
      @move_planet_8_arrow.open()

      @endArrow.close()
    else if @map.planets[6].numShips(window.config.units.attackShip) > 0
      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_attack_6_arrow.open()
      @move_planet_8_arrow.close()

      @endArrow.close()
      @m18.close()
      @m19.open()
    else
      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_attack_6_arrow.close()
      @move_planet_8_arrow.close()

      @endArrow.open()

  _checkTurn7Arrows: ->
    if UI.selectedPlanet != @map.planets[2] and
       @map.planets[2].sendingResourcesTo() != @home
      @move_planet_2_arrow.open()
      @send_resources_arrow.close()
      @select_home_1_arrow.close()

      @select_attack_0_arrow.close()
      @move_planet_6_arrow.close()

      @endArrow.close()
    else if not @map.planets[2].sendingResourcesTo() and
            not UI.lookingToSendResources
      @move_planet_2_arrow.close()
      @send_resources_arrow.open()
      @select_home_1_arrow.close()

      @select_attack_0_arrow.close()
      @move_planet_6_arrow.close()

      @endArrow.close()
    else if UI.lookingToSendResources
      @move_planet_2_arrow.close()
      @send_resources_arrow.close()
      @select_home_1_arrow.open()

      @select_attack_0_arrow.close()
      @move_planet_6_arrow.close()

      @endArrow.close()
    else if @_attackSelected(@home)
      @move_planet_2_arrow.close()
      @send_resources_arrow.close()
      @select_home_1_arrow.close()

      @select_attack_0_arrow.close()
      @move_planet_6_arrow.open()

      @endArrow.close()
    else if @home.numShips(window.config.units.attackShip) > 0
      @move_planet_2_arrow.close()
      @send_resources_arrow.close()
      @select_home_1_arrow.close()

      @select_attack_0_arrow.open()
      @move_planet_6_arrow.close()

      @endArrow.close()
      @m16.close()
      @m17.open()
    else
      @move_planet_2_arrow.close()
      @send_resources_arrow.close()
      @select_home_1_arrow.close()

      @select_attack_0_arrow.close()
      @move_planet_6_arrow.close()

      @endArrow.open()

  _checkTurn5Arrows: ->
    if UI.selectedPlanet != @map.planets[2] and
       @map.planets[2].buildUnit() != window.config.structures.outpost
      @move_planet_2_arrow.open()
      @build_structure_arrow.close()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.close()
      @build_attack_arrow.close()

      @endArrow.close()
    else if @map.planets[2].buildUnit() != window.config.structures.outpost
      @move_planet_2_arrow.close()
      @build_structure_arrow.open()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.close()
      @build_attack_arrow.close()

      @endArrow.close()
    else if @_attackSelected(@home2)
      @move_planet_2_arrow.close()
      @build_structure_arrow.close()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.open()

      @select_home_2_arrow.close()
      @build_attack_arrow.close()

      @endArrow.close()
    else if @home2.numShips(window.config.units.attackShip) > 0
      @move_planet_2_arrow.close()
      @build_structure_arrow.close()

      @select_attack_1_arrow.open()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.close()
      @build_attack_arrow.close()

      @endArrow.close()
      @m13.close()
      @m14.open()
    else if UI.selectedPlanet != @home2 and
            @home2.buildUnit() != window.config.units.attackShip
      @move_planet_2_arrow.close()
      @build_structure_arrow.close()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.open()
      @build_attack_arrow.close()

      @endArrow.close()
    else if @home2.buildUnit() != window.config.units.attackShip
      @move_planet_2_arrow.close()
      @build_structure_arrow.close()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.close()
      @build_attack_arrow.open()

      @endArrow.close()
    else
      @move_planet_2_arrow.close()
      @build_structure_arrow.close()

      @select_attack_1_arrow.close()
      @move_planet_6_arrow.close()

      @select_home_2_arrow.close()
      @build_attack_arrow.close()

      @endArrow.open()

  _checkTurn4Arrows: ->
    selected = false
    if @home.numShips(window.config.units.probe) > 0 and
       not @_probeSelected(@home)
      @select_probe_0_arrow.open()
      @endArrow.close()
    else
      @select_probe_0_arrow.close()
      selected = true

    if @home.numShips(window.config.units.colonyShip) > 0 and
       not @_colonySelected(@home)
      @select_colony_0_arrow.open()
      @endArrow.close()
      selected = false
    else
      @select_colony_0_arrow.close()

    if selected
      @move_planet_2_arrow.open()
    else
      @move_planet_2_arrow.close()

    if @home.numShips(window.config.units.probe) == 0 and
       @home.numShips(window.config.units.colonyShip) == 0
      @move_planet_2_arrow.close()
      @m11.close()
      @m12.open()
      if UI.selectedPlanet != @home and
         @home.buildUnit() != window.config.units.attackShip
        @select_home_1_arrow.open()
        @build_attack_arrow.close()
        @endArrow.close()
      else if @home.buildUnit() != window.config.units.attackShip
        @select_home_1_arrow.close()
        @build_attack_arrow.open()
        @endArrow.close()
      else
        @select_home_1_arrow.close()
        @build_attack_arrow.close()
        @endArrow.open()
    else
      @select_home_1_arrow.close()
      @build_attack_arrow.close()
      @endArrow.close()

  _checkTurn3Arrows: ->
    @endArrow.open()

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
    @_unitSelected(planet, planet.unitSelection.probes)

  _colonySelected: (planet) ->
    @_unitSelected(planet, planet.unitSelection.colonies)

  _attackSelected: (planet) ->
    @_unitSelected(planet, planet.unitSelection.attacks)

  _defenseSelected: (planet) ->
    @_unitSelected(planet, planet.unitSelection.defenses)

  _unitSelected: (planet, units) ->
    for row in units
      for stack in row
        if stack.isSelected() and stack.getCount() > 0
          return true
    return false

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
    @onMouseClick(0,0)