###
#_require Unit

class ColonyShip extends Unit
  constructor: ->
    cfg = config.units.colonyShip
    console.log("Building a colony ship!")
    super(cfg.cost, cfg.turns, cfg.attack, cfg.defense)
###