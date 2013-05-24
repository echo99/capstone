if not root?
  root = exports ? window

if exports?
  {config} = require '../config'
  {ControlGroup} = require './ControlGroup'
  {AI} = require './AI'
  root.config = config

#_require ControlGroup
#_require ResourceCarrier

# Defines a class to represent planets
#
class Planet
  # Sets the coordinate location, starting resources, and rate of harvest.
  constructor: (@_x, @_y, @_resources = 0, @_rate = 0) ->
    @_lastSeenResources = null
    @_lastSeenFungus = false
    @_hasBeenSeen = false
    @_availableResources = 0
    @_resourceSendingPathway = []
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
    @_resourceCarriers = []
    @_unitConstructing = null
    @_turnsToComplete = 0
    @_sendingResourcesTo = null
    @_sendingUnitsTo = null
    @_nextSend = null
    @_sprite = null
    @_visibility = root.config.visibility.undiscovered
    @_combatReport = {
      fungusDamage: 0
      fungusDefense: 0
      humanDamage: 0
      humanDefense: 0
      fungusLost: 0
      attackShipsLost: 0
      defenseShipsLost: 0
      probesLost: 0
      coloniesLost: 0
      outpostLost: false
      stationLost: false
    }

  # GETTERS #

  # Returns the string representation of the planet.
  #
  # @return [String] String representation of planet
  #
  toString: ->
    return "Planet(#{@_x}, #{@_y}, #{@_resources}, #{@_rate})"

  # Returns the sprite used to display this planet
  #
  # @return [Integer] The sprite used to display this planet
  sprite: ->
    @_sprite

  # Returns the (x, y) location of the planet.
  #
  # @return [Array.<Integer>] Location of planet
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
  # @return [Visibility] The current visibility state of the planet.
  #
  visibility: ->
    return @_visibility

  # Returns the current planet we are senting resources to or null if none.
  #
  # @return [Planet] The planet we are sending resources to.
  sendingResourcesTo: ->
    return @_sendingResourcesTo

  # Returns the current planet we are senting units to or null if none.
  #
  # @return [Planet] The planet we are sending units to.
  sendingUnitsTo: ->
    return @_sendingUnitsTo

  # Returns the current number of ships on the planet of the specified type.
  #
  # @param [Visibility] type The specified type
  #
  # @return [Integer] The number of ships of the specified type.
  #
  # @throw [Error] If the ship type is not one of Visibility
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

  # True if there is a unit or structure on the planet
  #
  # @return [Boolean] True if any humans around.
  humansOnPlanet: ->
    @_station or @_outpost or
    @_probes > 0 or @_attackShips > 0 or @_defenseShips > 0 or @_colonies > 0

  # True if there is fungus on the planet
  #
  # @return [Boolean] True if any fungus around.
  fungusOnPlanet: ->
    @_fungusStrength > 0

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
  # @return [Array.<Planet>] A list of planets adjacent to this one.
  #
  getAdjacentPlanets: ->
    return @_adjacentPlanets

  # Returns the list of control groups stationed at this planet.
  #
  # @return [Array.<Planet>] The list of control groups stationed at this planet.
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
  # @return [Visibility] The type of unit being constructed
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

  # Returns the combat report for the last turn.
  #
  # @return [] A representation of the combat that
  #            occured on the last turn for this planet.
  getCombatReport: ->
    return @_combatReport

  # SETTERS FOR USE BY GUI #

  # Set sprite
  setSprite: (sprite) ->
    @_sprite = sprite

  # Sets the visibility state to either visible, discovered or undiscovered
  #
  setVisibility: (state) ->
    if (state is root.config.visibility.visible) or
       (state is root.config.visibility.discovered) or
       (state is root.config.visibility.undiscovered)
      @_visibility = state
      if (state is root.config.visibility.visible) or
         (state is root.config.visibility.discovered)
        @_hasBeenSeen = true
    else
      throw Error "Invalid Visibility"


  # Immediately adds the specified number of the specified type of ship to
  # those on the planet.  This does not incur a resource cost or build delay.
  #
  # @param [{cost: Integer, turns: Integer, attack: Double, defense: Double, isStructure: true}] type The type of ship to build.
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
    if !@_station and
       !@_outpost and
       @_probes >= root.config.structures.outpost.cost and
       @_colonies > 0
      @_unitConstructing = root.config.structures.outpost
      @_turnsToComplete = root.config.structures.outpost.turns
      @_probes -= root.config.structures.outpost.cost
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
      if @_unitConstructing == root.config.structures.outpost
        @_probes++
        @_colonies++
      else
        @_availableResources += @_unitConstructing.cost
      @_unitConstructing = null
      @_turnsToComplete = 0

  # Begin sending resources to another planet
  #
  # @throw [Error] If the planet is invalid or has no structures.
  # @throw [Error] If there is no path.
  sendResources: (planet) ->
    if planet == undefined or planet == null
      throw new Error("Planet is " + planet + ".")
    if planet.hasStation() == undefined or
       planet.hasStation() == null or
       planet.hasOutpost() == undefined or
       planet.hasOutpost() == null
      throw new Error("Planet has invalid state or I hate js.")
    if !planet.hasStation() and !planet.hasOutpost()
      throw new Error("Planet has no structure")
    # There is a valid structure here
    path = AI.getPath(@, planet, true)
    if path is []
      throw new Error("There is no path between the two planets")
    # There is a valid path between them
    @_sendingResourcesTo = planet

  # Stop sending resources to another planet
  #
  # @throw [Error] If we are not sending yet.
  stopSendingResources: ->
    if @_sendingResourcesTo == null
      throw new Error("Tried to cancel sending resources, no such job.")
    @_sendingResourcesTo = null
    @_nextSend = null

  # Returns the first planet to send resources to.
  #
  # @return [Planet] First planet in supply chain.
  nextSend: ->
    if @_sendingResourcesTo == null
      return null
    #console.log("next send initial " + @_nextSend)
    if @_nextSend == null or @_nextSend == undefined
      path = AI.getPath(@, @_sendingResourcesTo)
      if path == []
        @_nextSend = null
        @_sendingResourcesTo = null
      else
        @_nextSend = path[0]
    #console.log("next send " + @_nextSend)
    return @_nextSend

  # Sends units to given planet
  #
  # @throw [Error] If there is no immediate path.
  sendUnits: (planet) ->
    if planet == @
      @_sendingUnitsTo = null
    else
      path = AI.getPath(@, planet)
      if path is []
        throw new Error("There is no path between the two planets")
      # There is a valid path between them
      @_sendingUnitsTo = planet

  # Stop sending ships to another planet
  #
  # @throw [Error] If we are not sending yet.
  stopSendingUnits: ->
    if @_sendingUnitsTo == null
      throw new Error("Tried to cancel sending ships, no such job.")
    @_sendingUnitsTo = null

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
    if @_resources < 0
      @_resources = 0

  # Fungus growth phase 1.
  # Determines growth and sporing for next turn.
  #
  growPass1: ->
    if @_fungusStrength > 0
      @_fungusStrength += root.config.units.fungus.growthPerTurn
    if @_fungusStrength == 0 or @_attackShips + @_defenseShips +
        @_probes + @_colonies > 0 or @_outpost or @_station or game._noGrow
      null # No sporing or growing.
    else if @_fungusStrength >= @_fungusMaximumStrength and
        @_adjacentPlanets.length > 0
      # Spore
      for i in [Math.min(@_fungusStrength, 2)..@_fungusStrength]
        planet = @_adjacentPlanets[Math.floor(
          Math.random() * @_adjacentPlanets.length)]
        if planet._fungusStrength - planet._fungusLeaving +
            planet._fungusArriving < planet._fungusMaximumStrength
          # this DOES introduce dependence on what order grow is called on planets,
          # but it should be okay
          planet._fungusArriving++
          @_fungusLeaving++
          # console.log "#{planet._fungusStrength} - #{planet._fungusLeaving} " +
          #   "+ #{planet._fungusArriving} ?= #{planet._fungusMaximumStrength}"
    else if @_fungusStrength < @_fungusMaximumStrength
      # Grow
      @_fungusArriving += if Math.random() <
          root.config.units.fungus.growthChancePerTurn then 1 else 0

  # Fungus growth phase 2.
  # Applies fungus changes determined from pass 1.
  # Resets the "maximum fungus strength on this planet" counter
  # in preparation for phase 3.
  #
  growPass2: ->
    @_fungusStrength -= @_fungusLeaving
    @_fungusLeaving = 0
    @_fungusStrength += @_fungusArriving
    @_fungusArriving = 0
    @_fungusMaximumStrength = 0

  # Fungus growth phase 3.
  # Recalculates maximum fungus strength on each planet.
  growPass3: ->
    if @_fungusStrength > 0
      @_fungusMaximumStrength += 1
      for planet in @_adjacentPlanets
        planet._fungusMaximumStrength += 1

  # Resolves combat between player/fungus on a planet.
  #
  resolveCombat: ->
    @_combatReport = {
      fungusDamage: 0
      fungusDefense: 0
      humanDamage: 0
      humanDefense: 0
      fungusLost: 0
      attackShipsLost: 0
      defenseShipsLost: 0
      probesLost: 0
      coloniesLost: 0
      outpostLost: false
      stationLost: false
    }
    if !@humansOnPlanet() or !@fungusOnPlanet()
      return
    fungusDamage = 0
    humanDamage = 0
    fungusDefense = 0
    humanDefense = 0
    # Roll for damage
    fungusDamage += @rollForDamage(root.config.units.fungus.attack,
                                   @_fungusStrength)
    @_combatReport.fungusDamage = fungusDamage
    humanDamage += @rollForDamage(root.config.units.attackShip.attack,
                                  @_attackShips)
    humanDamage += @rollForDamage(root.config.units.defenseShip.attack,
                                  @_defenseShips)
    humanDamage += @rollForDamage(root.config.units.colonyShip.attack,
                                  @_colonyShips)
    humanDamage += @rollForDamage(root.config.units.probe.attack, @_probes)
    @_combatReport.humanDamage = humanDamage
    # Roll for defense rating
    fungusDefense += @rollForDamage(root.config.units.fungus.defense,
                                    @_fungusStrength)
    @_combatReport.fungusDefense = fungusDefense
    humanDefense += @rollForDamage(root.config.units.attackShip.defense,
                                   @_attackShips)
    humanDefense += @rollForDamage(root.config.units.defenseShip.defense,
                                   @_defenseShips)
    humanDefense += @rollForDamage(root.config.units.colonyShip.defense,
                                   @_colonyShips)
    humanDefense += @rollForDamage(root.config.units.probe.defense, @_probes)
    @_combatReport.humanDefense = humanDefense
    console.log("Fungus rolled " + fungusDamage + "damage")
    console.log("Humans rolled " + humanDefense + "defense")
    console.log("Humans rolled " + humanDamage + "damage")
    console.log("Fungus rolled " + fungusDefense + "defense")
    # Apply defensive ratings to damage
    fungusDamage -= humanDefense
    humanDamage -= fungusDefense
    if fungusDamage < 0
      fungusDamage = 0
    if humanDamage < 0
      humanDamage = 0
    console.log(fungusDamage + " damage to humans")
    console.log(humanDamage + " damage to fungus")
    # Destroy units
    @_combatReport.fungusLost = Math.min(@_fungusStrength, humanDamage)
    if @_fungusStrength >= humanDamage
      @_fungusStrength -= humanDamage
    else
      @_fungusStrength = 0
    # Destroy attack ships first
    @_combatReport.attackShipsLost = Math.min(@_attackShips, fungusDamage)
    if @_attackShips >= fungusDamage
      @_attackShips -= fungusDamage
      return null
    @_attackShips = 0
    fungusDamage -= @_attackShips
    @_combatReport.defenseShipsLost = Math.min(@_defenseShips, fungusDamage)
    # Destroy defense ships second
    if @_defenseShips >= fungusDamage
      @_defenseShips -= fungusDamage
      return null
    @_defenseShips = 0
    fungusDamage -= @_defenseShips
    @_combatReport.probesLost = Math.min(@_probes, fungusDamage)
    # Destroy probes third
    if @_probes >= fungusDamage
      @_probes -= fungusDamage
      return null
    @_probes = 0
    fungusDamage -= @_probes
    @_combatReport.coloniesLost = Math.min(@_colonies, fungusDamage)
    # Destroy colony ships last
    if @_colonies >= fungusDamage
      @_colonies -= fungusDamage
      return null
    @_colonies = 0
    fungusDamage -= @_colonies
    # If there is any leftover fungus damage
    # then destroy all structures
    if fungusDamage > 0
      @_combatReport.outpostLost = @_outpost
      @_combatReport.stationLost = @_station
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
            when root.config.structures.station
              @_station = true
              @_outpost = false
            when root.config.structures.warpgate then @_warpgate = true
            else throw new Error("Invalid structure, it ain't one.")
        else
          switch unit
            when root.config.units.probe then @_probes++
            when root.config.units.colonyShip then @_colonies++
            when root.config.units.attackShip then @_attackShips++
            when root.config.units.defenseShip then @_defenseShips++
            else throw new Error("Ship type unknown.")
          if @_sendingUnitsTo != null
            switch unit
              when root.config.units.probe
                @moveShips(0, 0, 1, 0, @_sendingUnitsTo)
              when root.config.units.colonyShip
                @moveShips(0, 0, 0, 1, @_sendingUnitsTo)
              when root.config.units.attackShip
                @moveShips(1, 0, 0, 0, @_sendingUnitsTo)
              when root.config.units.defenseShip
                @moveShips(0, 1, 0, 0, @_sendingUnitsTo)
              else throw new Error("Ship type unknown.")

  # Create new resource carriers if sending and can afford it.
  # If there is not currently a path without fungus then stops sending.
  #
  resourceSendingUpkeep: ->
    if @_sendingResourcesTo == null
      return
    if (!@_outpost and !@_station) or @_availableResources == 0
      @_sendingResourcesTo = null
      @_nextSend = null
      return
    path = AI.getPath(@, @_sendingResourcesTo, true)
    if path is []
      @_sendingResourcesTo = null
      return
    # We are sending resources
    if @_availableResources < root.config.resources.sendRate
      console.log("We only have " + @_availableResources)
      amount = @_availableResources
    else
      console.log("Sending max: " + root.config.resources.sendRate)
      amount = root.config.resources.sendRate
    @_availableResources -= amount
    carrier = new ResourceCarrier(amount, @_sendingResourcesTo)
    carrier.updateAi(@)
    @_resourceCarriers.push(carrier)
    if @_resources == 0 and @_availableResources == 0
      @_sendingResourcesTo = null
      @_nextSend = null

  # Combines control groups headed to the same destination
  #
  #
  combineControlGroups: (group) ->
    if group == undefined
      return
    for other in @_controlGroups.filter((g) => g != group)
      if (group.destination() == other.destination()) and
         (group.moved() == other.moved())
        group.setProbes(group.probes() + other.probes())
        group.setAttackShips(group.attackShips() + other.attackShips())
        group.setDefenseShips(group.defenseShips() + other.defenseShips())
        group.setColonies(group.colonies() + other.colonies())
        @_controlGroups = @_controlGroups.filter((g) => g != other)


  # Movement phase 1.
  # Moves control groups.
  #
  movementUpkeep1: ->
    @move(group) for group in @_controlGroups
    @send(carrier) for carrier in @_resourceCarriers

  # Movement phase 2.
  # Resets all control groups to allow movement again.
  # Reintegrates control groups that have reached their destination.
  #
  movementUpkeep2: ->
    for group in @_controlGroups
      group.resetMoved()
      if (group.destination() is @) or @.fungusOnPlanet()
        @_attackShips += group.attackShips()
        @_defenseShips += group.defenseShips()
        @_probes += group.probes()
        @_colonies += group.colonies()
        @_controlGroups = @_controlGroups.filter((g) => g != group)
    for carrier in @_resourceCarriers
      console.log(@ + " " + carrier.toString())
      carrier.resetMoved()
      if carrier.destination() is @
        console.log("disassembling carrier: " + carrier)
        @_availableResources += carrier.amount()
        @_resourceCarriers= @_resourceCarriers.filter((c) => c != carrier)

  # Visibility upkeep method.
  # Updates visibility status and last-known values to reflect planet
  # visibility.
  #
  visibilityUpkeep: ->
    @_nextSend = null
    # If it has probes:
    if @hasProbes() or @_station or @_outpost or
       @_unitConstructing == root.config.structures.outpost
      @_lastSeenResources = @_resources
    # If it has any units
    if @hasProbes() or
       @_attackShips > 0 or
       @_defenseShips > 0 or
       @_colonies > 0 or
       @_station or @_outpost or 
       @_unitConstructing == root.config.structures.outpost
      # If it isn't visible make it visible and update both last seen.
      if !@_hasBeenSeen
        @_hasBeenSeen = true
      @_lastSeenFungus = @_fungusStrength
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
    carrier.updateAi(@) for carrier in @_resourceCarriers

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
      if controlGroup == undefined
        console.log("Control Group that we made is undefined somehow")
      @_controlGroups.push(controlGroup)
      @combineControlGroups(controlGroup)

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
      group.setMoved()
      if !(group.destination() is @)
        group.next().receiveGroup(group)
        @_controlGroups = @_controlGroups.filter((g) => g != group)

  # Moves a resource carrier to it's next intermediate destination.
  #
  # @param [ResourceCarrier] carrier The carrier to be moved.

  send: (carrier) ->
    console.log("Planet:" + @ + " sending carrier: " + carrier)
    if !carrier.moved()
      carrier.setMoved()
      if !(carrier.destination() is @)
        carrier.next().receiveCarrier(carrier)
        @_resourceCarriers = @_resourceCarriers.filter((c) => c != carrier)

  # Adds a given group to the current planet
  #
  # @param [ControlGroup] group The group to add.
  receiveGroup: (group) ->
    if group == undefined
      return
    @_controlGroups.push(group)
    @combineControlGroups(group)

  # Adds a given carrier to the current planet
  #
  # @param [ResourceCarrier] carrier The carrier to add.
  receiveCarrier: (carrier) ->
    console.log("Planet:" + @ + " receiving carrier: " + carrier)
    @_resourceCarriers.push(carrier)

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
      if roll < power
        total++
    return total

   # Returns true if this planet contains probes including control groups.
  #
  # @return [Bool] Whether or not this planet contains probes.
  hasProbes: ->
    if @_probes > 0
      return true
    for group in @_controlGroups
      if group.probes() > 0
        return true
    return false

  # Returns true if any adjacent planets contain probes.
  #
  # @return [Bool] Whether or not any adjacent planets contain probes.
  neighborsHaveProbes: ->
    for planet in @_adjacentPlanets
      if planet.hasProbes()
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
    expectedFungusMaximumStrength = if @_fungusStrength > 0 then 1 else 0
    (expectedFungusMaximumStrength +=
      (if planet._fungusStrength > 0 then 1 else 0)) for planet in @_adjacentPlanets
    if @_fungusMaximumStrength != expectedFungusMaximumStrength
      throw new Error "Fungus maximum strength is not correct!"
    # console.log "#{@_fungusStrength} / #{@_fungusMaximumStrength}"

root.Planet = Planet
