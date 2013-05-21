# Defines a class to represent Resource Carriers

if not root?
  root = exports ? window

#_require AI

class ResourceCarrier
  constructor: (@_amount, @_destination) ->
    @_route = []
    @_hasMoved = false

  # Returns true if the carrier has moved yet this turn.
  #
  # @return [Bool] True if the carrier has moved.
  moved: ->
    @_hasMoved

  # Returns the number of resources carried.
  #
  # @return [Integer] Amount of resources.
  amount: ->
    @_amount

  # Returns the route that this Control Group currently intends to follow.
  #
  # @return [Array.<Planet>] The group's route.
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

  # Sets the moved flag to true.
  setMoved: ->
    @_hasMoved = true

  # Sets the moved flag to false.
  resetMoved: ->
    @_hasMoved = false

  # String representation
  #
  # @return [String] String representation of the carrier.
  toString: ->
    "amount: " + @_amount + " destination: " + @_destination

  # ARTIFICIAL INTELLIGENCE #

  # Updates the intended path based on a breadth first search
  #
  # @param [Planet] v Current planet.
  updateAi: (v) ->
    @_route = AI.getPath(v, @_destination)