# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# build file for use with jbuild - https://github.com/pmuellr/jbuild
#-------------------------------------------------------------------------------

path          = require "path"
child_process = require "child_process"

mkdir "-p", "tmp"

# base name of this file, for watch()
__basename    = path.basename __filename

exports.build =
    doc: "run a build against the source files"
    run: -> taskBuild()

exports.test =
    doc: "test the build"
    run: -> taskTest()

exports.watch =
    doc: "watch for source file changes, then rebuild"
    run: -> taskWatch()

exports.clean =
    doc: "clean up transient files"
    run: -> taskClean()

#-------------------------------------------------------------------------------
taskClean = ->
    rm "-rf", "lib"
    rm "-rf", "tmp"

    rm "-rf", "samples/sample-01/bower"
    rm "-rf", "samples/sample-01/bower_components"
    rm "-rf", "samples/sample-01/bower-files.coffee"

    rm "-rf", "samples/sample-02/bower"
    rm "-rf", "samples/sample-02/bower_components"
    rm "-rf", "samples/sample-02/bower-files.coffee"

#-------------------------------------------------------------------------------
taskBuild = ->
    coffeec "lib-src", "lib"

#-------------------------------------------------------------------------------
taskTest = ->
    samples = "01 02".split " "

    for sample in samples
        mkdir "-p", "tmp/sample-#{sample}" 
        rm "-rf", "tmp/sample-#{sample}/*" 

        cmd = """
            node bin/ang-tangle.js 
                --output tmp/sample-#{sample} 
                samples/sample-#{sample}
        """.replace /\s+/g, " "

        log "running #{cmd}"
        exec cmd

#-------------------------------------------------------------------------------
taskWatch =  ->
    buildNtest()

    # watch for changes to sources, run a build
    watch
        files: ["lib-src/**/*"]
        run: -> 
            buildNtest()

    # watch for changes to this file, then exit
    watch
        files: __basename
        run: -> 
            log "file #{__basename} changed; exiting"
            process.exit 0

#-------------------------------------------------------------------------------
buildNtest =  ->
    taskBuild()
    setTimeout taskTest, 1000

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
