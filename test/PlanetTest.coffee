# Testing the Planet class

{Planet} = require "../app/src/backend/Planet"
{config} = require "../app/src/config"

suite 'Planet', ->
  units = config.units

  suite '#build', ->
    test 'Building fails when not enough available resources.', ->
      testPlanet = new Planet(0, 0, 100, 0)
      assert.throws(-> testPlanet.build(units.probe))
      testPlanet._availableResources = 2
      assert.throws(-> testPlanet.build(units.attackShip))
      assert.doesNotThrow(-> testPlanet.build(units.probe))

    test 'Building fails when something is already under construction.', ->
      testPlanet = new Planet(0, 0, 100, 0)
      testPlanet._availableResources = 5
      assert.doesNotThrow(-> testPlanet.build(units.probe))
      assert.throws(-> testPlanet.build(units.probe))

  suite '#buildUpkeep', ->
    test 'buildUpkeep properly adds to ship count when countdown is done.', ->
      testPlanet = new Planet(0, 0, 100, 0)
      testPlanet._availableResources = 1
      assert.doesNotThrow(-> testPlanet.build(units.probe))
      assert.doesNotThrow(-> testPlanet.buildUpkeep())
      assert.equal(testPlanet._probes, 1, 'Probe was added to probe count.')