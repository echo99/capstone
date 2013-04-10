#_require Structure

class Station extends Structure
  constructor: (planet) ->
    cfg = config.structures.station
    console.log("Building a station!")
    super(cfg.cost, cfg.turns, cfg.defense, planet)