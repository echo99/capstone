# Defines a class to represent control groups

class ControlGroup

  constructor: (@_attackShips,
                @_defenseShips,
                @_probes,
                @_colonies,
                @_destination) ->
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

  updateAi: (v) ->
    @_route = []
    q = []
    seen = []
    q.push [v, null]
    seen.push v
    while q.length is not 0
      t = q.unshift
      if t[0] is @_destination
        current = t
        while current[1] is not null
          @_route.shift current[0]
          current = current[1]
      for u in t[0].getAdjacentPlanets
        if (not seen.contains u) and
            not (u.visibility is window.config.visibility.invisible) and
            not (u.visibility is window.config.visibility.fungus)
          seen.push u
          q.push [u, t]
    return null