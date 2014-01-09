# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

_         = require "underscore"
sh        = require "shelljs"
marked    = require "marked"
coffee    = require "coffee-script"
sourceMap = require "source-map"

pkg = require "../package.json"

Program = pkg.name
Version = pkg.version

Verbose = false

#-------------------------------------------------------------------------------
exports.run = ([iDir, oFile], options={}) ->

    error "no input directory specified" if  !iDir?
    error "no output file specified"     if  !oFile?

    error "input directory is not a directory: #{iDir}" if !sh.test "-d", iDir

    Verbose = !!options.verbose

    main iDir, oFile, options

    return

#-------------------------------------------------------------------------------
main = (iDir, oFile, options) ->
    oFileMap = "#{oFile}.map.json"

    logv "iDir:     #{iDir}"
    logv "oFile:    #{oFile}"
    logv "oFileMap: #{oFileMap}"
    logv "options:  #{JSON.stringify options, null, 4}"
    logv ""

    fileNames = sh.ls "-R", iDir

    files = {}
    for fileName in fileNames
        continue unless sh.test "-f", path.join(iDir, fileName)

        file = getFile(iDir, fileName)

        unless file?
            log "skipping file: #{path.join iDir, fileName}"
            continue

        files[file.name] = file

    processData  iDir, files
    processViews iDir, files

    scripts = processScripts files

    out            = []
    out.sourceNode = new sourceMap.SourceNode

    scriptPrefix = ";(function(){\n"
    scriptSuffix = "\n})();\n"

    out.push           scriptPrefix
    out.sourceNode.add scriptPrefix

    initScript      = scripts["init"]
    angTangleScript = scripts["--ang-tangle--"]

    error "init script required" unless initScript?

    delete scripts["init"]
    delete scripts["--ang-tangle--"]

    writeScript out, initScript, angTangleScript

    for name, script of scripts
        writeScript out, script

    out.push           scriptSuffix
    out.sourceNode.add scriptSuffix

    out.push "//# sourceMappingURL=#{path.basename oFileMap}\n"

    log "generating: #{oFile}"

    sh.mkdir "-p", path.dirname(oFile)
    fs.writeFileSync oFile, out.join ""

    log "generating: #{oFileMap}"

    content = out.sourceNode.toStringWithSourceMap file: path.basename(oFile)
    content = "#{content.map}"
    content = JSON.stringify JSON.parse(content), null, 4

    fs.writeFileSync oFileMap, content

    return

#-------------------------------------------------------------------------------
writeScript = (out, script, angTangleScript) ->
    isInit = false

    if angTangleScript
        isInit = true

        wrappedBefore = "\n//----- #{angTangleScript.name}\n"
        wrappedAfter  = "\n"

        out.push wrappedBefore
        out.push angTangleScript.js
        out.push wrappedAfter

        out.sourceNode.add wrappedBefore
        out.sourceNode.add angTangleScript.js
        out.sourceNode.add wrappedAfter

    fileName = JSON.stringify script.name
    dirName  = JSON.stringify path.dirname script.name
    baseName = JSON.stringify script.base

    if script.sourceMap
        smConsumer = new sourceMap.SourceMapConsumer script.sourceMap
        sourceNode = sourceMap.SourceNode.fromStringWithSourceMap script.js, smConsumer
    else
        sourceNode = new sourceMap.SourceNode 1, 1, script.fileName, script.js

    sourceNode.setSourceContent script.name, script.source

    if isInit
        errorMessage  = "the init script must call AngTangle.module(name, requires[, configFn]) to create the module"
        wrappedBefore = "//----- #{script.name}\n;(function(AngTangle) {\n"
        wrappedAfter  = "\n})(new AngTangle.Init());\nif (!AngTangle.Module) throw Error(#{JSON.stringify(errorMessage)})\n\n"

    else
        wrappedBefore = "//----- #{script.name}\n;(function(AngTangle) {\n"
        wrappedAfter  = "\n})(new AngTangle.Script(AngTangle.Module, #{JSON.stringify script.base}));\n\n"

    wrapped = "#{wrappedBefore}#{script.js}#{wrappedAfter}"

    out.push wrapped

    sourceNode.prepend wrappedBefore
    sourceNode.add     wrappedAfter

    out.sourceNode.add sourceNode

#-------------------------------------------------------------------------------
processScripts = (files) ->

    file =
        name: "--ang-tangle--.coffee"
        full: "--ang-tangle--.coffee"
        base: "--ang-tangle--"
        type: "coffee"
        kind: "script"

    fileName = path.join __dirname, "..", "www-src", "ang-tangle.coffee"

    file.contents = fs.readFileSync fileName, "utf8"
    files[file.name] = file

    scripts = {}
    for name, file of files
        continue if file.kind isnt "script"

        if scripts[file.base]?
            error "duplicate named script files: #{file.full} and #{scripts[file.base].full}"

        if file.type is "js"
            result =
                js: file.contents

        else if file.type is "coffee"
            try
                result = coffee.compile file.contents,
                    filename:       file.name
                    sourceFiles:    [file.full]
                    generatedFile:  "index.js"
                    bare:           true
                    sourceMap:      true
            catch err
                loc = "#{err.location.first_line}:#{err.location.first_column}"
                error "error compiling CoffeeScript file #{file.full}:#{loc}: #{err}"

            v3SourceMap = JSON.parse result.v3SourceMap
            v3SourceMap.sourcesContent = [file.contents]

            result =
                js:         result.js
                sourceMap:  v3SourceMap

        else if file.type is "litcoffee"
            try
                result = coffee.compile file.contents,
                    filename:       file.name
                    sourceFiles:    [file.full]
                    generatedFile:  "index.js"
                    bare:           true
                    sourceMap:      true
                    literate:       true
            catch err
                loc = "#{err.location.first_line}:#{err.location.first_column}"
                error "error compiling Literate CoffeeScript file #{file.full}:#{loc}: #{err}"

            v3SsourceMap = JSON.parse result.v3SourceMap
            v3SsourceMap.sourcesContent = [file.contents]

            result =
                js:         result.js
                sourceMap:  v3SsourceMap

        scripts[file.base]           = files[name]
        scripts[file.base].js        = result.js
        scripts[file.base].source    = file.contents
        scripts[file.base].sourceMap = result.sourceMap

    return scripts

#-------------------------------------------------------------------------------
processViews = (iDir, files) ->

    marked.setOptions
        gfm:            true
        tables:         true
        breaks:         false
        pedantic:       false
        sanitize:       true
        smartLists:     true
        smartypants:    false

    views = {}
    for name, file of files
        continue if file.kind isnt "view"

        if file.type is "html"
            html = file.contents

        else if file.type is "md"
            html = marked file.contents

        dirBaseName = path.join file.dir, file.base
        views[dirBaseName] = html

    file =
        name: "--views--.coffee"
        full: path.join iDir, "--views--.coffee"
        base: "--views--"
        type: "coffee"
        kind: "script"

    file.contents = "AngTangle.constant 'views', #{JSON.stringify views, null, 4}"

    files[file.name] = file

#-------------------------------------------------------------------------------
processData = (iDir, files) ->

    data = {}

    for name, file of files
        continue if file.kind isnt "data"

        if file.type is "json"

            try
                object = JSON.parse file.contents
            catch err
                error "invalid JSON in file #{file.full}: #{err}"

        dirBaseName = path.join file.dir, file.base
        data[dirBaseName] = object

    file =
        name: "--data--.coffee"
        full: path.join iDir, "--data--.coffee"
        base: "--data--"
        type: "coffee"
        kind: "script"

    file.contents = "AngTangle.constant 'data', #{JSON.stringify data, null, 4}"

    files[file.name] = file

#-------------------------------------------------------------------------------
Kinds =
    js:        "script"
    coffee:    "script"
    litcoffee: "script"
    html:      "view"
    md:        "view"
    json:      "data"
    cson:      "data"

#-------------------------------------------------------------------------------
getFile = (dir, name) ->
    switch
        when name.match /.*\.js$/        then type = "js"
        when name.match /.*\.coffee$/    then type = "coffee"
        when name.match /.*\.litcoffee$/ then type = "litcoffee"

        when name.match /.*\.html$/      then type = "html"
        when name.match /.*\.md$/        then type = "md"

        when name.match /.*\.json$/      then type = "json"

        else return

    kind = Kinds[type]
    full = path.join(dir, name)
    dir  = path.dirname name
    base = path.basename(name).replace /\.[^\.]*$/, ""

    try
        contents = fs.readFileSync full, "utf8"
    catch err
        error "error reading file #{full}: #{err}"

    return {name, full, base, dir, type, kind, contents}

#-------------------------------------------------------------------------------
log = (message) ->
    if !message? or message is ""
        message = ""
    else
        message = "#{pkg.name}: #{message}"

    console.log message
    return

#-------------------------------------------------------------------------------
logv = (message) ->
    return if !Verbose
    log message
    return

#-------------------------------------------------------------------------------
error = (message) ->
    log message
    process.exit 1
    return

#-------------------------------------------------------------------------------
getDate = () ->
    date = new Date()

    yr  = date.getFullYear()
    mon = date.getMonth() + 1
    day = date.getDate()
    hr  = date.getHours()
    min = date.getMinutes()
    sec = date.getSeconds()
    ms  = date.getMilliseconds()

    mon = align.right "#{mon}" , 2, 0
    day = align.right "#{day}" , 2, 0
    hr  = align.right "#{hr }" , 2, 0
    min = align.right "#{min}" , 2, 0
    sec = align.right "#{sec}" , 2, 0

    result = "#{yr}-#{mon}-#{day} #{hr}:#{min}:#{sec}"
    return result

#-------------------------------------------------------------------------------
align = (s, dir, len, pad=" ") ->
    switch dir[0]
        when "l" then add = (s) -> "#{s}#{pad}"
        when "r" then add = (s) -> "#{pad}#{s}"
        else throw Error "invalid dir argument to align: #{dir}"

    s   = "#{s}"
    pad = "#{pad}"
    while s.length < len
        s = add s

    return s

#-------------------------------------------------------------------------------
align.left  = (s, len, pad=" ") -> align s, "left",  len, pad
align.right = (s, len, pad=" ") -> align s, "right", len, pad

#-------------------------------------------------------------------------------
# Copyright 2014 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
