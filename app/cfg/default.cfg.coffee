# Define "global" variables and helper functions

DEBUG = false

# Print messages to console only if debug mode is on
debug = (message) ->
  console.log(message) if DEBUG
