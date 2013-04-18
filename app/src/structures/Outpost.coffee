###
#_require Structure

class Outpost extends Structure
  constructor: (planet) ->
    cfg = config.structures.outpost
    console.log("Building an outpost!")
    super(cfg.cost, cfg.turns, cfg.defense, planet)
###