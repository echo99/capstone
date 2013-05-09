#_require Mission

# This mission acts as our games main menu
class Extermination extends Mission
  #settings: window.config.MainMenu

  # @see Mission#reset
  reset: ->
    @gameEnded = false
    ga('send', {
      'hitType': 'event',
      'eventCategory': 'Mission',
      'eventAction': 'Start'
      'eventLabel': 'Extermination'
      'dimension1': 'Extermination',
      'metric1': 1
    })

    newGame(10000, 10000)

    # Create planets:
    @home = game.setup(30)
    @home.addStation()

    # Test stuff
    #@home.getAdjacentPlanets()[0].addOutpost()
    #@home.addShips(window.config.units.probe, 8)
    #@home.addShips(window.config.units.colonyShip, 10)
    #@home.addShips(window.config.units.attackShip, 10)
    #@home.addShips(window.config.units.defenseShip, 10)
    # End test stuff

    UI.initialize()
    camera.setZoom(0.5)
    camera.setTarget(@home.location())

    @_initMenus()

    @startTime = currentTime()

  destroy: ->
    cameraHudFrame.removeChild(@victoryMenu)
    cameraHudFrame.removeChild(@failMenu)

  _initMenus: ->
    @victoryMenu = @createVictoryMenu(
      () =>
        console.log('restart extermination')
        newMission(Extermination)
      () =>
        console.log('to next mission')
        newMission(Menu)
    )
    @failMenu = @createFailMenu(
      () =>
        console.log('restart extermination')
        newMission(Extermination)
    )

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
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission',
          'eventAction': 'Victory',
          'eventLabel': 'Extermination',
          'dimension1': 'Extermination',
          'metric5': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson',
          'timingVar': 'Victory',
          'timingValue': getMinutes(@endTime - @startTime),
          'timingLabel': 'Extermination'
        })
      @gameEnded = true
      UI.endGame()
      @victoryMenu.open()

    if not hasAnything
      if not @gameEnded
        @endTime = currentTime()
        ga('send', {
          'hitType': 'event',
          'eventCategory': 'Mission',
          'eventAction': 'Fail',
          'eventLabel': 'Extermination',
          'dimension1': 'Extermination',
          'metric6': 1
        })
        ga('send', {
          'hitType': 'timing',
          'timingCategory': 'Misson',
          'timingVar': 'Fail',
          'timingValue': getMinutes(@endTime - @startTime),
          'timingLabel': 'Extermination'
        })
      @gameEnded = true
      UI.endGame()
      @failMenu.open()