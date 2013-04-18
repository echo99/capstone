###
#_require Unit

class Probe extends Unit
  constructor: ->
    cfg = config.units.probe
    console.log("Building a probe!")
    super(cfg.cost, cfg.turns, cfg.attack, cfg.defense)
###