#_require Extermination

class ExterminationMedium extends Extermination

  reset: ->
    @restart = ExterminationMedium
    @size = "medium"
    @numPlanets = window.config.numberOfPlanetsInExterminateMedium
    @spread = window.config.spreadExterminateMedium
    super()