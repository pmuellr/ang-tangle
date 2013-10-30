ang-tangle - WEb aPPLicationS
================================================================================

ang-tangle is a tool to easily build the static files for a single-page
web application with multiple views, using [AngularJS](http://angularjs.org/).

You provide your angular views, controllers, services, directives and 
filters, along with the "index.html" of the app, along with
other random files of your choice.

installation
--------------------------------------------------------------------------------

Install globally via: *(`sudo` not needed for windows)*

    sudo npm -g install ang-tangle

This will install a global command `ang-tangle`.

what it does
--------------------------------------------------------------------------------


usage
--------------------------------------------------------------------------------

    ang-tangle [options] directory

directory is a directory of files to ang-tangle-ize

options:

    -b --bower       re-get bower files based on bower-files module
    -c --copy dir    copy directory
    -i --ignore dir  ignore directory
    -o --output dir  output directory
    -v --verbose     be verbose

If you don't specify an output directory, an output directory
of [directory]-out willl be used.

The --ignore and --copy options may be used multiple times. 

Directories that are --ignore'd will not be processed or copied into
the output directory.

Directories that are --copy'd will not be processed but will be copied into
the output directory.

Files and directories that begin with "." (eg, ".git") will be --ignore'd

The directory "bower" will be --copy'd and the directory "bower_components"
will be --ignore'd.  The file "bower-files.coffee" and "bower-files.js" will
be ignored.

The file "index.html" will be copied.

All the remaining files are subject to processing.

Files with the extension ".html", except for "index.html" are added to an
angular constant named "views".  The "views" constant is an object whose keys  
are the base name of the file (no directory, no extension), and the value is
the content of the file.

Files with the extension ".md" are processed with 
[`marked`](https://npmjs.org/package/marked) and then treated like ".html" files.

Files with the extension of ".js" will be concatenated into an "index.js"
file.  The content of the ".js" files will be wrapped with an 
[IFFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression)
which also passes `__filename`, `__dirname`, and `__basename` as parameters.
`__filename` is name of the source file relative to the input directory, 
and `__dirname` is `path.dirname(__filename)`.  `__basename` is the name
of the source file sans directory and extension.  It's useful to use as 
the name of the thing you are registering in angular.

Files with the extension of ".coffee" and ".litcoffee" will be compiled into
JavaScript with [`coffee-script`](https://npmjs.org/package/coffee-script), 
and then treated like ".js" files.

Files with the extension of ".json" are added to an angular constant named "data".
The "data" constant is an object whose keys are the base name of the file, and
the value is the `JSON.parse()` value of the file contents.

Files with the extension of ".cson" are CoffeeScript-formated JSON files.
They will be evaluated with CoffeeScript and then treated like ".json" files.


building `ang-tangle`
--------------------------------------------------------------------------------

To hack on `ang-tangle` code itself, you should first install 
[`jbuild`](https://github.com/pmuellr/jbuild).  Then run
`npm install`, or course.

Run `jbuild` by itself in the project directory to see the tasks available.

To rebuild from the source, run `jbuild build`.

To build the samples, run `jbuild test`.

To go into edit-compile mode, run `jbuild watch`, which will
do a `jbuild build` and then `jbuild test`, and then whenever
a source file changes will re-run those commands.  FOR EVER.



`ang-tangle` home
--------------------------------------------------------------------------------

<https://github.com/pmuellr/ang-tangle>


license
--------------------------------------------------------------------------------

Apache License Version 2.0

<http://www.apache.org/licenses/>
