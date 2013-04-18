###
#_require ../util/Module
#_require ../util/Buildable

class Structure extends Module
  defense: 0

  constructor: (@cost, @turns, @defense, @planet) ->
    console.log("Cost: #{cost}, turns: #{turns}, defense: #{defense}")
###