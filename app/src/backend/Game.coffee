

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
    @_planets.filter(planet)

  setNeighbors: (planet1, planet2) ->
    planet1.addNeighbor(planet2)

  # GETTER #
  getPlanets: ->
    return @_planets

  # UPKEEP #
  endTurn: ->
    return null