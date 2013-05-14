#_require Mission

# This mission acts as our games main menu
class Extermination extends Mission
  #settings: window.config.MainMenu
  size: ""
  numPlanets: 0
  restart: null

  # @see Mission#reset
  reset: ->
    @attemptName = "extermination_"+@size+"_attempts"
    @mission = "Extermination " + @size
    @attempts = localStorage[@attemptName]

    if not @attempts
      @attempts = 0
    @attempts++
    localStorage[@attemptName] = Number(@attempts)
    Logger.logEvent("Starting " + @mission, {attempt: @attempts})
    console.log('1: ' + Math.random())
    randSave = Math.random
    Math.seedrandom()
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': @mission,
      'eventAction': 'Start'
      'dimension1': @mission,
      'metric1': 1
    })
    Math.random = randSave

    newGame(10000, 10000)
    # Create planets:
    @home = game.setup(@numPlanets)
    @home.addStation()

    UI.initialize()
    camera.setZoom(0.1)
    camera.setZoomTarget(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)
    cameraHudFrame.removeChild(@optionsMenu)
    frameElement.removeChild(@menuButton)

    Logger.logEvent("Leaving " + @mission)
    Logger.send()

  _initMenus: ->
    restart = () => newMission(@restart)
    next = () => newMission(Menu)
    @victoryMenu = @createVictoryMenu(restart, next)
    @failMenu = @createFailMenu(restart)
    @optionsMenu = @createOptionMenu(restart)
    @menuButton = @createMenuButton(@optionsMenu)

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->
    # if drawing a prompt
    #   check mouse position against the button positions

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

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
         #p.numShips(window.config.units.probe) > 0 or
         #p.numShips(window.config.units.colonyShip) > 0 or
         #p.numShips(window.config.units.attackShip) > 0 or
         #p.numShips(window.config.units.defenseShip) > 0
        hasAnything = true
        break

    if not hasFungus
      if not @gameEnded
        @endTime = currentTime()
        randSave = Math.random
        Math.seedrandom()
        ga('send', {
          'hitType': 'event',
          'eventCategory': @mission,
          'eventAction': 'Complete',
          'eventLabel': 'Victory',
          'dimension1': @mission,
          'metric5': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': @mission,
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Victory'
        })
        Math.random = randSave
        Logger.logEvent("Player successfully completed " + @mission,
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
          'eventCategory': @mission,
          'eventAction': 'Complete',
          'eventLabel': 'Fail',
          'dimension1': @mission,
          'metric6': 1,
          'metric2': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': @mission,
          'timingVar': 'Complete',
          'timingValue': @endTime - @startTime,
          'timingLabel': 'Fail'
        })
        Math.random = randSave
        Logger.logEvent("Player failed " + @mission,
                        {minutes: getMinutes(@endTime - @startTime)
                        turns: UI.turns})
      @gameEnded = true
      UI.endGame()
      @failMenu.open()