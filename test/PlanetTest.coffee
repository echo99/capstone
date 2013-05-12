# Testing the Planet class

{Planet} = require "../app/src/backend/Planet"
{config} = require "../app/src/config"

suite 'Planet', ->
  units = config.units

  suite '#build', ->
    testPlanet = null

    setup ->
      testPlanet = new Planet(0, 0, 100, 0)
      testPlanet.addStation()

    test 'Building fails when not enough available resources.', ->
      assert.throws(-> testPlanet.build(units.probe))
      testPlanet._availableResources = 2
      assert.throws(-> testPlanet.build(units.attackShip))
      assert.doesNotThrow(-> testPlanet.build(units.probe))

    test 'Building fails when something is already under construction.', ->
      testPlanet._availableResources = 5
      assert.doesNotThrow(-> testPlanet.build(units.probe))
      assert.throws(-> testPlanet.build(units.probe))

  suite '#buildUpkeep', ->
    testPlanet = null

    setup ->
      testPlanet = new Planet(0, 0, 100, 0)
      testPlanet.addStation()

    test 'buildUpkeep properly adds to ship count when countdown is done.', ->
      testPlanet._availableResources = 1
      assert.doesNotThrow(-> testPlanet.build(units.probe))
      assert.doesNotThrow(-> testPlanet.buildUpkeep())
      assert.equal(testPlanet._probes, 1, 'Probe was added to probe count.')

  suite '#visibility', ->
    visibility = config.visibility

    test 'should be visible when a probe is in a control group', ->
      # Create planets
      planet1 = new Planet(0, 0)
      planet2 = new Planet(100, 0)
      planet1.addNeighbor(planet2)
      planet1.addShips(config.units.probe, 1)
      planet1.moveShips(0, 0, 1, 0, planet2)
      planet1.visibilityUpkeep()
      planet2.visibilityUpkeep()
      assert.equal(planet1.visibility(), visibility.visible,
        'Planet 1 should be visible')
      assert.equal(planet2.visibility(), visibility.visible,
        'Planet 2 should be visible')

  suite '#gatherResources', ->
    suite 'Planet with 4 resources and rate 3', ->
      planet = null

      setup ->
        planet = new Planet(0, 0, 4, 3)
        planet.addOutpost()

      test 'should start with 4 resources and 0 available', ->
        assert.equal(planet._resources, 4)
        assert.equal(planet._availableResources, 0)

      test 'should have 1 resource and 3 available after gathering once', ->
        planet.gatherResources()
        assert.equal(planet._resources, 1)
        assert.equal(planet._availableResources, 3)

      test 'should have 0 resources and 4 available after gathering twice', ->
        planet.gatherResources()
        planet.gatherResources()
        assert.equal(planet._resources, 0)
        assert.equal(planet._availableResources, 4)
