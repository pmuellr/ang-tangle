# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

path          = require "path"
child_process = require "child_process"

bower_files   = require "./bower-files"

samples = ["01", "02"]

mkdir "-p", "tmp"

# base name of this file, for watch()
__basename    = path.basename __filename

exports.build =
    doc: "run a build against the source files"
    run: -> taskBuild()

exports["build-samples"] =
    doc: "build the samples"
    run: -> taskBuildSamples()

exports.watch =
    doc: "watch for source file changes, then build, then build-samples"
    run: -> taskWatch()

exports.clean =
    doc: "clean up transient files"
    run: -> taskClean()

exports["sample-prep"] =
    doc: "get extra files for samples"
    run: -> taskSamplePrep()

#-------------------------------------------------------------------------------
taskClean = ->
    rm "-rf", "lib"
    rm "-rf", "tmp"
    rm "-rf", "bower"
    rm "-rf", "bower_components"

#-------------------------------------------------------------------------------
taskBuild = ->
    coffeec "lib-src", "lib"

#-------------------------------------------------------------------------------
taskBuildSamples = ->
    for sample in samples
        buildSample sample

#-------------------------------------------------------------------------------
taskWatch =  ->
    buildNtest()

    srcs = [
        "lib-src/**/*"
        "www-src/**/*"
    ]

    for sample in samples
        srcs.push "samples/sample-#{sample}/ang/**/*"
        srcs.push "samples/sample-#{sample}/index.html"

    # watch for changes to sources, run a build
    watch
        files: srcs
        run: ->
            buildNtest()

    # watch for changes to this file, then exit
    watch
        files: __basename
        run: ->
            log "file #{__basename} changed; exiting"
            process.exit 0

#-------------------------------------------------------------------------------
taskSamplePrep =  ->
    runBower()

    prepSample sample for sample in samples

#-------------------------------------------------------------------------------
buildSample =  (num) ->
    iDir  = "samples/sample-#{num}/ang"
    oFile = "samples/sample-#{num}/index.js"

    cmd = "node bin/ang-tangle.js #{iDir} #{oFile}"

    log "running #{cmd}"
    exec cmd

#-------------------------------------------------------------------------------
buildNtest =  ->
    taskBuild()
    setTimeout taskBuildSamples, 1000

#-------------------------------------------------------------------------------
runBower =  ->
    bower = which "bower"

    unless bower
        bower = "./node_modules/.bin/bower"

        unless test "-f", bower
            logError "bower is not installed globally or locally"

    mkdir "-p", "bower"
    rm "-rf",   "bower/*"

    for pkgName, pkgSpec of bower_files
        exec "#{bower} install #{pkgName}##{pkgSpec.version}"

        for srcFile, dstDir of pkgSpec.files
            srcFile = path.join "bower_components", pkgName, srcFile
            dstDir  = path.join "bower",            pkgName, dstDir

            mkdir "-p", dstDir
            cp srcFile, dstDir

#-------------------------------------------------------------------------------
prepSample = (num) ->
    dir       = path.join "samples", "sample-#{num}"
    dirBower  = path.join dir, "bower"
    dirImages = path.join dir, "images"

    rm "-rf", dirBower  if test "-d", dirBower
    rm "-rf", dirImages if test "-d", dirImages

    cp "-R", "bower/*",  dirBower
    cp "-R", "images/*", dirImages


#-------------------------------------------------------------------------------
coffeec = (src, out) ->
    log "compiling #{src}/*.coffee to #{out}"

    mkdir "-p", "#{out}"
    rm          "#{out}/*"

    coffee "--compile --bare --output #{out} #{src}/*.coffee"

#-------------------------------------------------------------------------------
coffee = (cmd) ->
    pexec "coffee #{cmd}"

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
