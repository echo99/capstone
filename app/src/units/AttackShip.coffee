###
#_require Unit

class AttackShip extends Unit
  constructor: ->
    cfg = config.units.attackShip
    console.log("Building an attack ship!")
    super(cfg.cost, cfg.turns, cfg.attack, cfg.defense)
###