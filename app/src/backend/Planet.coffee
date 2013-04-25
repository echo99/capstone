#Defines a class to represent planets

root = exports ? window

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
    @_visibility = window.config.visibility.invisible

  # GETTERS #

  location: ->
    return {x: @_x, y: @_y}

  resources: ->
    return resources

  availableResources: ->
    return availableResources

  visibility: ->
    return @_visibility

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
        planet = @_adjacentPlanets[Math.floor(
          Math.random() * @_adjacentPlanets.length)]
        if planet._fungusStrength - planet._fungusLeaving +
            planet._fungusArriving < planet._fungusMaximumStrength
          # this DOES introduce dependence on what order grow is called on planets,
          # but it should be okay
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
    # check for insufficient ships
    if attackShips > @_attackShips or
       defenseShips > @_defenseShips or
       probes > @_probes or
       colonies > @_colonies
      throw error "Insufficient Ships"
    else
      # generate control group
      controlGroup = new ControlGroup(attackShips, defenseShips, probes, colonies, dest)
      # update planet
      @_attackShips -= attackShips
      @_defenseShips -= defenseShips
      @_probes -= probes
      @_colonies -= colonies
      # add to planet
      @_controlGroups.push(controlGroup)

  # SETTERS FOR USE BY GUI #

  setVisibility: (state) ->
    if (state is window.config.visibility.visible) or
       (state is window.config.visibility.fungus) or
       (state is window.config.visibility.nonfungus) or
       (state is window.config.visibility.invisible)
      @_visibility = state
    else
      throw error "Invalid Visibility"

  # SETTERS FOR USE BY GAME CLASS #

  addNeighbor: (otherplanet) ->
    @_adjacentPlanets.push(otherplanet)
    otherplanet._adjacentPlanets.push(@)

  # HELPER FUNCTIONS #

  move: (group) ->
    if not group.moved
      group.setMoved
      if ((group.destination is @) and (group.destination is group.next))
        @_attackShips += group.attackShips
        @_defenseShips += group.defenseShips
        @_probes += group.probes
        @_colonies += group.colonies
      else
        group.next.receiveGroup(group)
      @_controlGroups.filter(group)

  receiveGroup: (group) ->
    @_controlGroups.push(group)


root.Planet = Planet
