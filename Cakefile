fs = require 'fs'
path = require 'path'
{spawn, exec} = require 'child_process'

# Add to list any modules that cannot be found
missingModules = []
tryRequire = (moduleName) ->
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
  colors = tryRequire('colors')
  coffeelint = tryRequire('coffeelint')
  Rehab = tryRequire('rehab')
getDependencies()

PLATFORM = process.platform

Platform =
  WINDOWS: 'win32'
  LINUX: 'linux'

SLASH = if PLATFORM == Platform.WINDOWS then '\\' else '/'

# Constants
APP_JS = "public#{SLASH}app.js"
VENDOR_JS = "public#{SLASH}vendor.js"
SRC_DIR = "app#{SLASH}src"
VENDOR_DIR = "vendor#{SLASH}scripts"
VENDOR_STYLES = "vendor#{SLASH}stylesheets"
VENDOR_CSS = "public#{SLASH}vendor.css"
NODE_DIR = ".#{SLASH}node_modules"
NODE_BIN_DIR = NODE_DIR + SLASH + '.bin'
RHINO_DIR = "vendor#{SLASH}tools"
HOME_FROM_RHINO = "..#{SLASH}.."
# if process.platform == 'win32'
#   APP_JS = 'public\\app.js'
#   VENDOR_JS = 'public\\vendor.js'
#   SRC_DIR = 'app\\src'
#   VENDOR_DIR = 'vendor\\scripts'
# Flag to make sure we aren't calling build multiple times at once
BUILDING = false
WATCHING = false

coffeeLintConfig =
  no_tabs:
    level: 'error'
  no_trailing_whitespace:
    level: 'error'
  max_line_length:
    value: 85
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
    level: 'ignore'

MessageLevel =
  INFO: 'info'
  WARN: 'warn'
  ERROR: 'error'

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
      # There are still more modules to load
      moduleName = missingModules[curModuleNum]
      console.log()
      console.log("Installing #{moduleName}...")
      curModuleNum++
      wrappedExec("npm install #{moduleName}", true, installMissingModules)
    else
      # All done! Reload dependencies
      getDependencies()
      # Print success message
      console.log()
      console.log('All modules have been successfully installed!'.green)
      console.log()
      # Empty missing modules
      missingModules = []
      # Call callback function if one was given
      if callback != null
        callback()
  installMissingModules()

# Check to see if a global node module is missing, and if it isn't executes the
# callback
checkGlobalModule = (moduleName, modulePkg, cmd, failOnError, callback) ->
  exec "#{cmd} -h", (err, stdout, stderr) ->
    if err
      if PLATFORM == Platform.WINDOWS
        # Handle Windows errors
        if err.code == 1
          # 1 = "ERROR_INVALID_FUNCTION"
          missingGlobalModule(moduleName, modulePkg, err) if failOnError
      else if err.code == 127
        # 127 = "illegal command"
        missingGlobalModule(moduleName, modulePkg, err) if failOnError
      else
        throw err # Unknown error
      callback(false)
    else
      callback(true)

# Handle missing global modules
missingGlobalModule = (moduleName, modulePkg, error) ->
  console.error(error.toString().trim().red)
  console.error("#{moduleName} may not be installed correctly".red)
  console.error("Please install using \"npm install -g #{modulePkg}\"".red)
  process.exit(error.code)

# Compile CoffeeScript output to null to check for syntax errors
checkSyntax = (callback) ->
  nulDir = if process.platform == 'win32' then 'nul' else '/dev/null'

  exec "coffee -p -c #{SRC_DIR} > #{nulDir}", (err, stdout, stderr) ->
    if err
      console.error(err.toString().trim().red)
      notify("Build failed! Please check the terminal for details.",
        MessageLevel.ERROR) if WATCHING
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

# Sends a system notification
notify = (message, msgLvl) ->
  switch PLATFORM
    when Platform.WINDOWS
      notifu = '.\\vendor\\tools\\notifu'
      time = 5000
      switch msgLvl
        when MessageLevel.INFO
          time = 3000
        when MessageLevel.WARN
          time = 5000
        when MessageLevel.ERROR
          time = 10000
      spawn notifu, ['/p', 'Cake Status', '/m', message, '/t', msgLvl]
    when Platform.LINUX
      cmd = 'notify-send'
      icon = ''
      time = 5000
      switch msgLvl
        when MessageLevel.INFO
          icon += 'dialog-information'
          time = 3000
        when MessageLevel.WARN
          icon += 'dialog-warning'
          time = 5000
        when MessageLevel.ERROR
          icon += 'dialog-error'
          time = 10000
      spawn cmd, ['--hint=int:transient:1', '-i', icon, '-t', time, 'Cake Status',
        message]

#
jsSanityCheck = (options, callback) ->
  process.chdir(RHINO_DIR)
  options.verbose ?= 'verbose' of options
  exec 'java -jar js.jar -opt -1 testrun.js', (err, stdout, stderr) ->
    console.log(stdout) if stdout and options.verbose
    console.error(stderr.red) if stderr
    process.chdir(HOME_FROM_RHINO)
    if err
      callback(false)
    else
      callback(true)

###############################################################################
# Options

option '-v', '--verbose', 'Print out verbose output'
option null, '--no-doc', 'Don\'t document the source files when building'
option null, '--no-rhino', 'Don\'t try to run the script with rhino'

###############################################################################
# Tasks

task 'build', 'Build coffee2js using Rehab', sbuild = (options) ->
  options['no-doc'] ?= 'no-doc' of options
  options['no-rhino'] ?= 'no-rhino' of options
  if not BUILDING
    BUILDING = true
    checkDep ->
      invoke 'vendcomp'
      console.log(
        "Building project from #{SRC_DIR}#{SLASH}*.coffee to #{APP_JS}...".yellow)
      # Try to compile all files individually first, to get a better
      # error message, then if it succeeds, compile them all to one file
      callback = (passed) ->
        if passed
          files = new Rehab().process './'+SRC_DIR

          to_single_file = "--join #{APP_JS}"
          from_files = "--compile #{files.join ' '}"

          exec "coffee #{to_single_file} #{from_files}",
            (err, stdout, stderr) ->
              if err
                # Should probably figure out way to handle this error
                # However, if it got to this point, there should be no problems
                console.error(err.toString().trim().red)
              else
                # notify("Build successful!", MessageLevel.INFO) if WATCHING
                console.log('Build successful!'.green)
                # console.log()
              if options['no-rhino']
                invoke 'lint'
                invoke 'doc' if not options['no-doc']
              else
                console.log('Doing test run on compiled script...'.yellow)
                jsSanityCheck options, (passed) ->
                  if passed
                    console.log('Test passed!'.green)
                    invoke 'lint'
                    invoke 'doc' if not options['no-doc']
                  else
                    notify('Compiled app.js file failed to run!', MessageLevel.ERROR)
                    console.error('Test run failed!'.red)
        else
          invoke 'lint'
        BUILDING = false
        # else
        #   console.log('Build failed!'.red)
        #   console.log()

      checkSyntax(callback)

task 'vendcomp', 'Combine vendor scripts into one file', ->
  console.log("Combining vendor scripts to #{VENDOR_JS}".yellow)
  scripts = ''
  dir = VENDOR_DIR
  # files = fs.readdirSync dir
  files = [
    'browserdetect.js',
    'jquery-1.9.1.min.js',
    'jqModal.js',
    'soundjs-0.4.0.min.js',
    'soundjs.flashplugin-0.4.0.min.js'
  ]
  for file in files
    contents = fs.readFileSync (dir+'/'+file), 'utf8'
    scripts += contents + "\n"
    #name = file.replace /\..*/, '' # remove extension
    #templateJs += "window.#{name} = '#{contents}';"
  try
    fs.writeFile VENDOR_JS, scripts
  catch err
    console.log(err)

  console.log("Combining vendor styles to #{VENDOR_CSS}".yellow)
  styles = ''
  dir = VENDOR_STYLES
  files = fs.readdirSync dir
  for file in files
    contents = fs.readFileSync (dir+'/'+file), 'utf8'
    styles += contents + "\n"
    #name = file.replace /\..*/, '' # remove extension
    #templateJs += "window.#{name} = '#{contents}';"
  try
    fs.writeFile VENDOR_CSS, styles
  catch err
    console.log(err)
  # exec 'echo "hi2"'
  #exec "echo #{scripts} > ../public/vendor.js"

# task 'test', 'Task for testing cake stuff', ->
#   filesToProcess = 0
#   exec "coffee -p #{SRC_DIR}", (err, stdout, stderr) ->
#     filesToProcess++
#     console.log("Finished!".green)
#     # console.log(err)
#     # console.log(stdout)
#     # parts = stdout.split(/^\}\)\.call\(this\);$/)
#     parts = stdout.split("(function() {\n\n\n}).call(this);")
#     console.log("Num files :  #{parts.length}")
#     # console.log(stderr)


task 'watch', 'Watch all files in src and compile as needed', sbuild = ->
  WATCHING = true
  checkDep ->
    console.log("Watching files #{SRC_DIR}#{SLASH}*.coffee".yellow)

    # Get total number of files
    files = new Rehab().process './'+SRC_DIR
    filesToProcess = files.length

    # # Get number of empty files
    # emptyFiles = 0
    # exec "coffee -p #{SRC_DIR}", (err, stdout, stderr) ->
    #   parts = stdout.split("(function() {\n\n\n}).call(this);")
    #   emptyFiles = parts.length
    #   filesToProcess -= emptyFiles

    cmd = 'coffee'
    if process.platform == 'win32'
      cmd = 'coffee.cmd'
    args = ['-wp', SRC_DIR]
    coffee = spawn cmd, args

    coffee.stdout.on 'data', (data) ->
      # # Only compile the last time iterating throught all the files
      # if filesToProcess > 1
      #   filesToProcess--
      #   console.log(filesToProcess + " files left")
      # else
      #   #console.log('Recompiling files...'.yellow)
      #   invoke 'build'

      # This will execute each time the script picks up something from stdout,
      # including multiple outputs the first time printing everything, but
      # I haven't yet come up with a way around it.
      invoke 'build'

task 'integrate', 'Compile and combine all files', sbuild = ->
  invoke 'build'
  invoke 'vendcomp'

task 'minify', 'Minifies all public .js files (requires UglifyJS)', ->
  console.log 'Minifying app.js and vendor.js'

  checkGlobalModule 'UglifyJS', 'uglify-js', 'uglifyjs', true, (hasModule = false) ->
    exec "uglifyjs #{APP_JS} -o #{APP_JS}", (err, stdout, stderr) ->
      throw err if err

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
# task 'print', 'Dummy task for testing purposes', ->
#   # exec "pwd", (err, stdout, stderr) ->
#   #   console.log stdout
#   #   exec "cd app", (err, stdout, stderr) ->
#   #     console.log stdout
#   #     exec "pwd", (err, stdout, stderr) ->
#   #       console.log stdout
#   console.log('Starting directory: ' + process.cwd())
#   try
#     process.chdir('app')
#     console.log('New directory: ' + process.cwd())
#   catch err
#     console.log('chdir: ' + err)

task 'install-dep', 'Install all necessary node modules', ->
  installDep()

task 'lint', 'Check CoffeeScript for lint using Coffeelint', (options) ->
  checkDep ->
    options.verbose ?= 'verbose' of options
    console.log("Checking #{SRC_DIR}#{SLASH}*.coffee for lint".yellow)
    pass = "✔".green
    warn = "⚠".yellow
    fail = "✖".red
    if process.platform == 'win32'
      pass = "√".green
      warn = "!".yellow
      fail = "x".red
    failCount = 0
    fileFailCount = 0
    errorCount = 0
    # errorFileCount = 0
    files = getSourceFilePaths()
    filesToLint = files.length
    files.forEach (filepath) ->
    # getSourceFilePaths().forEach (filepath) ->
      fs.readFile filepath, (err, data) ->
        filesToLint--
        shortPath = filepath.substr SRC_DIR.length + 1
        try
          result = coffeelint.lint data.toString(), coffeeLintConfig
          if result.length
            fileFailCount++
            hasError = result.some (res) -> res.level is 'error'
            level = if hasError then fail else warn
            console.error "#{level}  #{shortPath}".red
            for res in result
              failCount++
              level = if res.level is 'error' then fail else warn
              console.error("   #{level}  Line #{res.lineNumber}: #{res.message}")
          else if options.verbose
            console.log("#{pass}  #{shortPath}".green)
          if filesToLint == 0
            # console.log("#{failCount} lint failures")
            if failCount > 0
              notify("Build succeeded, but #{failCount} lint errors were " +
                "found! Please check the terminal for more details.",
                MessageLevel.ERROR) if WATCHING
              console.error("\n")
              if errorCount > 0
                console.error(("#{errorCount} syntax error(s) found!").red.bold)
              console.error(("#{failCount} lint error(s) found in " +
                "#{fileFailCount} file(s)!").red.bold)
              console.error("As a reminder:".grey.underline)
              console.error("- Indentation is two spaces. No tabs allowed".grey)
              console.error(("- Maximum line width is " +
                "#{coffeeLintConfig.max_line_length.value} characters").grey)
            else
              notify("Build succeeded. All files passed lint.",
                MessageLevel.INFO) if WATCHING
              console.log('No lint errors found!'.green)
            console.log("") if WATCHING
        catch e
          errorCount++
          console.error("#{filepath}: #{e}".red)
          # return e

task 'doc', 'Document the source code using Codo', (options) ->
  lastResortCodoFix = (cmd, callback=null) ->
    console.log('Documenting with codo failed'.red)
    try
      # if process.platform == 'win32'
      #   process.chdir('node_modules\\codo')
      # else
      #   process.chdir('node_modules/codo')
      process.chdir("#{NODE_DIR}#{SLASH}codo")
      console.log('Attempting to force installation of walkdir v0.0.5...'.yellow)
      exec "npm install walkdir@0.0.5", (err, stdout, stderr) ->
        # console.log(stdout)
        throw err if err
        # if process.platform == 'win32'
        #   process.chdir('..\\..')
        # else
        #   process.chdir('../..')
        process.chdir("..#{SLASH}..")
        console.log('Installation successful'.green)
        console.log('Attempting to run codo again...'.yellow)
        exec cmd, (err, stdout, stderr) ->
          console.log(stdout)
          throw err if err

      # console.log('New directory: ' + process.cwd())
    catch err
      console.log('chdir: ' + err)

  checkDep ->
    console.log("Documenting CoffeeScript in #{SRC_DIR} to doc...".yellow)
    checkGlobalModule 'Codo', 'codo', 'codo', false, (hasModule = false) ->
      # cmd = './node_modules/.bin/codo'
      # if process.platform == 'win32'
      #   cmd = '.\\node_modules\\.bin\\codo'
      cmd = "#{NODE_BIN_DIR}#{SLASH}codo"
      if hasModule
        exec "codo #{SRC_DIR}", (err, stdout, stderr) ->
          console.log(stdout)
          # throw err if err
          lastResortCodoFix(cmd) if err
      else
        tryRequire('codo')
        checkDep ->
          exec cmd + " " + SRC_DIR, (err, stdout, stderr) ->
            console.log(stdout)
            # throw err if err
            lastResortCodoFix(cmd) if err

# REPORTER = "min"

# task "test", "run tests", ->
#   exec "NODE_ENV=test
#     ./node_modules/.bin/mocha
#     --compilers coffee:coffee-script
#     --reporter #{REPORTER}
#     --require coffee-script
#     --require test/test_helper.coffee
#     --colors
#   ", (err, output) ->
#     throw err if err
#     console.log output

task "test", "Run tests", (options) ->
  tryRequire('mocha')
  tryRequire('chai')
  tryRequire('coffee-script')
  reporter =  if 'verbose' of options then 'spec' else 'dot'
  checkDep ->
    # cmd = './node_modules/.bin/mocha'
    cmd = "#{NODE_BIN_DIR}#{SLASH}mocha"
    args = [
      " --compilers coffee:coffee-script"
      "-u tdd --reporter #{reporter}"
      "--require coffee-script"
      "--require test/helpers/test_helper.coffee"
      "--colors"
    ].join(' ')
    # if process.platform == 'win32'
    #   cmd = '.\\node_modules\\.bin\\mocha'
    exec cmd + args, (err, output, stderr) ->
      console.log(output) if output
      console.log(stderr) if stderr
      # throw err if err
