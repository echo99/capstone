# Defines a class to represent control groups

class ControlGroup

  constructor: (@_attackShips, @_defenseShips, @_probes, @_colonies, @_destination) ->
    @_route = []
    @_hasMoved = false

  moved: ->
    @_hasMoved

  attackShips: ->
    @_attackShips

  defenseShips: ->
    @_defenseShips

  probes: ->
    @_probes

  colonies: ->
    @_colonies

  route: ->
    @_route

  next: ->
    @_route[0]

  destination: ->
    @_destination

  setAttackShips: (ships) ->
    @_attackShips = ships

  setDefenseShips: (ships) ->
    @_defenseShips = ships

  setProbes: (ships) ->
    @_probes = ships

  setColonies: (ships) ->
    @_colonies = ships

  setMoved: ->
    @_moved = true

  resetMoved: ->
    @_moved = false

  # ARTIFICIAL INTELLIGENCE #

  updateAi: ->
    null
    
  


  