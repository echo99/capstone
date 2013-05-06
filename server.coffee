# Server script
# To run from root directory, run `coffee server.coffee`

# Import modules
sys = require 'sys'
http = require 'http'
path = require 'path'
url = require 'url'
fs = require 'fs'

# Set directory to root/public
dir = path.join(process.cwd(), 'public')

# Create the server
server = http.createServer (request, response) ->
  reqPath = url.parse(request.url).pathname
  if reqPath == '/'
    reqPath = '/index.html'
  console.log 'Requested path: ' + reqPath
  fullPath = path.join dir, reqPath
  path.exists fullPath, (exists) ->
    if not exists
      response.writeHeader 404,
        'Content-Type': 'text/plain'
      response.write '404 Not Found\n'
      reponse.end()
    else
      fs.readFile fullPath, 'binary', (err, file) ->
        if err
          response.writeHeader 500,
            'Content-Type': 'text/plain'
          response.write err + '\n'
          response.end()
        else
          if fullPath.match(/\.css$/)
            response.writeHeader 200,
              'Content-Type': 'text/css'
            response.write file
            response.end()
          else
            response.writeHeader 200
            response.write file, 'binary'
            response.end()

# Start the server
server.listen 8080
sys.puts 'Server now listening on port 8080'