# Licensed under the Apache License. See footer for details.

path = require "path"

_    = require "underscore"
nopt = require "nopt"

pkg    = require "../package.json"
angTangle = require "./ang-tangle"


cli = exports

#-------------------------------------------------------------------------------
cli.main = (args) ->
    help() if args.length is 0 
    help() if args[0] in ["?", "-?", "--?"]

    opts = 
        verbose: [ "v", Boolean ]
        help:    [ "h", Boolean ]

    longOpts  = {}
    shortOpts = {}
    for name, opt of opts
        shortOpts[opt[0]] = "--#{name}" for name, opt of opts
        longOpts[name]    = opt[1] 

    parsed = nopt longOpts, shortOpts, args, 0

    help() if parsed.help

    args = parsed.argv.remain
    opts = _.pick parsed, _.keys longOpts

    help() if args.length is 0 
    
    angTangle.run args, opts

    return

#-------------------------------------------------------------------------------
help = ->
    console.log """
        #{pkg.name} [options] input-directory output-file
        
            input-directory is a directory of files to ang-tangle-ize
            output-file     is the name of the file to be generated
        
        options:
        
            -v --verbose     be verbose
        
        version: #{pkg.version}; for more info: #{pkg.homepage}    
    """

    process.exit 1

#-------------------------------------------------------------------------------
cli.main.call null, (process.argv.slice 2) if require.main is module


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
