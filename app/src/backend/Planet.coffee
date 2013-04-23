#Defines a class to represent planets

#_require ControlGroup

class Planet
  constructor: (@_x, @_y, @_resources = 0, @_rate = 0) ->
    @_availableResources = 0
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

  resources: ->
    return resources

  availableResources: ->
    return availableResources

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
    if @_turnstocomplete is 0
      return false
    else
      return true

  # UPKEEP #

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

  resolveCombat: ->
    null

  buildUpkeep: ->
    null

  movementUpkeep1: ->
    group.updateAi for group in @_controlGroups
    move group for group in @_controlGroups

  movementUpkeep2: ->
    group.resetMoved for group in @_controlGroups
	  
  # INGAME COMMANDS #

  build: (name) ->
    null

  move: (attackShips, defenseShips, probes, colonies, dest) ->
    controlGroup = new ControlGroup(attackShips, defenseShips, probes, colonies, dest)
    @_controlGroups.push(controlGroup)
    
  # SETTERS FOR USE BY GAME CLASS #

  addNeighbor: (otherplanet) ->
    @_adjacentPlanets.push(otherplanet)
    otherplanet._adjacentPlanets.push(@)
    
  # HELPER FUNCTIONS #

  move: (group) ->
    if not group.moved
      group.setMoved
      @_controlGroups.filter(group)
      group.next.receiveGroup(group)

  receiveGroup: (group) ->
    @_controlGroups.push(group)










		

