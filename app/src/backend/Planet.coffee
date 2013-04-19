#Defines a class to represent planets

class Planet
  constructor: (@_x, @_y, @_resources = 0, @_rate = 0) ->
    @_adjacentPlanets = []
    @_fungusStrength = 0
    @_fungusMaximumStrength = 0
    @_fungusArriving = 0
    @_fungusLeaving = 0
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

  growPass1: ->
    if @_fungusStrength >= @_fungusMaximumStrength
      # Spore
      for i in [2..@_fungusStrength]
        planet = @_adjacentPlanets[Math.floor(Math.random() * @_adjacentPlanets.length)]
        if planet._fungusStrength - planet._fungusLeaving + planet._fungusArriving < planet._fungusMaximumStrength
          # this DOES introduce dependence on what order grow is called on planets, but it should be okay
          planet._fungusArriving++
          @_fungusLeaving++
    else
      # Grow
      @_fungusArriving += if Math.random() >= 0 then 1 else 0

  growPass2: ->
    @_fungusStrength -= @_fungusLeaving
    @_fungusLeaving = 0
    @_fungusStrength += @_fungusArriving
    @_fungusArriving = 0

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
    
    








		

