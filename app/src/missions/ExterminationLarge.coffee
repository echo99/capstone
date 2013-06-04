#_require Extermination

class ExterminationLarge extends Extermination

  reset: ->
    @restart = ExterminationLarge
    @size = "large"
    @numPlanets = window.config.numberOfPlanetsInExterminateLarge
    @spread = window.config.spreadExterminateLarge
    super()