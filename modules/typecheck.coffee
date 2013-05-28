# Dependencies
fs = require 'fs'
path = require 'path'
writefile = require 'writefile'

# Flag for debugging the module
DEBUG_MODE = false

# Print to console if debugging
debug = (msg) ->
  if DEBUG_MODE
    console.log msg

# Regexes
CLASS_REGEX = /^class\s+(.*)/
SUBCLASS_REGEX = /^class\s+(.*?)\s+extends\s+(.*)/
COMMENT_REGEX = /^(\s*)#+\s*(.*)/
MULTI_COMMENT_REGEX = /^(\s*)###+/
REQUIRE_REGEX = /^(\s*)#_require/
# TYPE_DEF_REGEX = /@(require|param)/
TYPE_DEF_REGEX = /@(return|param)\s+\[(.*?)\]\s*(.*)/
openParam = /^\s+#\s+@param\s+\[(.*)/
closeParam = /^\s+#\s+(.*?)\]/
SUPPRESS_REGEX = /@suppress\s+/
FUNCTION_REGEX = /^\s*@?[a-zA-Z0-9_]+\s*(?:\:|=)\s*(?:\((.*?)\))\s*(?:-|=)>/
FUNCTION_OPEN_REGEX = /^\s*@?[a-zA-Z0-9_]+\s*(?:\:|=)\s*\((.*)/
FUNCTION_CLOSE_REGEX = /^\s+(.*?)\)\s*(?:-|=)>/
collectionType = /^(.*?)(?:\.)?<(.*)>$/
objectType = /^\{(.*?)\}$/
builtInTypes = ['boolean', 'string', 'number', 'list']
capTypes = ['CanvasRenderingContext2D', 'Array', 'Object']
numberTypes = ['integer', 'double', 'float']
# @HACK For replacing invalid backend documented types
replaceTypes =
  'visibility': 'Object'
  'bool': 'boolean'

normalizeType = (type) ->
  # Check if type is a collection
  collectionMatch = type.match(collectionType)
  if collectionMatch
    outer = normalizeType(collectionMatch[1])
    inner = normalizeType(collectionMatch[2])
    return "#{outer}.<#{inner}>"
  # Normal type
  lcType = type.toLowerCase()
  if lcType in numberTypes
    return 'number'
  else if lcType in builtInTypes
    return lcType
  else if lcType is 'function'
    return 'function(?)'
  else if lcType of replaceTypes
    return replaceTypes[lcType]
  else
    return type

codoToJsdoc = (files) ->
  buffer = ''
  classes = []
  superclasses = {}


  compFiles = []
  # mkdirp = require 'mkdirp'
  # Convert each file separately
  for file in files
    fileBuffer = _codoToJsdoc(file, classes, superclasses)
    buffer += fileBuffer
    dir = path.dirname(file)
    # , (exists) ->
    # unless fs.existsSync('./tmp/' + dir)
    #   fs.mkdirSync('./tmp/' + dir)
    # fs.writeFile './tmp/' + file, fileBuffer
    target = './tmp/' + file
    writefile target, fileBuffer
    if target.match(/\.coffee$/)
      target = target.substr(0, target.length-7) + '.js'
    compFiles.push(target)


  return [superclasses, classes, buffer, compFiles]
# end codoToJsdoc

# Convert an individual CoffeeScript file
# @modifies classes Adds classes found in the file
# @modifies superclasses
_codoToJsdoc = (file, classes, superclasses) ->
  buffer = 'CLOSURE = true\n\n'
  classBuffer = ''
  afterClassDecBuffer = ''
  nonTypeCommentBuffer = ''
  commentBuffer = []
  containsTypeDef = false
  containsSuppress = false

  # Current state variables
  inClass = false
  curClass = ''
  classInd = 0
  inTypeTag = false
  inFunctionDef = false

  contents = fs.readFileSync (file), 'utf8'
  # contents = fs.readFileSync ('app/src/util/Sprite.coffee'), 'utf8'
  # debug contents
  lines = contents.split "\n"
  inComment = false
  inBlockComment = false
  lastSpacing = ''
  indentStr = ''
  params = []

  # Helper functions
  parseFunctionDef = (line) ->
    # Line is a function, check for default parameters
    parameters = line.match(FUNCTION_REGEX)[1]
    params = parameters.split(/, */)
    # debug("checking params")
    # debug(params)
    for param in params
      if param.indexOf('=') > 0
        # debug "Checking #{param}"
        # debug(commentBuffer)
        # debug param.indexOf('=')
        paramParts = param.split(/\s*=\s*/)
        # debug paramParts
        paramName = paramParts[0]
        paramDefault = paramParts[1]
        if paramName.indexOf('@') == 0
          paramName = paramName.substr(1)
        newLines = []
        foundDef = false
        if commentBuffer.length > 1
          for i in [1..commentBuffer.length-1]
            commLine = commentBuffer[i]
            unless commLine?
              console.error 'Comment buffer:'
              console.error commentBuffer
              console.error "Line: #{i}"
              console.error line
            if commLine.indexOf(paramName) > 0
              foundDef = true
              # debug "Found #{paramName} in '#{commLine}'"
              commentBuffer[i] = commLine.replace(/@param \{(.*?)\}/, '@param {$1=}')
              if paramDefault is 'null'
                commentBuffer[i] = commentBuffer[i].replace(/@param \{(.*?)\}/, '@param {?$1}')
              break
        unless foundDef
          type = if paramDefault is 'null' then '?*=' else '*='
          newLines.push(indentStr + "* @param {#{type}} #{paramName}\n")
        commentBuffer.push.apply(commentBuffer, newLines)

  exitComment = (line) ->
    # commentBuffer.push lastSpacing + '###\n'
    if line.match(FUNCTION_REGEX)
      # Line is a function, check for default parameters
      parseFunctionDef(line)
      # parameters = line.match(/[a-zA-Z0-9_]+\s*:\s*(?:\((.*?)\))\s*(?:-|=)>/)[1]
      # params = parameters.split(/, */)
      # debug("checking params")
      # debug(params)
      # for param in params
      #   if param.indexOf('=') > 0
      #     debug "Checking #{param}"
      #     debug(commentBuffer)
      #     debug param.indexOf('=')
      #     paramParts = param.split(/\s*=\s*/)
      #     debug paramParts
      #     paramName = paramParts[0]
      #     paramDefault = paramParts[1]
      #     if paramName.indexOf('@') == 0
      #       paramName = paramName.substr(1)
      #     for i in [1..commentBuffer.length-1]
      #       commLine = commentBuffer[i]
      #       if commLine.indexOf(paramName) > 0
      #         debug "Found #{paramName} in '#{commLine}'"
      #         commentBuffer[i] = commLine.replace(/@param \{(.*?)\}/, '@param {$1=}')
      #         if paramDefault is 'null'
      #           commentBuffer[i] = commentBuffer[i].replace(/@param \{(.*?)\}/, '@param {?$1}')
      #         break
    commentBuffer.push lastSpacing + '###\n'
    if line.indexOf('constructor:') > 0
      # Found constructor!
      # Put the constructor documentation before the class definition so
      # Google closure can see it
      # debug commentBuffer.length
      trimmedBuffer = []
      for commLine in commentBuffer
        # debug i
        # debug(commentBuffer[i])
        # debug commLine.replace(/^\s+/, '')
        trimmedBuffer.push commLine.replace(/^\s+/g, '')
      last = trimmedBuffer.pop()
      trimmedBuffer.push '* @constructor\n'
      classStr = curClass
      if curClass of superclasses
        trimmedBuffer.push "* @extends #{superclasses[curClass]}\n"
        classStr += " extends #{superclasses[curClass]}"
      trimmedBuffer.push(last)
      classBuffer += trimmedBuffer.join('')
      classBuffer += "class #{classStr}\n"
      buffer += classBuffer
      buffer += afterClassDecBuffer
      # buffer += line + '\n'
      classBuffer = ''
      afterClassDecBuffer = ''
      inClass = false
    else
      if containsTypeDef or containsSuppress
        if inClass
          afterClassDecBuffer += commentBuffer.join('')
        else
          buffer += commentBuffer.join('')
      else
        if inClass
          afterClassDecBuffer += nonTypeCommentBuffer
        else
          buffer += nonTypeCommentBuffer
    commentBuffer = []
    nonTypeCommentBuffer = ''
    inComment = false
    containsTypeDef = false
    containsSuppress = false
    # buffers = [commentBuffer, classBuffer, afterClassDecBuffer, nonTypeCommentBuffer]
    # flags = [inComment, inClass, containsTypeDef]
    # return [buffer, buffers, flags]

  # Loop over each line
  for line in lines
    if line.length > 0 and not line.match(REQUIRE_REGEX)
      indentStr = (line.match(/^(\s*)/))[0]
      indentation = indentStr.length
      if inClass and indentation <= classInd
        debug("not in class anymore!")
        buffer += '###*\n'
        buffer += '* @constructor\n'
        classStr = curClass
        if curClass of superclasses
          buffer += "* @extends #{superclasses[curClass]}\n"
          classStr += " extends #{superclasses[curClass]}"
        buffer += '###\n'
        classBuffer += "class #{classStr}\n"
        buffer += classBuffer
        buffer += afterClassDecBuffer
        classBuffer = ''
        afterClassDecBuffer = ''
        inClass = false
        inComment = false
      # else
      #   debug indentation + ': ' + line
      matches = line.match(COMMENT_REGEX)

      if line.match(MULTI_COMMENT_REGEX)
        if inBlockComment
          inBlockComment = false
        else
          inBlockComment = true

      if not inBlockComment and matches and not line.match(MULTI_COMMENT_REGEX)
        # Line is a comment
        spacing = matches[1]
        comment = matches[2]
        # debug "Spacing: #{spacing}|"
        # debug "Comment: #{comment}"
        if not inComment
          inComment = true
          commentBuffer.push spacing + '###*\n'
        if line.match(TYPE_DEF_REGEX)
          typeMatches = line.match(TYPE_DEF_REGEX)
          containsTypeDef = true
          tag = typeMatches[1]
          type = typeMatches[2]
          desc = typeMatches[3]

          if type.match(objectType)
            for jsType in builtInTypes
              type = type.replace(new RegExp(jsType, 'ig'), jsType)
            for numType in numberTypes
              type = type.replace(new RegExp(numType, 'ig'), 'number')
            # for invalType, repl of replaceTypes
            #   type = type.replace(new RegExp(': ?' + invalType, 'ig'), repl)
          else
            # if type.toLowerCase() in numberTypes
            #   type = 'number'
            type = normalizeType(type)
          if type
            commentBuffer.push "#{spacing}* @#{tag} \{#{type}\} #{desc}\n"
          else
            commentBuffer.push "#{spacing}* @#{tag} #{desc}\n"
          params.push
            tag: tag
            type: type
          # commentBuffer += spacing + '* ' + comment + '\n'
        else
          if line.match(SUPPRESS_REGEX)
            containsSuppress = true
          commentBuffer.push spacing + '* ' + comment + '\n'
        nonTypeCommentBuffer += line + '\n'
        lastSpacing = spacing
      else
        # Line is not a comment
        if inComment
          # Exit comment
          # buffers = [commentBuffer, classBuffer, afterClassDecBuffer, nonTypeCommentBuffer]
          # flags = [inComment, inClass, containsTypeDef]
          # [str, buffers, flags] = _exitComment(line, lastSpacing, curClass, superclasses, buffers, flags)
          # buffer += str
          # [commentBuffer, classBuffer, afterClassDecBuffer, nonTypeCommentBuffer] = buffers
          # [inComment, inClass, containsTypeDef] = flags
          exitComment(line)
        else if line.indexOf('constructor:') > 0 and not inBlockComment
          # Found constructor!
          # Put the constructor documentation before the class definition so
          # Google closure can see it
          # debug commentBuffer.length
          # trimmedBuffer = []
          # for commLine in commentBuffer
          #   # debug i
          #   # debug(commentBuffer[i])
          #   # debug commLine.replace(/^\s+/, '')
          #   trimmedBuffer.push commLine.replace(/^\s+/g, '')
          trimmedBuffer = [
            '###*\n'
            '* @constructor\n'
          ]
          commentBuffer = trimmedBuffer
          parseFunctionDef(line) if line.match(FUNCTION_REGEX)
          trimmedBuffer = commentBuffer
          classStr = curClass
          if curClass of superclasses
            trimmedBuffer.push "* @extends #{superclasses[curClass]}\n"
            classStr += " extends #{superclasses[curClass]}"
          trimmedBuffer.push('###\n')
          classBuffer += trimmedBuffer.join('')
          classBuffer += "class #{classStr}\n"
          buffer += classBuffer
          buffer += afterClassDecBuffer
          # buffer += line + '\n'
          classBuffer = ''
          afterClassDecBuffer = ''
          inClass = false
          commentBuffer = []
        else if line.match(FUNCTION_REGEX) and not inBlockComment
          # Add default documentation to function that's missing it
          commentBuffer = [indentStr + '###*\n']
          parseFunctionDef(line)
          commentBuffer.push(indentStr + '###\n')
          if inClass
            afterClassDecBuffer += commentBuffer.join('')
          else
            buffer += commentBuffer.join('')
          commentBuffer = []
        if line.match(CLASS_REGEX) and not inBlockComment
          if line.match(SUBCLASS_REGEX)
            matches = line.match(SUBCLASS_REGEX)
            curClass = matches[1]
            superClass = matches[2]
            superclasses[curClass] = superClass
          else
            matches = line.match(CLASS_REGEX)
            # buffer += matches[1] + '\n'
            curClass = matches[1]
          classes.push(curClass)
          inClass = true
          # debug("In class #{curClass}")
          classInd = indentation
          # debug("Indentation level #{classInd}")
        else
          if line.match(/\{.*?\} = .*/)
            shortHandObjAssignments = line.match(/\{(.*?)\} = (.*)/)
            vars = shortHandObjAssignments[1].split(', ')
            obj = shortHandObjAssignments[2]
            newlines = ''
            for assignedVar in vars
              newlines += indentStr + "#{assignedVar} = #{obj}['#{assignedVar}']\n"
            line = newlines
          if inClass
            afterClassDecBuffer += line + '\n'
          else
            buffer += line + '\n'
    else
      if inComment
        # Exit comment
        commentBuffer.push lastSpacing + '###\n'
        if containsTypeDef or containsSuppress
          if inClass
            afterClassDecBuffer += commentBuffer.join('')
          else
            buffer += commentBuffer.join('')
        else
          if inClass
            afterClassDecBuffer += nonTypeCommentBuffer
          else
            buffer += nonTypeCommentBuffer
        commentBuffer = []
        nonTypeCommentBuffer = ''
        inComment = false
        containsTypeDef = false
        containsSuppress = false
      else
        if inClass
          afterClassDecBuffer += '\n'
        else
          buffer += '\n'
  # debug buffer
  if inClass
    debug("Reached end of file!")
    buffer += '###\n'
    buffer += '* @constructor\n'
    classStr = curClass
    if curClass of superclasses
      buffer += "* @extends #{superclasses[curClass]}\n"
      classStr += " extends #{superclasses[curClass]}"
    buffer += '###\n'
    classBuffer += "class #{classStr}\n"
    buffer += classBuffer
    buffer += afterClassDecBuffer
    classBuffer = ''
    afterClassDecBuffer = ''
    inClass = false
    inComment = false
  return buffer
# end _codoToJsdoc

jsToClosure = (file, classes, superclasses) ->
  debug 'Checking file ' + file
  jsClassDec = /\n([^ .\n]+ = \(function\(.*\n\}\)\((.*?)\);)/g
  # jsClassDec2 = /\n(([^ \n]+) = \(function\([^]*?\n\}\)\((.*?)\);)/
  jsClassDec2 = /\n([^ \n]+ = \(function\([^]*?\n\}\)\(.*?\);)/
  jsClassDec3 = /^([^ \n]+) = \(function\(.*?\{\n([^]*?)\n\}\)\((.*?)\);/
  namespacedClass = /^([a-zA-Z0-9_.]+?)\.([a-zA-Z0-9_]+)$/
  # 1 = classname
  # 2 = body
  # 3 = superclass

  buffer = ''

  contents = fs.readFileSync (file), 'utf8'
  parts = contents.split(jsClassDec2)

  header = parts[0].replace(/__extends.*/, '')
  header = header.replace(/__bind.*/, '')
  headerLines = header.split('\n')

  index = 0
  for headerLine in headerLines
    if headerLine.indexOf('var') == 0
      varLine = headerLine
      break
    index++

  # varLine = headerLines[1]
  if varLine?.indexOf('var') == 0
    globalVars = varLine.substr(4).split(', ')
    lastVar = globalVars[globalVars.length-1]
    end = ''
    if lastVar.match(/,$/)
      globalVars[globalVars.length-1] = lastVar.substr(0, lastVar.length-1)
      end = ','
    else if lastVar.match(/;$/)
      globalVars[globalVars.length-1] = lastVar.substr(0, lastVar.length-1)
      end = ';'
    debug globalVars
    retainedVars = []
    for globalVar in globalVars
      if globalVar not in classes
        retainedVars.push(globalVar)
    # console.log(retainedVars)
    debug retainedVars
    if retainedVars.length > 0
      line = 'var ' + retainedVars.join(';\n var ') + ';\n var'
    else
      line = 'var DUMMY_VAR, '
    # lines.unshift(line)
    headerLines[index] = line
  else
    console.error('Unknown file structure. Expected `var` in line 2.')
  parts[0] = headerLines.join('\n')

  # console.log(parts)
  while parts.length > 1
    beg = parts.shift()
    jsClass = parts.shift()

    buffer += beg
    # debug(jsClass)
    # debug('====================')
    classData = jsClass.match(jsClassDec3)
    className = classData[1]
    classBody = classData[2]
    classExtends = classData[3]
    debug "#{className} extends #{classExtends}"
    nameSpace = ''
    if className.match(namespacedClass)
      matches = className.match(namespacedClass)
      nameSpace = matches[1]
      className = matches[2]
      debug "Namespace: #{nameSpace}"
      debug "className: #{className}"
    # constructorRegex = new RegExp("  function #{className} = ([^]*?)\n  \\};")
    constructorRegex = new RegExp("  function #{className}(\\(\\) \\{\\}|\\(.*?\\) \\{(?:\\n|\\s|\\S)*?\\n  \\})")
    # \(.*?\) \{(\n|\s|\S)*?\n  \}
    # debug classBody.match(constructorRegex)
    matches = classBody.match(constructorRegex)
    # debug "var #{className} = function#{matches[1]}"
    classBodyFrags = classBody.split(constructorRegex)
    beg = classBodyFrags[0]
    end = classBodyFrags[2]
    if classExtends
      beg = beg.replace(/__extends.*/, '')
      # end += "goog.inherits(#{className}, #{classExtends})\n"
      end += "/** @type {?} */\n"
      end += "#{className}.__super__ = {}\n"
    end = end.replace(new RegExp("return #{className};"), '')
    # debug(beg)
    # debug(end)

    if nameSpace
      # debug("Namespace true!")
      # debug "Classname: #{className}"
      buffer += "#{nameSpace}.#{className} = function#{matches[1]}\n"
      # debug("old beg")
      # debug beg
      beg = beg.replace(new RegExp("  #{className}", 'gi'), "  #{nameSpace}.#{className}")
      # debug("new beg")
      # debug beg
      end = end.replace(new RegExp("  #{className}", 'gi'), "  #{nameSpace}.#{className}")
    else
      # debug("Namespace false!")
      buffer += "var #{className} = function#{matches[1]}\n"
    buffer += beg + "\n"
    buffer += end + "\n"
  buffer += parts.shift()
  return buffer
# end jsToClosure

# Export server functions
module.exports =
  codoToJsdoc: codoToJsdoc
  jsToClosure: jsToClosure
