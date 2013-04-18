###
#_require Structure

class WarpGate extends Structure
  constructor: (planet) ->
    cfg = config.structures.warpGate
    console.log("Building an outpost!")
    super(cfg.cost, cfg.turns, cfg.defense, planet)
###