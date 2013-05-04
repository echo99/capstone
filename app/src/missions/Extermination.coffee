#_require Mission

# This mission acts as our games main menu
class Extermination extends Mission
  #settings: window.config.MainMenu

  # @see Mission#reset
  reset: ->
    # Create planets:
    #game.setup(10, null)
    #return
    newGame(10000, 10000)
    @home = game.setup(10)
    @home._station =true
    @home._availableResources = 30

    # Test stuff
    @home.getAdjacentPlanets()[0]._outpost = true
    @home.getAdjacentPlanets()[0]._availableResources = 30
    @home._unitConstructing = window.config.units.attackShip
    @home._turnsToComplete = window.config.units.attackShip.turns
    # End test stuff

    UI.initialize()
    camera.setZoom(0.5)
    camera.setTarget(@home.location())

  # @see Mission#draw
  draw: (ctx, hudCtx) ->

  # @see Mission#onMouseMove
  onMouseMove: (x, y) ->
    # if drawing a prompt
    #   check mouse position against the button positions

  # @see Mission#onMouseClick
  onMouseClick: (x, y) ->

  getHomeTarget: ->
    # TODO: come up with smarter target
    return @home.location()

  # @see Mission#onEndTurn
  onEndTurn: ->
    # TODO: check for end game
    if @home.numShips(window.config.units.probe) > 10
      UI.endGame()
      newMission(Menu)