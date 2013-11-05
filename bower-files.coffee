# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# Instructions on components to install from bower, and where to copy relevant
# files
#
# The basic structure is that this module exports an object whose property
# names are the bower packages to install.  The property values associated
# with a package are objects with two properties: 
#    version: the version to install
#    files:   an object specifying file names and directories to copy them
#             into
# 
# for the files property, the name will be relative to 
#     bower_components/package
# and the directory to copy to is relative to
#     bower/package
#-------------------------------------------------------------------------------

module.exports =

    jquery:
        version: "2.0.x"
        files: 
            "jquery.js":                "."
            "jquery.min.js":            "."
            "jquery.min.map":           "."

    angular: 
        version: "1.0.x"
        files:
            "angular.js":               "."
            "angular.min.js":           "."

    bootstrap: 
        version: "3.0.x"
        files:
            "dist/css/*":               "css"
            "dist/fonts/*":             "fonts"
            "dist/js/*":                "js"
#            
#    "font-awesome": 
#        version: "3.2.x"
#        files:
#            "css/*":                    "css"
#            "font/*":                   "font"
#
#    d3: 
#        version: "3.3.x"
#        files:
#            "d3.js":                    "."
#            "d3.min.js":                "."

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
