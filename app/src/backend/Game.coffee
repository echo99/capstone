

class Game
  constructor: (@_height, @_width) ->
    @_planets = []

  # GAME MANIPULATION #

  setup: (@_numplanets = 0, planets) ->
    if planets isnt null
      @_planets = planets
    else
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
        newPlanet = new Planet(newX, newY, newResources(), newRate())
        if isGoodPlanet(newPlanet)
          makeAdjacent(newPlanet)
          @_planets.push(newPlanet)


  setGraph: (planets) ->
    @_planets = planets

  addPlanet: (planet) ->
    @_planets.push(planet)

  removePlanet: (planet) ->
    @_planets = @_planets.filter((p) => p != planet)

  setNeighbors: (planet1, planet2) ->
    planet1.addNeighbor(planet2)

  # GETTER #
  getPlanets: ->
    return @_planets

  # UPKEEP #
  endTurn: ->
    planet.growPass1() for planet in @_planets
    planet.growPass2() for planet in @_planets
    planet.movementUpkeep1() for planet in @_planets
    planet.movementUpkeep2() for planet in @_planets
    planet.resolveCombat() for planet in @_planets
    planet.buildUpkeep() for planet in @_planets
    planet.updateAI() for planet in @_planets
    planet.visibilityUpkeep() for planet in @_planets

  # Helper Functions #

  gaussian: (stdev, mean) ->
    ((Math.random() * 2 - 1) *
     (Math.random() * 2 - 1) *
     (Math.random() * 2 - 1)) * stdev + mean

  newResources: ->
    ret = gaussian(root.config.resources.meanResources,
                   root.config.resources.stdevResources)
    ret = Math.floor(ret)
    if ret < 1
      ret = 1
    return ret

  newRate: ->
    ret = gaussian(root.config.resources.meanRate,
                   root.config.resources.stdevRate)
    ret = Math.floor(ret)
    if ret < 1
      ret = 1
    return ret

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

  makeAdjacent: (planet) ->
    for other in @_planets
      if planet.distance(other) < root.config.maximumAdjacencyDistance
        planet.addNeighbor(other)