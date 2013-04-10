#_require Unit

class DefenseShip extends Unit
  constructor: ->
    cfg = config.units.defenseShip
    console.log("Building a defense ship!")
    super(cfg.cost, cfg.turns, cfg.attack, cfg.defense)