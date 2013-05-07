if not root?
  root = exports ? window

if exports?
  {config} = require '../config'
  root.config = config

#_require ControlGroup

# Defines a class to represent planets
#
class Planet
  # Sets the coordinate location, starting resources, and rate of harvest.
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

  # Returns the string representation of the planet.
  #
  # @return [String] String representation of planet
  #
  toString: ->
    return "Planet(#{@_x}, #{@_y}, #{@_resources}, #{@_rate})"

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
    oX = planet.location().x
    oY = planet.location().y
    return Math.sqrt(Math.pow(@_x - oX, 2) + Math.pow(@_y - oY, 2))

  # Returns the last-known amount of (unharvested) resources left on the planet.
  # This resource count is updated if a probe or outpost/station is on the planet.
  #
  # @return [Integer] The last-known count of (unharvested) resources
  # left on the planet.
  #
  resources: ->
    return @_lastSeenResources

  # Returns the resource collection rate of the planet.
  #
  # @return [Integer] The planet's rate.
  #
  rate: ->
    return @_rate

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

  # SETTERS FOR USE BY GUI #

  # Sets the visibility state to either visible, discovered or undiscovered
  #
  setVisibility: (state) ->
    if (state is root.config.visibility.visible) or
       (state is root.config.visibility.discovered) or
       (state is root.config.visibility.undiscovered)
      @_visibility = state
    else
      throw Error "Invalid Visibility"


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

  # Sets fungus strength
  setFungus: (amount) ->
    @_fungusStrength = amount

  # Adds a station
  #
  # @throw [Error] if there is already a station.
  addStation: ->
    if !@_station and !@_outpost
      @_station = true
    else
      throw new Error("Attempting to build a station where a building exists")

  # Adds an outpost
  #
  # @throw [Error] if there is already an outpost.
  addOutpost: ->
    if !@_station and !@_outpost
      @_outpost = true
    else
      throw new Error("Attempting to build an outpost where a building exists")

  # Removes all buildings
  #
  # @throw [Error] if there are not buildings.
  removeStructures: ->
    if @_station or @_outpost
      @_station = false
      @_outpost = false
    else
      throw new Error("Attempting to remove building that ain't there")

  # Builds outpost sacrificing a probe and a colony ship.
  #
  # @throw [Error] if there is insufficient ships or a building already.
  scheduleOutpost: ->
    if !@_station and !@_outpost and @_probes > 0 and @_colonies > 0
      @_unitConstructing = root.config.structures.outpost
      @_turnsToComplete = root.config.structures.outpost.turns
      @_probes -= 1
      @_colonies -= 1
    else
      throw new Error("Invalid outpost construction -" +
                    " probes: " + @_probes +
                    " colonies: " + @_colonies +
                    " station: " + @_station +
                    " outpost: " + @_outpost)


  # Builds station sacrificeing outpost and resources
  #
  # @throw [Error] if there is no outpost or insufficient resources.
  scheduleStation: ->
    if !@_station and @_availableResources >= root.config.structures.station.cost
      @_unitConstructing = root.config.structures.station
      @_turnsToComplete = root.config.structures.station.turns
      @_availableResources -= root.config.structures.station.cost
      @_outpost = false
    else
      throw new Error("Invalid outpost construction -" +
                    " resources: " + @_availableResources +
                    " station: " + @_station +
                    " outpost: " + @_outpost)

  # Build unit
  #
  # @throw [Error] if the unit is not valid or there is not enough resources.
  scheduleUnit: (unit) ->
    if isStructure == undefined
      throw new Error("This is not a unit.")
    if isStructure
      throw new Error("This is a structure.")
    if unit.cost > @_availableResources
      throw new Error("Not enough resources to build a " + unit)
    @_unitConstructing = unit
    @_turnsToComplete = unit.turns

  # Cancels the current building unit.
  #
  # @throw [Error] if there is no unit building
  cancelConstruction: ->
    if @_unitConstructing == null and @_turnsToComplete == 0
      throw new Error("Tried to cancel when not constructing")
    else
      @_unitConstructing = null
      @_turnsToComplete = 0

  # Cancel control group.
  #
  # @throw [Error] if there is no such control group
  cancelControlGroup:(group) ->
    if group in @_controlGroups
      @_controlGroups = @_controlGroups.filter((g) => g != group)
      @_attackShips += group.attackShips()
      @_defenseShips += group.defenseShips()
      @_colonies += group.colonies()
      @_probes += group.probes()
    else
      throw new Error("Tried to remove control group that doesn't exist")

  # UPKEEP #


  # Increases available resources and decreases resources by the rate
  # if there is a structure.
  gatherResources: ->
    if @_outpost or @_station
      if @_resources > 0
        @_availableResources += @_rate
        @_resources -= @_rate

  # Fungus growth phase 1.
  # Determines growth and sporing for next turn.
  #
  growPass1: ->
    if @_fungusStrength > 0
      @_fungusStrength += root.config.units.fungus.growthPerTurn
    if @_fungusStrength >= @_fungusMaximumStrength and @_adjacentPlanets.length > 0
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
    else if @_fungusStrength < @_fungusMaximumStrength
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
        if unit.isStructure == undefined
          throw new Error("Invalid unit, not of buildable type")
        @_unitConstructing = null
        if unit.isStructure
          switch unit
            when root.config.structures.outpost then @_outpost = true
            when root.config.structures.station then @_station = true
            when root.config.structures.warpgate then @_warpgate = true
            else throw new Error("Invalid structure, it ain't one.")
        else
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
  # Reintegrates control groups that have reached their destination.
  #
  movementUpkeep2: ->
    for group in @_controlGroups
      group.resetMoved()
      console.log("reset id: " + group._id)
      if group.destination() is @
        @_attackShips += group.attackShips()
        @_defenseShips += group.defenseShips()
        @_probes += group.probes()
        @_colonies += group.colonies()
        @_controlGroups = @_controlGroups.filter((g) => g != group)

  # Visibility upkeep method.
  # Updates visibility status and last-known values to reflect planet
  # visibility.
  #
  visibilityUpkeep: ->
    # If it has probes:
    if @_probes > 0 or
       @_attackShips > 0 or
       @_defenseShips > 0 or
       @_colonies or
       @_station or @_outpost
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
    #console.log("updating control groups in planet " + @toString())
    group.updateAi(@) for group in @_controlGroups
    #console.log("done updating control groups")

  # INGAME COMMANDS #

  # Causes a unit to be built, sets relevant fields.
  #
  # @param [String] name The type of unit to be built.
  #
  # @throw [Error] If there is no station.
  # @throw [Error] If construction is already under way.
  # @throw [Error] If there are not enough resources.
  build: (name) ->
    if @_station == false
      throw new Error("Planet has no station to build ships.")
    else if @_unitConstructing != null or @_turnsToComplete != 0
      throw new Error("Planet is already constructing something else.")
    else if @_availableResources < name.cost
      throw new Error("Not enough available resources.")
    else
      @_unitConstructing = name
      @_availableResources -= name.cost
      @_turnsToComplete = name.turns


  # Creates a control group at the current planet.
  # Does nothing if dest == @.
  #
  # @param [Integer] attackShips Number of attack ships to add to control group.
  # @param [Integer] defenseShips Number of defense ships to add to control group.
  # @param [Integer] probes Number of probes to add to control group.
  # @param [Integer] colonies Number of colony ships to add to control group.
  # @param [Planet] dest The control group's intended destination.
  #
  # @throw [Error]  If there are not enough ships on the planet.
  moveShips: (attackShips, defenseShips, probes, colonies, dest) ->
    # Check for trivial case
    if dest == @
      return null
    # check for insufficient ships
    if attackShips > @_attackShips or
         defenseShips > @_defenseShips or
         probes > @_probes or
         colonies > @_colonies
      throw Error "Insufficient Ships"
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
      #console.log("Adding control group to planet " + @toString())
      @_controlGroups.push(controlGroup)
      #console.log("Control groups: " + @_controlGroups)

  # SETTERS FOR USE BY GAME CLASS #

  # Creates a two-way link between this planet and another.
  #
  # @param [Planet] otherPlanet The planet to connect to @.
  addNeighbor: (otherplanet) ->
    @_adjacentPlanets.push(otherplanet)
    otherplanet._adjacentPlanets.push(@)

  # HELPER FUNCTIONS #

  # Moves a control group to it's next intermediate destination.
  #
  # @param [ControlGroup] group The group to be moved.

  move: (group) ->
    if !group.moved()
      console.log("Trying to move: group id: " + group._id)
      group.setMoved()
      if !(group.destination() is @)
        group.next().receiveGroup(group)
        @_controlGroups = @_controlGroups.filter((g) => g != group)

  # Adds a given group to the current planet
  #
  # @param [ControlGroup] group The group to add.
  receiveGroup: (group) ->
    console.log("Planet: " + @toString() + " received id: " + group._id)
    console.log("groups: " + @_controlGroups)
    @_controlGroups.push(group)

  # Given a chance of success and a number of units, determine one roll.
  #
  # @param [Double] power The chance of success (between 0 and 1)
  # @param [Integer] quantity The number of units attempting to attack/defend
  #
  # @return [Integer] The number of units which succeed.
  rollForDamage: (power, quantity) ->
    total = 0
    for x in [0...quantity] by 1
      roll = Math.random()
      if roll >= power
        total++
    return total

  # Returns true if any adjacent planets contain probes.
  #
  # @return [Bool] Whether or not any adjacent planets contain probes.
  neighborsHaveProbes: ->
    for planet in @_adjacentPlanets
      if planet.numShips(root.config.units.probe) > 0
        return true
    return false

  # Checks various representational invariants
  #
  # @throw [Error] If any representational invariant is violated.
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
    if @_station and @_outpost
      throw new Error "station AND outpost"

root.Planet = Planet
