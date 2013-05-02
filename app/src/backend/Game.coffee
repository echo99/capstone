

class Game
  # Set the height and width of the game world
  constructor: (@_height, @_width) ->
    @_planets = []

  # GAME MANIPULATION #

  # Setup the mission, either by accepting a passed graph or by generating one.
  #
  # @param [Integer] The number of planets to generate if generating.
  # @param [Array of Planets] The graph to use if a custom mission else null.
  setup: (@_numplanets = 0, planets = null) ->
    if planets isnt null
      @_planets = planets
    else if @_numplanets != 0
      # Generate home planet.
      homePlanetX = Math.floor(Math.random() * @_width)
      homePlanetY = Math.floor(Math.random() * @_height)
      homePlanet = new Planet(homePlanetX,
                              homePlanetY,
                              root.config.resources.homePlanetResources,
                              root.config.resources.homePlanetRate)
      homePlanet.addShips(root.config.units.probe, 1)
      # Generate the rest of the planets.
      while @_planets.length != @_numplanets
        if @_planets.length > @_numplanets
          throw error "TOO MANY PLANETS OMG"
        seedPlanet = @_planets[Math.floor(Math.random() * @_planets.length)]
        deltaX = Math.floor((Math.random() * 2 - 1) *
                            root.config.minimumPlanetDistance)
        deltaY = Math.sqrt(Math.pow(root.config.minimumPlanetDistance, 2) -
                           Math.pow(deltaX, 2))
        newX = seedPlanet.location.x + deltaX
        newY = seedPlanet.location.y + deltaY
        newPlanet = new Planet(newX, newY, @newResources(), @newRate())
        if @isGoodPlanet(newPlanet)
          @makeAdjacent(newPlanet)
          @_planets.push(newPlanet)
    @endTurn()

  # Replaces current graph with the specified.
  #
  # param [Array of Planets] The new graph.
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
  # @param [Planet] First new neighbor.
  # @param [Planet] Second new neighbor.
  setNeighbors: (planet1, planet2) ->
    planet1.addNeighbor(planet2)

  # GETTER #

  # Get the entire graph as a list of planets
  #
  # @return [Array of Planets] The current graph.
  getPlanets: ->
    return @_planets

  # UPKEEP #

  # Does all required upkeep for the end of the turn.
  endTurn: ->
    planet.growPass1() for planet in @_planets
    planet.growPass2() for planet in @_planets
    planet.movementUpkeep1() for planet in @_planets
    planet.movementUpkeep2() for planet in @_planets
    planet.updateAI() for planet in @_planets
    planet.resolveCombat() for planet in @_planets
    planet.buildUpkeep() for planet in @_planets
    planet.visibilityUpkeep() for planet in @_planets

  # Helper Functions #

  # Returns a gaussian random variable
  #
  # @return [Double] The sum of three random values between -1 and 1
  gaussian: (stdev, mean) ->
    ((Math.random() * 2 - 1) *
     (Math.random() * 2 - 1) *
     (Math.random() * 2 - 1)) * stdev + mean

  # Returns a new value for a planet's resources according to mean and stdev
  #
  # @return [Integer] A gaussian random amount of resources.
  newResources: ->
    ret = @gaussian(root.config.resources.meanResources,
                   root.config.resources.stdevResources)
    ret = Math.floor(ret)
    if ret < 1
      ret = 1
    return ret

  # Returns a new value for a planet's rate according to mean and stdev
  #
  # @return [Integer] A gaussian random amount of resources.
  newRate: ->
    ret = @gaussian(root.config.resources.meanRate,
                   root.config.resources.stdevRate)
    ret = Math.floor(ret)
    if ret < 1
      ret = 1
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
    for other in @_planets
      if planet.distance(other) < root.config.minimumPlanetDistance
        return false
    return true

  # Checks all planets in the graph and makes neighbors of the close ones.
  makeAdjacent: (planet) ->
    for other in @_planets
      if planet.distance(other) < root.config.maximumAdjacencyDistance
        planet.addNeighbor(other)
