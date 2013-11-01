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
