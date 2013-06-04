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

    @_initMenus()

    UI.initialize()
    UI.endTurn()

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@m1)
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)
    cameraHudFrame.removeChild(@optionsMenu)
    cameraHudFrame.removeChild(@menuButton)

    Logger.logEvent("Leaving The Mission from challenge")
    Logger.send()

  _initMenus: ->
    @m1 = @_getM("Exterminate all fungus.",
      () =>
        @m1.close()
    )
    @m1.open()

    restart = () => newMission(Cutscene)
    next = () => newMission(Menu)
    @victoryMenu = @createVictoryMenu(restart, next)
    @failMenu = @createFailMenu(restart)
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
    hasFungus = false
    for p in game.getPlanets()
      if p.fungusStrength() > 0
        hasFungus = true

    hasAnything = false
    for p in game.getPlanets()
      if p.getControlGroups().length > 0 or p.humansOnPlanet() or
          p.hasStation() or p.hasOutpost()
        hasAnything = true
        break

    if not hasFungus
      if not @gameEnded
        @endTime = currentTime()
        randSave = Math.random
        Math.seedrandom()
        ga('send', {
          'hitType': 'event',
          'eventCategory': "The Mission Challenge",
          'eventAction': 'Complete',
          'eventLabel': 'Victory',
          'dimension1': "The Mission Challenge",
          'metric5': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': "The Mission Challenge",
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Victory'
        })
        Math.random = randSave
        Logger.logEvent("Player successfully completed " + "The Mission Challenge",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns})
      @gameEnded = true
      UI.endGame()
      @victoryMenu.open()

    if not hasAnything
      if not @gameEnded
        @endTime = currentTime()
        randSave = Math.random
        Math.seedrandom()
        ga('send', {
          'hitType': 'event',
          'eventCategory': "The Mission Challenge",
          'eventAction': 'Complete',
          'eventLabel': 'Fail',
          'dimension1': "The Mission Challenge",
          'metric6': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': "The Mission Challenge",
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Fail'
        })
        Math.random = randSave
        Logger.logEvent("Player failed " + "The Mission Challenge",
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns})
      @gameEnded = true
      UI.endGame()
      @failMenu.open()
