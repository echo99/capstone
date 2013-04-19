#Defines a class to represent planets

class Planet
  constructor: (@_x, @_y, @_resources = 0, @_rate = 0) ->
    @_adjacentPlanets = []
    @_fungusStrength = 0
    @_attackShips = 0
    @_defenseShips = 0
    @_probes = 0
    @_colonys = 0
    @_outpost = false
    @_station = false
    @_controlGroups = []
    @_unitConstructing = null
    @_turnsToComplete = 0

  # GETTERS #

  location: ->
    return {x: @_x, y: @_y}

  numShips: (type) ->
    return null

  fungusStrength: ->
    return null

  hasOutpost: ->
    return null

  hasStation: ->
    return null

  getAdjacentPlanets: ->
    return []

  getControlGroups: ->
    return []

  buildStatus: ->
    return null

  buildUnit: ->
    return null

  isBuilding: ->
    if turnstocomplete is 0
      return false
    else
      return true

  # UPKEEP #

  grow: ->
    null

  resolveCombat: ->
    null

  # INGAME COMMANDS #

  build: (name) ->
    null

  move: (dest) ->
    null

  # SETTERS FOR USE BY GAME CLASS #
  
  addNeighbor: (otherplanet) ->
    
    








		

