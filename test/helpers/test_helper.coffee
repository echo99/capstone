# Define helper functions and global variables for testing

chai = require 'chai'
global.assert = chai.assert
chai.should()


# describe 'Task instance', ->
#   task1 = task2 = null
#   it 'should have a name', ->
#     # task1 = new Task 'feed the cat'
#     # task1.name.should.equal 'feed the cat'
#     task1 = "test"
#     task2 = "test2"
#     task1.should.equal task2

# suite 'Suite One', ->
# 	suite 'Inner Suite One', ->
# 		test 'Test One', ->
# 			assert.equal(-1, [1,2,3].indexOf(4));
# 			assert.equal(1, [1,2,3].indexOf(2));
# 		test 'Test Two', ->
# 			assert.equal(-1, [1,2,3].indexOf(4));
# 			assert.equal(0, [1,2,3].indexOf(2));
# 		test 'Test Three', ->	
# 			assert.equal(-1, [1,2,3].indexOf(4));
# 			assert.equal(1, [1,2,3].indexOf(2));
# 	suite 'Inner Suite Two', ->
# 		test 'Test One', ->
# 			assert.equal(-1, [1,2,3].indexOf(4));
# 			assert.equal(1, [1,2,3].indexOf(2));
# 		test 'Test Two', ->
# 			assert.equal(-2, [1,2,3].indexOf(4));
# 			assert.equal(1, [1,2,3].indexOf(2));
# 		test 'Test Three', ->	
# 			assert.equal(-1, [1,2,3].indexOf(4));
# 			assert.equal(1, [1,2,3].indexOf(2));
# 		# assert.equal(1, [1,2,3].indexOf(5));