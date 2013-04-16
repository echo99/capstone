fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

# Add to list any modules that cannot be found
missingModules = []
requireOrExit = (moduleName) ->
  try
    module = require moduleName
    return module
  catch e
    console.error("Missing module #{moduleName}")
    missingModules.push(moduleName)
    return null

# Dependencies
coffeelint = null
Rehab = null
getDependencies = ->
  colors = requireOrExit('colors')
  coffeelint = requireOrExit('coffeelint')
  Rehab = requireOrExit('rehab')
getDependencies()

# Constants
APP_JS = 'public/app.js'
VENDOR_JS = 'public/vendor.js'
SRC_DIR = 'app/src'
VENDOR_DIR = 'vendor/scripts'
if process.platform == 'win32'
  APP_JS = 'public\\app.js'
  VENDOR_JS = 'public\\vendor.js'
  SRC_DIR = 'app\\src'
  VENDOR_DIR = 'vendor\\scripts'

coffeeLintConfig =
  no_tabs:
    level: 'error'
  no_trailing_whitespace:
    level: 'error'
  max_line_length:
    value: 80
    level: 'error'
  camel_case_classes:
    level: 'error'
  indentation:
    value: 2
    level: 'error'
  no_implicit_braces:
    level: 'ignore'
  no_trailing_semicolons:
    level: 'error'
  no_plusplus:
    level: 'ignore'
  no_throwing_strings:
    level: 'error'
  no_backticks:
    level: 'warn'
  line_endings:
    value: 'unix'
    level: 'warn'

###############################################################################
# Helper functions

# Wrapper for handling exec calls
wrappedExec = (cmd, showOutput = false, callback = null) ->
  exec cmd, (err, stdout, stderr) ->
    if (showOutput)
      console.log(stdout.toString().trim())
      console.log(stderr.toString().trim())
    throw err if err
    if callback != null
      callback()

# Check for missing dependencies
checkDep = (callback) ->
  if missingModules.length > 0
    console.log("Please wait while required modules are being installed...")
    installDep(callback)
  else
    callback()

# Install missing dependent modules
installDep = (callback = null) ->
  curModuleNum = 0
  installMissingModules = ->
    if curModuleNum < missingModules.length
      moduleName = missingModules[curModuleNum]
      console.log()
      console.log("Installing #{moduleName}...")
      curModuleNum++
      wrappedExec("npm install #{moduleName}", true, installMissingModules)
    else
      getDependencies()
      console.log()
      console.log('All modules have been successfully installed!'.green)
      console.log()
      if callback != null
        callback()
  installMissingModules()

# Compile CoffeeScript output to null to check for syntax errors
checkSyntax = (callback) ->
  nulDir = if process.platform == 'win32' then 'nul' else '/dev/null'

  exec "coffee -p -c #{SRC_DIR} > #{nulDir}", (err, stdout, stderr) ->
    if err
      console.error(err.toString().trim().red)
      callback(false)
    else
      callback(true)

# Helper for finding all source files
getSourceFilePaths = (dirPath = SRC_DIR) ->
  files = []
  for file in fs.readdirSync dirPath
    filepath = path.join dirPath, file
    stats = fs.lstatSync filepath
    if stats.isDirectory()
      files = files.concat getSourceFilePaths filepath
    else if /\.coffee$/.test file
      files.push filepath
  files

###############################################################################
# Tasks

task 'build', 'Build coffee2js using Rehab', sbuild = ->
  checkDep ->
    console.log("Building project from #{SRC_DIR}/*.coffee to #{APP_JS}...".yellow)
    # Try to compile all files individually first, to get a better
    # error message, then if it succeeds, compile them all to one file
    callback = (passed) ->
      if passed
        files = new Rehab().process './'+SRC_DIR

        to_single_file = "--join #{APP_JS}"
        from_files = "--compile #{files.join ' '}"

        exec "coffee #{to_single_file} #{from_files}", (err, stdout, stderr) ->
          if err
            # Should probably figure out way to handle this error
            # However, if it got to this point, there should be no problems
            console.error(err.toString().trim().red)
          else
            console.log('Build successful!'.green)
            console.log()
      # else
      #   console.log('Build failed!'.red)
      #   console.log()

    checkSyntax(callback)

task 'vendcomp', 'Combine vendor scripts into one file', ->
  console.log("Combining vendor scripts to #{VENDOR_JS}".yellow)
  scripts = ''
  dir = VENDOR_DIR
  files = fs.readdirSync dir
  for file in files
    contents = fs.readFileSync (dir+'/'+file), 'utf8'
    scripts += contents
    #name = file.replace /\..*/, '' # remove extension
    #templateJs += "window.#{name} = '#{contents}';"
  try
    fs.writeFile VENDOR_JS, scripts
  catch err
    console.log(err)
  # exec 'echo "hi2"'
  #exec "echo #{scripts} > ../public/vendor.js"

task 'watch', 'Watch all files in src and compile as needed', sbuild = ->
  checkDep ->
    console.log("Watching files #{SRC_DIR}/*.coffee".yellow)

    # Get total number of files
    files = new Rehab().process './'+SRC_DIR
    filesToProcess = files.length

    cmd = 'coffee'
    if process.platform == 'win32'
      cmd = 'coffee.cmd'
    args = ['-wp', SRC_DIR]
    coffee = spawn cmd, args

    coffee.stdout.on 'data', (data) ->
      # Only compile the last time iterating throught all the files
      if filesToProcess > 1
        filesToProcess--
        # console.log(filesToProcess + " files left")
      else
        #console.log('Recompiling files...'.yellow)
        invoke 'build'

task 'integrate', 'Compile and combine all files', sbuild = ->
  invoke 'build'
  invoke 'vendcomp'

task 'minify', 'Minifies all public .js files (requires UglifyJS)', ->
  console.log 'Minifying app.js and vendor.js'

  missingUglify = (error) ->
    console.error(error.toString().trim())
    console.error('UglifyJS may not be installed correctly')
    console.error('Please install using "npm install -g uglify-js"')
    process.exit(error.code)

  exec "uglifyjs #{APP_JS} -o #{APP_JS}", (err, stdout, stderr) ->
    if err
      if process.platform == 'win32'
        # Handle Windows errors
        if err.code == 1
          # 1 = "ERROR_INVALID_FUNCTION"
          missingUglify(err)
      else if err.code == 127
        # 127 = "illegal command"
        missingUglify(err)
      else
        throw err # Unknown error

  exec "uglifyjs #{VENDOR_JS} -o #{VENDOR_JS}", (err, stdout, stderr) ->
    if err
      throw err

task 'check', 'Temporarily compiles coffee files to check syntax', ->
  checkDep ->
    passFunc = (passed) ->
      if passed
        console.log("No errors found".green)
    checkSyntax(passFunc)

# task 'print', 'Do stuff', ->
#   checkDep ->
#     console.log('hello!')
#     console.log()
#     console.log('hello!'.green)

task 'install-dep', 'Install all necessary node modules', ->
  installDep()

task 'lint', 'Check CoffeeScript for lint', ->
  checkDep ->
    console.log("Checking #{SRC_DIR}/*.coffee for lint".yellow)
    pass = "✔".green
    warn = "⚠".yellow
    fail = "✖".red
    getSourceFilePaths().forEach (filepath) ->
      fs.readFile filepath, (err, data) ->
        shortPath = filepath.substr SRC_DIR.length + 1
        result = coffeelint.lint data.toString(), coffeeLintConfig
        if result.length
          hasError = result.some (res) -> res.level is 'error'
          level = if hasError then fail else warn
          console.error "#{level}  #{shortPath}".red
          for res in result
            level = if res.level is 'error' then fail else warn
            console.error("   #{level}  Line #{res.lineNumber}: "
              + res.message)
        else
          console.log("#{pass}  #{shortPath}".green)