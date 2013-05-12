#_require Extermination

class ExterminationLarge extends Extermination

  reset: ->
    @restart = ExterminationLarge
    @size = "large"
    @numPlanets = window.config.numberOfPlanetsInExterminateLarge
    super()