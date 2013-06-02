#_require Mission

class Challenge extends Mission
  # @see Mission#reset
  reset: ->
    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'The Mission Challenge',
      'eventAction': 'Start'
      'dimension1': 'The Mission Challenge',
      'metric1': 1
    })
    Math.random = randSave

    # Create planets:
    @home = game.getPlanets()[0]
    ###
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
    ###
    #camera.setZoom(0.1)
    #camera.setZoomTarget(0.5)
    #camera.setTarget(@home.location())

    @_initMenus()

    #game.endTurn()
    UI.initialize()
    UI.endTurn()

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@m0)
    cameraHudFrame.removeChild(@m1)
    cameraHudFrame.removeChild(@optionsMenu)
    cameraHudFrame.removeChild(@menuButton)

    Logger.logEvent("Leaving The Mission from challenge")
    Logger.send()

  _initMenus: ->
    @m0 = @_getM("Well, the attack ship did damage but got destroyed. " +
                  "Defense ships can be used to make your ships survive longer. " +
                  "We'll let you continue on your own now, don't forget to keep " +
                  "making outposts so you don't run out of resources."
      () =>
        @m0.close()
        @m1.open()
      370, 80
    )

    @m1 = @_getM("Exterminate all fungus.",
      () =>
        @m1.close()
    )
    @m0.open()

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

  # @see Mission#canEndTurn
  canEndTurn: ->
    true

  # @see Mission#canMove
  canMove: ->
    true

  # @see Mission#canPlay
  canPlay: ->
    true

  getHomeTarget: ->
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
