# Dependencies
fs = require 'fs'

# Flag for debugging the module
DEBUG_MODE = false

# Print to console if debugging
debug = (msg) ->
  if DEBUG_MODE
    console.log msg

# Regex
classRegex = /^class\s+(.*)/
classExtendsRegex = /^class\s+(.*?)\s+extends\s+(.*)/
commentLine = /^(\s*)#+\s*(.*)/
multilineComment = /^(\s*)###+/
requireLine = /^(\s*)#_require/
# typeCheck = /@(require|param)/
typeCheck = /@(return|param)\s+\[(.*?)\]\s*(.*)/
openParam = /^\s+#\s+@param\s+\[(.*)/
closeParam = /^\s+#\s+(.*?)\]/
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
    coll = normalizeType(collectionMatch[1])
    inner = normalizeType(collectionMatch[2])
    return "#{coll}.<#{inner}>"
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
  classBuffer = ''
  afterClassDecBuffer = ''
  nonTypeCommentBuffer = ''
  commentBuffer = []
  containsTypeDef = false

  inClass = false
  curClass = ''
  classInd = 0

  classes = []
  superclasses = {}
  for file in files
    contents = fs.readFileSync (file), 'utf8'
    # contents = fs.readFileSync ('app/src/util/Sprite.coffee'), 'utf8'
    # debug contents
    lines = contents.split "\n"
    inComment = false
    inBlockComment = false
    lastSpacing = ''
    params = []
    # Loop over each line
    for line in lines
      if line.length > 0 and not line.match(requireLine)
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
        matches = line.match(commentLine)

        if line.match(multilineComment)
          if inBlockComment
            inBlockComment = false
          else
            inBlockComment = true

        if not inBlockComment and matches and not line.match(multilineComment)
          # Line is a comment
          spacing = matches[1]
          comment = matches[2]
          # debug "Spacing: #{spacing}|"
          # debug "Comment: #{comment}"
          if not inComment
            inComment = true
            commentBuffer.push spacing + '###*\n'
          if line.match(typeCheck)
            typeMatches = line.match(typeCheck)
            containsTypeDef = true
            tag = typeMatches[1]
            type = typeMatches[2]
            desc = typeMatches[3]

            if type.match(collectionType)
              types = type.match(collectionType)
              outer = types[1]
              # if outer.toLowerCase() not in builtInTypes
              #   outer = 'function(new:' + outer + ')'
              # if outer.toLowerCase() in numberTypes
              #   outer = 'number'
              outer = normalizeType(outer)
              inner = types[2]
              type = outer + '.<'
              closing = '>'
              while inner.match(collectionType)
                types = inner.match(collectionType)
                outer = types[1]
                # if outer.toLowerCase() not in builtInTypes
                #   outer = 'function(new:' + outer + ')'
                # if outer.toLowerCase() in numberTypes
                #   outer = 'number'
                outer = normalizeType(outer)
                inner = types[2]
                type += outer + '.<'
                closing += '>'
              # if inner.toLowerCase() not in builtInTypes
              #   inner = 'function(new:' + inner + ')'
              # if inner.toLowerCase() in numberTypes
              #     inner = 'number'
              inner = normalizeType(inner)
              type += inner + closing
            else if type.match(objectType)
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
            commentBuffer.push spacing + '* ' + comment + '\n'
          nonTypeCommentBuffer += line + '\n'
          lastSpacing = spacing
        else
          # Line is not a comment
          if inComment
            # Exit comment
            commentBuffer.push lastSpacing + '###\n'

            if line.match(/[a-zA-Z0-9_]+\s*:\s*(?:\(.*?\))\s*(?:-|=)>/)
              # Line is a function, check for default parameters
              parameters = line.match(/[a-zA-Z0-9_]+\s*:\s*(?:\((.*?)\))\s*(?:-|=)>/)[1]
              params = parameters.split(/, */)
              debug("checking params")
              debug(params)
              for param in params
                if param.indexOf('=') > 0
                  debug "Checking #{param}"
                  debug(commentBuffer)
                  debug param.indexOf('=')
                  paramParts = param.split(/\s*=\s*/)
                  debug paramParts
                  paramName = paramParts[0]
                  paramDefault = paramParts[1]
                  if paramName.indexOf('@') == 0
                    paramName = paramName.substr(1)
                  for i in [1..commentBuffer.length-1]
                    commLine = commentBuffer[i]
                    if commLine.indexOf(paramName) > 0
                      debug "Found #{paramName} in '#{commLine}'"
                      commentBuffer[i] = commLine.replace(/@param \{(.*?)\}/, '@param {$1=}')
                      if paramDefault is 'null'
                        commentBuffer[i] = commentBuffer[i].replace(/@param \{(.*?)\}/, '@param {?$1}')
                      break

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
              if containsTypeDef
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
          if line.match(classRegex) and not inBlockComment
            if line.match(classExtendsRegex)
              matches = line.match(classExtendsRegex)
              curClass = matches[1]
              superClass = matches[2]
              superclasses[curClass] = superClass
            else
              matches = line.match(classRegex)
              # buffer += matches[1] + '\n'
              curClass = matches[1]
            classes.push(curClass)
            inClass = true
            debug("In class #{curClass}")
            classInd = indentation
            debug("Indentation level #{classInd}")
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
          if containsTypeDef
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
  return [superclasses, classes, buffer]
# end codoToJsdoc

jsToClosure = (file, classes, superclasses) ->
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
  headerLines = header.split('\n')

  index = 0
  for headerLine in headerLines
    if headerLine.indexOf('var') == 0
      varLine = headerLine
      break
    index++

  # varLine = headerLines[1]
  if varLine.indexOf('var') == 0
    globalVars = varLine.substr(4).split(', ')
    retainedVars = []
    for globalVar in globalVars
      if globalVar not in classes
        retainedVars.push(globalVar)
    # console.log(retainedVars)
    line = 'var ' + retainedVars.join(';\n var ') + '\n'
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
