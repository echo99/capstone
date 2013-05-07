# Defines a class to represent control groups

if not root?
  root = exports ? window

#_require AI

class ControlGroup
  # Sets the number of each type of ship and destination
  constructor: (@_attackShips,
                @_defenseShips,
                @_probes,
                @_colonies,
                @_destination) ->
    @_route = []
    @_hasMoved = false
  
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
    @_hasMoved = true

  # Sets the moved flag to false.
  resetMoved: ->
    @_hasMoved = false

  # ARTIFICIAL INTELLIGENCE #

  # Updates the intended path based on a breadth first search
  #
  # @param [Planet] v Current planet.
  updateAi: (v) ->
    @_route = AI.getPath(v, @_destination)

  # Returns a string representation of this ControlGroup
  # route: [list, of, planets]
  #
  # @return [String] A string representing this ControlGroup.
  toString: ->
    return "ControlGroup(id: [#{@_id}] route: [#{@_route}])"

root.ControlGroup = ControlGroup
