

class Game
  constructor: (@_height, @_width) ->
    @_planets = []

  # GAME MANIPULATION #

  setup: (@_numplanets = 0, planets) ->
    if planets isnt null
      @_planets = planets
    else
      numplanets

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