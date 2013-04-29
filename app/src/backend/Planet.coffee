#Defines a class to represent planets

if not root?
  root = exports ? window

if exports?
  {config} = require '../config'
  root.config = config

#_require ControlGroup

class Planet
  constructor: (@_x, @_y, @_resources = 0, @_rate = 0) ->
    @_lastSeenResources = null
    @_lastSeenFungus = false
    @_hasBeenSeen = false
    @_availableResources = 0
    @_adjacentPlanets = []
    @_fungusStrength = 0
    @_fungusMaximumStrength = 0
    @_fungusArriving = 0
    @_fungusLeaving = 0
    @_attackShips = 0
    @_defenseShips = 0
    @_probes = 0
    @_colonies = 0
    @_outpost = false
    @_station = false
    @_controlGroups = []
    @_unitConstructing = null
    @_turnsToComplete = 0
    @_visibility = root.config.visibility.invisible

  # GETTERS #

  location: ->
    return {x: @_x, y: @_y}

  resources: ->
    return @_lastSeenResources

  availableResources: ->
    return @_availableResources

  visibility: ->
    return @_visibility

  numShips: (type) ->
    return switch type
      when root.config.units.probe then @_probes
      when root.config.units.colonyShip then @_colonies
      when root.config.units.attackShip then @_attackShips
      when root.config.units.defenseShip then @_defenseShips
      else throw new Error("Ship type unknown.")

  fungusStrength: ->
    return @_fungusStrength

  hasOutpost: ->
    return @_outpost

  hasStation: ->
    return @_station

  getAdjacentPlanets: ->
    return @_adjacentPlanets

  getControlGroups: ->
    return @_controlGroups

  buildStatus: ->
    return @_turnsToComplete

  buildUnit: ->
    return @_unitConstructing

  isBuilding: ->
    if @_unitConstructing is null or @_turnsToComplete is 0
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
    fungusDamage = 0
    humanDamage = 0
    fungusDefense = 0
    humanDefense = 0
    # Roll for damage
    fungusDamage += @rollForDamage(root.config.units.fungus.attack,
                                   @_fungusStrength)
    humanDamage += @rollForDamage(root.config.units.attackShip.attack,
                                  @_attackShips)
    humanDamage += @rollForDamage(root.config.units.defenseShip.attack,
                                  @_defenseShips)
    humanDamage += @rollForDamage(root.config.units.colonyShip.attack,
                                  @_colonyShips)
    humanDamage += @rollForDamage(root.config.units.probe.attack, @_probes)
    # Roll for defense rating
    fungusDefense += @rollForDamage(root.config.units.fungus.defense,
                                    @_fungusStrength)
    humanDefense += @rollForDamage(root.config.units.attackShip.defense,
                                   @_attackShips)
    humanDefense += @rollForDamage(root.config.units.defenseShip.defense,
                                   @_defenseShips)
    humanDefense += @rollForDamage(root.config.units.colonyShip.defense,
                                   @_colonyShips)
    humanDefense += @rollForDamage(root.config.units.probe.defense, @_probes)
    # Apply defensive ratings to damage
    fungusDamage -= humanDefense
    humanDamage -= fungusDefense
    if fungusDamage < 0
      fungusDamage = 0
    if humanDamage < 0
      humanDamage = 0
    # Destroy units
    if @_fungusStrength >= humanDamage
      @_fungusStrength -= humanDamage
    else
      @_fungusStrength = 0
    # Destroy attack ships first
    if @_attackShips >= fungusDamage
      @_attackShips -= fungusDamage
      return null
    @_attackShips = 0
    fungusDamage -= @_attackShips
    # Destroy defense ships second
    if @_defenseShips >= fungusDamage
      @_defenseShips -= fungusDamage
      return null
    @_defenseShips = 0
    fungusDamage -= @_defenseShips
    # Destroy probes third
    if @_probes >= fungusDamage
      @_probes -= fungusDamage
      return null
    @_probes = 0
    fungusDamage -= @_probes
    # Destroy colony ships last
    if @_colonyShips >= fungusDamage
      @_colonyShips -= fungusDamage
      return null
    @_colonyShips = 0
    fungusDamage -= @_colonyShips
    # If there is any leftover fungus damage
    # then destroy all structures
    if fungusDamage > 0
      @_station = false
      @_outpost = false

  buildUpkeep: ->
    if @_turnsToComplete >= 1
      @_turnsToComplete--
      if @_turnsToComplete == 0
        unit = @_unitConstructing
        @_unitConstructing = null
        switch unit
          when root.config.units.probe then @_probes++
          when root.config.units.colonyShip then @_colonies++
          when root.config.units.attackShip then @_attackShips++
          when root.config.units.defenseShip then @_defenseShips++
          else throw new Error("Ship type unknown.")

  movementUpkeep1: ->
    @move(group) for group in @_controlGroups

  movementUpkeep2: ->
    group.resetMoved() for group in @_controlGroups

  visibilityUpkeep: ->
    # Update last seen in case a tracked planet becomes untracked
    if @_visibility = root.config.visibility.visible
      @_lastSeenFungus = @_fungusStrength
      @_lastSeenResources = @_resources
    # If it has probes:
    if @_probes > 0
      # If it isn't visible make it visible
      if @_visibility != root.config.visibility.visible
        @_lastSeenFungus = @_fungusStrength
        @_lastSeenResources = @_resources
        @_visibility = root.config.visibility.visible
    # If it is adjacent to a probe:
    else if neighborsHaveProbes()
      # Mark that this planet has been seen
      if !@_hasBeenSeen
        @_hasBeenSeen = true
      # Set visibility based on actual fungus strength
      if @_fungusStrength > 0
        @_visibility = root.config.visibility.fungus
      else
        @_visibility = root.config.visibility.nonfungus
    # If it is not adjacent to a probe:
    else
      # If it has never been seen it is invisible
      if !@_hasBeenSeen
        @_visibility = root.config.visibility.invisible
      # If it has been seen set visibility based on last seen fungus strength
      else
        if @_lastSeenFungus > 0
          @_visibility = root.config.visibility.fungus
        else
          @_visibility = root.config.visibility.nonfungus
    checkRepresentationalInvariants()



  updateAI: ->
    group.updateAi(@) for group in @_controlGroups

  # INGAME COMMANDS #

  build: (name) ->
    if @_unitConstructing != null or @_turnsToComplete != 0
      throw new Error("Planet is already constructing something else.")
    else if @_availableResources < name.cost
      throw new Error("Not enough available resources.")
    else
      @_unitConstructing = name
      @_availableResources -= name.cost
      @_turnsToComplete = name.turns

  moveShips: (attackShips, defenseShips, probes, colonies, dest) ->
    # check for insufficient ships
    if attackShips > @_attackShips or
       defenseShips > @_defenseShips or
       probes > @_probes or
       colonies > @_colonies
      throw error "Insufficient Ships"
    else
      # generate control group
      controlGroup = new ControlGroup(attackShips, defenseShips,
                                      probes, colonies, dest)
      # update planet
      @_attackShips -= attackShips
      @_defenseShips -= defenseShips
      @_probes -= probes
      @_colonies -= colonies
      controlGroup.updateAi(@)
      # add to planet
      @_controlGroups.push(controlGroup)

  # SETTERS FOR USE BY GUI #

  setVisibility: (state) ->
    if (state is root.config.visibility.visible) or
       (state is root.config.visibility.fungus) or
       (state is root.config.visibility.nonfungus) or
       (state is rootb.config.visibility.invisible)
      @_visibility = state
    else
      throw error "Invalid Visibility"

  # SETTERS FOR USE BY GAME CLASS #

  addNeighbor: (otherplanet) ->
    @_adjacentPlanets.push(otherplanet)
    otherplanet._adjacentPlanets.push(@)

  # HELPER FUNCTIONS #

  move: (group) ->
    if not group.moved()
      group.setMoved()
      if ((group.destination() is @) and (group.destination() is group.next()))
        @_attackShips += group.attackShips()
        @_defenseShips += group.defenseShips()
        @_probes += group.probes()
        @_colonies += group.colonies()
      else
        group.next().receiveGroup(group)
      @_controlGroups = @_controlGroups.filter((g) => g != group)

  receiveGroup: (group) ->
    @_controlGroups.push(group)

  rollForDamage: (power, quantity) ->
    total = 0
    for x in [0...quantity] by 1
      roll = Math.random()
      if roll >= power
        total++
    return total

  neighboursHaveProbes: ->
    for planet in @_adjacentPlanets
      if planet.numShips(root.config.units.probe) > 0
        return true
    return false

  checkRepresentationalInvariants: ->
    if @_attackShips < 0
      throw error "Less than 0 attack ships"
    if @_defenseShips < 0
      throw error "Less than 0 defense ships"
    if @_probes < 0
      throw error "Less than 0 probes"
    if @_colonys < 0
      throw error "less than 0 colony ships"
    if @_fungusStrength
      throw error "negative fungus strength"
    for planet in @_adjacentPlanets
      if !planet._adjacentPlanets.contains(@)
        throw error "we have a directed graph somehow"
    if @_visibility = root.config.visibility.visible
      if @_lastSeenResources != @_resources
        throw error "last seen resources don't match. Status: visible"
      if @_lastSeenFungus != @_fungusStrength
        throw error "last seen fungus dosn't match. Status: visible"
    if @_visibility = root.config.visibility.invisible and
       @_hasBeenSeen != false
      throw error "seen planet is invisible"
    if @_visibility = root.config.visibility.fungus and @_lastSeenFungus < 1
      throw error "incorrectly remembering planet as having had fungus"
    if @_visibility = root.config.visibility.nonfungus and @_lastSeenFungus > 0
      throw error "incorrectly remembering planet as having not had fungus"



root.Planet = Planet
