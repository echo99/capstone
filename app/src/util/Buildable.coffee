Buildable =
  cost: 0
  turns: 0

  build: ->
    @turnsRemaining = @turns

  isReady: ->
    return cost <= 0