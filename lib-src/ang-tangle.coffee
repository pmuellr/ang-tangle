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
exports.run = (dir, options={}) ->
    error "no dir specified" if  !dir?

    if !options.output?
        options.output = "#{dir}-out"

    Verbose = !!options.verbose

    main dir, options

    return

#-------------------------------------------------------------------------------
main = (iDir, options) ->
    oDir = options.output

    logv "iDir:    #{iDir}"
    logv "oDir:    #{oDir}"
    logv "options: #{JSON.stringify options, null, 4}"
    logv ""

    log "generating files in #{oDir}"
    sh.mkdir "-p", oDir
    if !sh.test "-d", oDir
        error "unable to create directory #{oDir}"

    fileNames = sh.ls "-R", iDir

    options.copy.push   "bower"
    options.ignore.push "bower_components"

    runBower iDir, options.bower

    files = {}
    for fileName in fileNames
        stats = fs.statSync path.join(iDir, fileName)
        continue unless stats.isFile()

        if fileName in ["index.html"]
            file = null
        else if fileName in ["bower-files.js", "bower-files.coffee"]
            continue

        else if dirMatch options.copy, fileName
            file = null
        else if dirMatch options.ignore, fileName
            continue

        else
            file = getFile(iDir, fileName)

        if !file?
            iFile = path.join iDir, fileName
            oFile = path.join oDir, fileName

            sh.mkdir "-p", path.dirname(oFile)

            sh.cp iFile, oFile
            continue

        files[file.name] = file

    processData  files
    processViews files

    scripts = processScripts files

    out = []

    initScript = scripts.init
    if initScript?
        delete scripts.init
        writeScript out, initScript

    for name, script of scripts
        writeScript out, script

    oFile = path.join oDir, "index.js"
    fs.writeFileSync oFile, out.join "\n"

    return

#-------------------------------------------------------------------------------
runBower = (iDir, force) ->

    unless force
        return if sh.test "-d", path.join(iDir, "bower")

    bowerProgram = sh.which "bower"
    if !bowerProgram
        error "bower is not installed"

    bowerFilesName = path.resolve path.join(iDir, "bower-files")
    try 
        bowerFiles = require bowerFilesName
    catch
        log "creating minimal #{bowerFilesName} module"
        minBowerFilesName = path.join __dirname, "..", "bower-files-template.coffee"
        sh.cp minBowerFilesName, path.join(iDir, "bower-files.coffee")

        bowerFiles = require bowerFilesName

    sh.rm "-rf", path.join(iDir, "bower")            if sh.test "-d", path.join(iDir, "bower") 
    sh.rm "-rf", path.join(iDir, "bower_components") if sh.test "-d", path.join(iDir, "bower_components") 

    origDir = process.cwd()
    process.chdir iDir

    for pkgName, pkgSpec of bowerFiles
        process.chdir
        log "running bower install #{pkgName}##{pkgSpec.version}"
        sh.exec "bower install #{pkgName}##{pkgSpec.version}"

        for srcFile, dstDir of pkgSpec.files
            dstDir = path.join "bower", pkgName, dstDir
            sh.mkdir "-p", dstDir
            srcFile = path.join "bower_components", pkgName, srcFile
            sh.cp srcFile, dstDir

    process.chdir origDir

#-------------------------------------------------------------------------------
dirMatch = (specs, fileName) ->
    for spec in specs
        spec += "/"
        prefix = fileName.slice 0, spec.length
        return true if spec is prefix

    return false

#-------------------------------------------------------------------------------
writeScript = (out, script) ->
    fileName = JSON.stringify script.name
    dirName  = JSON.stringify path.dirname script.name
    baseName = JSON.stringify script.base
    wrapped = """
        ;(function(__filename, __dirname, __basename) {
        #{script.js}
        })(#{fileName}, #{dirName}, #{baseName});
    """

    out.push "//----- #{script.name}"
    out.push wrapped
    out.push ""

#-------------------------------------------------------------------------------
processScripts = (files) ->

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
                    sourceFiles:    [file.name]
                    generatedFile:  "index.js"
                    bare:           true
                    sourceMap:      true
            catch err
                error "error compiling CoffeeScript file #{file.full}: #{err}"


        else if file.type is "litcoffee"
            try
                result = coffee.compile file.contents, 
                    filename:       file.name
                    sourceFiles:    [file.name]
                    generatedFile:  "index.js"
                    bare:           true
                    sourceMap:      true
                    literate:       true
            catch err
                error "error compiling Literate CoffeeScript file #{file.full}: #{err}"

        scripts[file.base]    = files[name]
        scripts[file.base].js = result.js

    return scripts

#-------------------------------------------------------------------------------
processViews = (files) ->

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

        if views[file.base]?
            error "duplicate named view files: #{file.full} and #{views[file.base].full}"

        if file.type is "html"
            html = file.contents

        else if file.type is "md"
            html = marked file.contents

        views[file.base] = html

    file = 
        name: "--views--.coffee" 
        full: "--views--.coffee" 
        base: "--views--" 
        type: "coffee" 
        kind: "script" 

    file.contents = """
        app.constant "views", #{JSON.stringify views, null, 4}
    """

    files[file.name] = file

#-------------------------------------------------------------------------------
processData = (files) ->

    data = {}
    for name, file of files
        continue if file.kind isnt "data"

        if data[file.base]?
            error "duplicate named data files: #{file.full} and #{data[file.base].full}"

        if file.type is "cson"
            js = coffee.compile file.content, bare: true

            try
                object = eval(js)
            catch err
                error "error evaluating cson file #{file.full}: #{err}"


        else if file.type is "json"

            try
                object = JSON.parse file.contents
            catch err
                error "invalid JSON in file #{file.full}: #{err}"

        json = JSON.stringify object, null, 4
            
        data[file.base] = json

    file = 
        name: "--data--.coffee" 
        full: "--data--.coffee" 
        base: "--data--" 
        type: "coffee" 
        kind: "script" 

    file.contents = """
        app.constant "data", #{JSON.stringify data, null, 4}
    """

    files[file.name] = file

#-------------------------------------------------------------------------------
getFile = (dir, name) ->
    switch
        when name.match /.*\.js$/        then type = "js"         
        when name.match /.*\.coffee$/    then type = "coffee"     
        when name.match /.*\.litcoffee$/ then type = "litcoffee"  

        when name.match /.*\.html$/      then type = "html"       
        when name.match /.*\.md$/        then type = "md"         

        when name.match /.*\.json$/      then type = "json"       
        when name.match /.*\.cson$/      then type = "cson"       

        else return 

    switch
        when type is "js"         then kind = "script"
        when type is "coffee"     then kind = "script"
        when type is "litcoffee"  then kind = "script"

        when type is "html"       then kind = "view"
        when type is "md"         then kind = "view"

        when type is "json"       then kind = "data"
        when type is "cson"       then kind = "data"

    full = path.join(dir, name)
    base = path.basename(name).replace /\.\w*$/, ""

    try
        contents = fs.readFileSync full, "utf8"
    catch err
        error "error reading file #{full}: #{err}"

    return {name, full, base, type, kind, contents}

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
# Copyright 2013 Patrick Mueller
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
