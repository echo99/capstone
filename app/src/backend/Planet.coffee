if not root?
  root = exports ? window

if exports?
  {config} = require '../config'
  root.config = config

#_require ControlGroup

# Defines a class to represent planets
#
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
    @_visibility = root.config.visibility.undiscovered

  # GETTERS #

  # Returns the (x, y) location of the planet.
  #
  # @return [{x: ..., y: ...}] Location of planet
  #
  location: ->
    return {x: @_x, y: @_y}

  # Returns the distance between this planet and the specified planet.
  #
  # @param [Planet] planet The other planet
  #
  # @return [Double] The distance between this planet and the specified planet.
  #
  distance: (planet) ->
    oX = planet.location.x
    oY = planet.location.y
    return sqrt(Math.pow(@_x - oX, 2) + Math.pow(@_y - oY, 2))

  # Returns the last-known amount of (unharvested) resources left on the planet.
  # This resource count is updated if a probe or outpost/station is on the planet.
  #
  # @return [Integer] The last-known count of (unharvested) resources left on the planet.
  #
  resources: ->
    return @_lastSeenResources

  # Returns the amount of usable resources on the planet's station,
  # or zero if no station exists.
  #
  # @return [Integer] The amount of usable resources on the planet.
  #
  availableResources: ->
    return @_availableResources

  # Returns the current visibility state of the planet.
  #
  # @return [root.config.visibility.*] The current visibility state of the planet.
  #
  visibility: ->
    return @_visibility

  # Returns the current number of ships on the planet of the specified type.
  #
  # @param [root.config.units.*] type The specified type
  #
  # @return [Integer] The number of ships of the specified type.
  #
  # @throw [Error] If the ship type is not one of root.config.units.*
  #
  numShips: (type) ->
    return switch type
      when root.config.units.probe then @_probes
      when root.config.units.colonyShip then @_colonies
      when root.config.units.attackShip then @_attackShips
      when root.config.units.defenseShip then @_defenseShips
      else throw new Error("Ship type unknown.")

  # Returns the current fungus strength on the planet.
  #
  # @return [Integer] The current fungus strength.
  #
  fungusStrength: ->
    return @_fungusStrength

  # Returns whether the planet has an outpost.
  #
  # @return [Boolean] True if the planet has an outpost.
  #
  hasOutpost: ->
    return @_outpost

  # Returns whether the planet has a station.
  #
  # @return [Boolean] True if the planet has a station.
  #
  hasStation: ->
    return @_station

  # Returns a list of planets adjacent to this one.
  #
  # @return [List] A list of planets adjacent to this one.
  #
  getAdjacentPlanets: ->
    return @_adjacentPlanets

  # Returns the list of control groups stationed at this planet.
  #
  # @return [List] The list of control groups stationed at this planet.
  getControlGroups: ->
    return @_controlGroups

  # Returns the number of turns left for construction to complete
  # on this planet, or 0 if nothing is being constructed.
  #
  # @return [Integer] The number of turns left for construction.
  #
  buildStatus: ->
    return @_turnsToComplete

  # Returns the type of unit being constructed, or null if no unit is being
  # constructed.
  #
  # @return [root.config.units.*] The type of unit being constructed
  #
  buildUnit: ->
    return @_unitConstructing

  # Returns whether a unit is being constructed at this planet.
  #
  # @return [Boolean] True if a unit is being constructed.
  #
  isBuilding: ->
    if @_unitConstructing is null or @_turnsToComplete is 0
      return false
    else
      return true

  # SETTERS #

  # Immediately adds the specified number of the specified type of ship to
  # those on the planet.  This does not incur a resource cost or build delay.
  #
  # @param [root.config.unit.*] type The type of ship to build.
  # @param [Integer] number The number of ships to build.
  #
  # @throw [Error] if type is not one of root.config.unit.*
  #
  addShips: (type, number) ->
    switch type
      when root.config.units.probe
        @_probes += number
      when root.config.units.colonyShip
        @_colonies += number
      when root.config.units.attackShip
        @_attackShips += number
      when root.config.units.defenseShip
        @_defenseShips += number
      else throw new Error("Ship type unknown.")

  # UPKEEP #

  # Fungus growth phase 1.
  # Determines growth and sporing for next turn.
  #
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

  # Fungus growth phase 2.
  # Applies fungus changes determined from pass 1.
  #
  growPass2: ->
    @_fungusStrength -= @_fungusLeaving
    @_fungusLeaving = 0
    @_fungusStrength += @_fungusArriving
    @_fungusArriving = 0

  # Resolves combat between player/fungus on a planet.
  #
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
      @_turnsToComplete = 0
      @_unitConstructing = null

  # Build upkeep method.
  # Called at the end of turn to advance building on the unit under
  # construction.
  #
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

  # Movement phase 1.
  # Moves control groups.
  #
  movementUpkeep1: ->
    @move(group) for group in @_controlGroups

  # Movement phase 2.
  # Resets all control groups to allow movement again.
  #
  movementUpkeep2: ->
    group.resetMoved() for group in @_controlGroups

  # Visibility upkeep method.
  # Updates visibility status and last-known values to reflect planet
  # visibility.
  #
  visibilityUpkeep: ->
    # If it has probes:
    if @_probes > 0 or @_station or @_outpost
      # If it isn't visible make it visible and update both last seen.
      if !@_hasBeenSeen
        @_hasBeenSeen = true
      @_lastSeenFungus = @_fungusStrength
      @_lastSeenResources = @_resources
      @_visibility = root.config.visibility.visible
    # If it is adjacent to a probe:
    else if @neighborsHaveProbes()
      # If it isn't visible make it visible and update fungus
      if !@_hasBeenSeen
        @_hasBeenSeen = true
      @_lastSeenFungus = @_fungusStrength
      @_visibility = root.config.visibility.visible
    # If it is not adjacent to a probe:
    else
      # If it has never been seen it is invisible
      if !@_hasBeenSeen
        @_visibility = root.config.visibility.undiscovered
      # If it has been seen it is discovered
      else
        @_visibility = root.config.visibility.discovered
    # Check to be sure that we aren't displaying the wrong thing
    if @_visibility == root.config.visibility.visible
      if @_lastSeenResources != @_resources and @_probes > 0
        throw new Error "last seen resources don't match but we have a probe."
      if @_lastSeenFungus != @_fungusStrength
        throw new Error "last seen fungus dosn't match."
    @checkRepresentationalInvariants()

  # Causes control groups to recalculate paths to their destinations
  # based on currently-known information.
  #
  updateAI: ->
    group.updateAi(@) for group in @_controlGroups

  # INGAME COMMANDS #

  build: (name) ->
    if @_station = false
      throw new Error("Planet has no station to build ships.")
    else if @_unitConstructing != null or @_turnsToComplete != 0
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
       (state is root.config.visibility.discovered) or
       (state is root.config.visibility.undiscovered)
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
        console.log('arrived at ' + @_x + ", " + @_y)
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

  neighborsHaveProbes: ->
    for planet in @_adjacentPlanets
      if planet.numShips(root.config.units.probe) > 0
        return true
    return false

  checkRepresentationalInvariants: ->
    if @_attackShips < 0
      throw new Error "Less than 0 attack ships"
    if @_defenseShips < 0
      throw new Error "Less than 0 defense ships"
    if @_probes < 0
      throw new Error "Less than 0 probes"
    if @_colonys < 0
      throw new Error "less than 0 colony ships"
    if @_fungusStrength < 0
      throw new Error "negative fungus strength"
    for planet in @_adjacentPlanets
      if !(@ in planet._adjacentPlanets)
        throw new Error "we have a directed graph somehow"
    if @_visibility == root.config.visibility.undiscovered and
       @_hasBeenSeen != false
      throw new Error "seen planet is undiscovered"


root.Planet = Planet
