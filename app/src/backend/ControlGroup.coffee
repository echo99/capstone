# Defines a class to represent control groups

if not root?
  root = exports ? window

class ControlGroup
  # Sets the number of each type of ship and destination
  constructor: (@_attackShips,
                @_defenseShips,
                @_probes,
                @_colonies,
                @_destination) ->
    @_route = []
    @_hasMoved = false
  
  # Check rep invariants.
  #
  # throws [Error] if a rep invariant is violated.
  checkRepInvariants: ->
    if @_attackShips < 0 or @_defenseShips < 0 or @_probes < 0 or @_colonies < 0
      throw new Error "Negative number of a type of ship!"
    else if @_destination is null
      throw new Error "Destination is null!"

  # Returns true if the ship has moved yet this turn.
  #
  # @return [Bool] True if the ship has moved.
  moved: ->
    @_hasMoved

  # Returns the number of attack ships.
  #
  # @return [Integer] Number of attack ships.
  attackShips: ->
    @_attackShips

  # Returns the number of defense ships.
  #
  # @return [Integer] Number of defense ships.
  defenseShips: ->
    @_defenseShips

  # Returns the number of probes.
  #
  # @return [Integer] Number of probes.
  probes: ->
    @_probes

  # Returns the number of colony ships.
  #
  # @return [Integer] Number of colony ships.
  colonies: ->
    @_colonies

  # Returns the route that this Control Group currently intends to follow.
  #
  # @return [Array of Planets] The group's route.
  route: ->
    @_route

  # Returns the the next planet.
  #
  # @return [Planet] Next planet.
  next: ->
    @_route[0]

  # Returns the the destination planet.
  #
  # @return [Planet] Destination planet.
  destination: ->
    @_destination

  # Sets the number of attack ships in the ControlGroup.
  #
  # @param [Integer] ships number of attack ships.
  setAttackShips: (ships) ->
    @_attackShips = ships

  # Sets the number of defense ships in the ControlGroup.
  #
  # @param [Integer] ships number of defense ships.
  setDefenseShips: (ships) ->
    @_defenseShips = ships

  # Sets the number of probes in the ControlGroup.
  #
  # @param [Integer] ships number of probes.
  setProbes: (ships) ->
    @_probes = ships

  # Sets the number of colony ships in the ControlGroup.
  #
  # @param [Integer] ships number of colony ships.
  setColonies: (ships) ->
    @_colonies = ships

  # Sets the moved flag to true.
  setMoved: ->
    @_moved = true

  # Sets the moved flag to false.
  resetMoved: ->
    @_moved = false

  # ARTIFICIAL INTELLIGENCE #

  # Updates the intended path based on a breadth first search
  #
  # @param [Planet] v Current planet.
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

  # Returns a string representation of this ControlGroup
  # route: [list, of, planets]
  #
  # @return [String] A string representing this ControlGroup.
  toString: ->
    return "ControlGroup(route: [#{@_route}])"

root.ControlGroup = ControlGroup
