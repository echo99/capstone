#_require ../util/Module
#_require ../util/Buildable

class Unit extends Module
  @include Buildable

  constructor: (@cost, @turns, @attack, @defense, @location) ->
    console.log("Cost: #{cost}, turns: #{turns}, "
      + "attack: #{attack}, defense: #{defense}")

  moveTo: (@destination) ->

  move: ->
    @location = @destination