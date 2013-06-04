

class Game
  # Set the height and width of the game world
  # Determine whether fungus should grow or not.
  constructor: (@_height, @_width, @_noGrow = false) ->
    @_maxX = @_width /2
    @_minX = 0 - (@_width / 2)
    @_maxY = @_height / 2
    @_minY = 0 - (@_height /2)
    @_planets = []

  # GAME MANIPULATION #

  # Setup the mission by generating a graph.
  #
  # @param [Integer] numplanets The positive integer number of planets to generate.
  #
  # @return [Planet] The home planet.
  #
  # @throw [Error] If the number of planets is not positive.
  setup: (numplanets = 0) ->
    # Sanitize inputs
    if numplanets < 1
      throw Error "Not positive number of planets requested."
    # Generate home planet.
    homePlanetX = Math.floor((Math.random() * 2 - 1) * @_maxX)
    homePlanetY = Math.floor((Math.random() * 2 - 1) * @_maxY)
    homePlanet = new Planet(homePlanetX,
                            homePlanetY,
                            root.config.resources.homePlanetResources,
                            root.config.resources.homePlanetRate)
    homePlanet.addShips(root.config.units.probe, 1)
    @_planets.push(homePlanet)
    # Generate the rest of the planets.
    while @_planets.length != numplanets
      if @_planets.length > numplanets
        throw Error "TOO MANY PLANETS OMG"

      maxAdjacency = 0
      for planet in @_planets
        if planet._adjacentPlanets.length > maxAdjacency
          maxAdjacency = planet._adjacentPlanets.length

      planetWeightList = []
      totalWeight = 0
      for planet in @_planets
        totalWeight += Math.pow( (maxAdjacency - planet._adjacentPlanets.length), 10 )
        planetWeightList.push( totalWeight )

      weightIndex = Math.random() * totalWeight
      i = 0
      while weightIndex > planetWeightList[i]
        i++

      seedPlanet = @_planets[i]

      # seedPlanet = @_planets[Math.floor(Math.random() * @_planets.length)]
      minDist = root.config.minimumPlanetDistance
      maxDist = root.config.maximumAdjacencyDistance
      a = 2 / (Math.pow( maxDist, 2 ) - Math.pow( minDist, 2 ) )
      r = Math.sqrt( 2 * Math.random() / a + Math.pow( minDist, 2 ) )
      theta = Math.random() * 2 * Math.PI
      x = r * Math.cos( theta )
      y = r * Math.sin( theta )
      if x < 0
        deltaX = Math.ceil( x )
      else
        deltaX = Math.floor( x )
      if y < 0
        deltaY = Math.ceil( y )
      else
        deltaY = Math.floor( y )
      # deltaX = Math.floor((Math.random() * 2 - 1) *
      #                     root.config.minimumPlanetDistance)
      # deltaY = Math.floor(Math.sqrt(Math.pow(root.config.minimumPlanetDistance, 2) -
      #                     Math.pow(deltaX, 2)))
      newX = seedPlanet.location().x + deltaX
      newY = seedPlanet.location().y + deltaY
      resources = @newResources()
      rate = @newRate()
      newPlanet = new Planet(newX, newY, @newResources(), @newRate())
      if @isGoodPlanet(newPlanet)
        @makeAdjacent(newPlanet)
        @_planets.push(newPlanet)
    placedFungus = false
    planetsTried = []
    chosenPlanet = null
    chosenPlanetDistance = -1
    while !placedFungus and planetsTried.length < @_planets.length
      fungusPlanet = @_planets[Math.floor(Math.random() * @_planets.length)]
      while fungusPlanet in planetsTried
        fungusPlanet = @_planets[Math.floor(Math.random() * @_planets.length)]
      planetsTried.push(fungusPlanet)
      fungusPlanetDistance = fungusPlanet.distance(homePlanet)
      if fungusPlanetDistance >= root.config.minimumFungusDistance or
          (chosenPlanet is null or chosenPlanetDistance < fungusPlanetDistance)
        placedFungus = fungusPlanetDistance >= root.config.minimumFungusDistance
        chosenPlanet = fungusPlanet
        chosenPlanetDistance = fungusPlanetDistance
    chosenPlanet.setFungus(root.config.fungusInitialStrength)
    chosenPlanet.getAdjacentPlanets()[0].setFungus(root.config.fungusInitialStrength)
    @endTurn()
    return homePlanet

  # Replaces current graph with the specified.
  #
  # param [Array.<Planet>] The new graph.
  setGraph: (planets) ->
    @_planets = planets

  # Adds a planet to the current graph.
  #
  # param [Planet] Planet to add.
  addPlanet: (planet) ->
    @_planets.push(planet)

  # Removes a planet from the graph.
  #
  # param [Planet] Planet to remove.
  removePlanet: (planet) ->
    @_planets = @_planets.filter((p) => p != planet)

  # Make two planets neighbors.
  #
  # @param [Planet] planet1 new neighbor.
  # @param [Planet] planet2 new neighbor.
  setNeighbors: (planet1, planet2) ->
    planet1.addNeighbor(planet2)

  # GETTER #

  # Get the entire graph as a list of planets
  #
  # @return [Array.<Planet>] The current graph.
  getPlanets: ->
    return @_planets

  # UPKEEP #

  # Does all required upkeep for the end of the turn.
  endTurn: ->
    planet.gatherResources() for planet in @_planets
    planet.resourceSendingUpkeep() for planet in @_planets
    planet.movementUpkeep1() for planet in @_planets
    planet.movementUpkeep2() for planet in @_planets
    planet.updateAI() for planet in @_planets
    planet.resolveCombat() for planet in @_planets
    planet._fungusMaximumStrength = 0 for planet in @_planets
    planet.growPass3() for planet in @_planets
    planet.growPass1a() for planet in @_planets
    planet.growPass1b() for planet in @_planets
    planet.growPass2() for planet in @_planets
    planet.growPass3() for planet in @_planets
    planet.buildUpkeep() for planet in @_planets
    planet.visibilityUpkeep() for planet in @_planets
    planet.combineControlGroups() for planet in @_planets
    planet.checkRepresentationalInvariants() for planet in @_planets
    console.log("--------------------------------------")

  # Helper Functions #

  # Returns a gaussian random variable
  #
  # @return [Double] The sum of three random values between -1 and 1
  gaussian: (stdev, mean) ->
    ((Math.random() * 2 - 1) *
     (Math.random() * 2 - 1) *
     (Math.random() * 2 - 1) *
     (Math.random() * 2 - 1) *
     (Math.random() * 2 - 1)) * stdev + mean

  # Returns a new value for a planet's resources according to mean and stdev
  #
  # @return [Integer] A gaussian random amount of resources.
  newResources: ->
    ret = @gaussian(root.config.resources.stdevResources,
                  root.config.resources.meanResources)
    ret = Math.floor(ret)
    if ret < root.config.resources.minResources
      ret = root.config.resources.minResources
    if ret > root.config.resources.maxResources
      ret = root.config.resources.maxResources
    return ret

  # Returns a new value for a planet's rate according to mean and stdev
  #
  # @return [Integer] A gaussian random amount of resources.
  newRate: ->
    ret = @gaussian(root.config.resources.stdevRate,
                   root.config.resources.meanRate)
    ret = Math.floor(ret)
    if ret < root.config.resources.minRate
      ret = root.config.resources.minRate
    if ret > root.config.resources.maxRate
      ret = root.config.resources.maxRate
    return ret

  # Returns true if the planet is on the map and not too close to others.
  #
  # @return [Bool] True if this planet is good enough to include.
  isGoodPlanet: (planet) ->
    location = planet.location
    if location.x >= @_width
      return false
    if location.y >= @height
      return false
    isCloseEnough = false
    for other in @_planets
      dist = planet.distance( other )
      if dist < root.config.minimumPlanetDistance
        return false
      isCloseEnough |= dist <= root.config.maximumAdjacencyDistance
    return isCloseEnough

  # Checks all planets in the graph and makes neighbors of the close ones.
  makeAdjacent: (planet) ->
    for other in @_planets
      if planet.distance(other) < root.config.maximumAdjacencyDistance
        planet.addNeighbor(other)
