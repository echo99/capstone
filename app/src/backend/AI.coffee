AI =
  # Finds a path based on a breadth first search
  #
  # @param [Planet] v Current planet.
  getPath:(start, finish, avoidFungus = false) ->
    route = []
    q = []
    seen = []
    q.push([start, null])
    seen.push(start)
    while q.length > 0
      t = q.shift()
      if t[0] is finish
        current = t
        while current[1] != null
          # add element to back of list
          route.unshift(current[0])
          current = current[1]
        break
      for u in t[0].getAdjacentPlanets()
        if !(u in seen) and
           u.visibility() != root.config.visibility.undiscovered and
           (!u.fungusOnPlanet or !avoidFungus)
          seen.push(u)
          q.push([u, t])
    return route