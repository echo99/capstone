

class Game
	constructor: (@_height, @_width) -> 
		@_planets = []
	
	setup: (@_numplanets = 0, planets) ->
		if planets isnt null
			@_planets = planets
		else 
			numplanets

	setGraph: (planets) ->
		@_planets = planets

	getPlanets: ->
		return @_planets

	endTurn: ->
		return null

	setDest: (unit, num, planet1, planet2) ->
		return null

	cancelControlGroup: (group) ->
		return null

	build (unit, planet) ->
		return null

	makeOutpost(planet) ->
		return null

	makeStation(planet) ->






	


