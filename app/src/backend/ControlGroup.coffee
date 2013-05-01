# Defines a class to represent control groups

if not root?
  root = exports ? window

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
    console.log("Finding route for control group")
    @_route = []
    q = []
    seen = []
    q.push([v, null])
    seen.push(v)
    console.log("q: " + q)
    while q.length > 0
      t = q.shift()
      console.log("t[0] " + t[0])
      console.log("dest " + @_destination)
      console.log("t[0] is dest: " + (t[0] is @_destination))
      if t[0] is @_destination
        current = t
        console.log("current[0]: " + current[0])
        console.log("current[1]: " + current[1])
        while current[1] != null
          # add element to back of list
          @_route.unshift(current[0])
          current = current[1]
        break
      for u in t[0].getAdjacentPlanets()
        if (not (u in seen)) and
            not (u.visibility is window.config.visibility.invisible) and
            not (u.visibility is window.config.visibility.fungus)
          seen.push(u)
          q.push([u, t])
    console.log("route: " + @_route)
    return null

  toString: ->
    return "ControlGroup(route: [#{@_route}])"

root.ControlGroup = ControlGroup
