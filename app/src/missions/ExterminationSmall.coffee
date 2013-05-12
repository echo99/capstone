#_require Extermination

class ExterminationSmall extends Extermination

  reset: ->
    @restart = ExterminationSmall
    @size = "small"
    @numPlanets = window.config.numberOfPlanetsInExterminateSmall
    super()