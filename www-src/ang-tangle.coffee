# Licensed under the Apache License. See footer for details.

AngTangle =

    OneArgMethods: [
        "config"
        "run"
    ]

    TwoArgMethods: [
        "animation"
        "constant"
        "controller"
        "directive"
        "factory"
        "filter"
        "provider"
        "service"
        "value"
    ]


#-------------------------------------------------------------------------------
class AngTangle.Init

    #---------------------------------------------------------------------------
    constructor: ->

        getOneArgFunction = (module, method) ->
            (thing) ->
                throw Error "module not defined in init script" unless module?
                module[method].call module, thing

        getTwoArgFunction = (module, method) ->
            (name, thing) ->
                throw Error "module not defined in init script" unless module?
                module[method].call module, name, thing

        for method in AngTangle.OneArgMethods
            @[method] = getOneArgFunction AngTangle.Module, method

        for method in AngTangle.TwoArgMethods
            @[method] = getTwoArgFunction AngTangle.Module, method


    #---------------------------------------------------------------------------
    module: (args...) ->

        unless args.length is 0
            throw Error "module() method called twice" if AngTangle.Module?

            AngTangle.Module = angular.module.apply(angular, args)

        return AngTangle.Module

#-------------------------------------------------------------------------------
class AngTangle.Script

    #---------------------------------------------------------------------------
    constructor: (@module, @scriptName) ->

        getOneArgFunction = (module, method) ->
            (thing) ->
                throw Error "module not defined in init script" unless module?
                module[method].call module, thing

        getTwoArgFunction = (module, method, scriptName) ->
            (name, thing) ->
                unless thing
                    thing = name
                    name  = scriptName

                throw Error "module not defined in init script" unless module?
                module[method].call module, name, thing

        for method in AngTangle.OneArgMethods
            @[method] = getOneArgFunction @module, method

        for method in AngTangle.TwoArgMethods
            @[method] = getTwoArgFunction @module, method, @scriptName

        return @

    #---------------------------------------------------------------------------
    module: () ->
        return @module

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
