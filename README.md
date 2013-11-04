ang-tangle - WEb aPPLicationS
================================================================================

ang-tangle is a tool and small library that can collect your 
static JavaScript, HTML, and JSON resources 
for an [AngularJS](http://angularjs.org/)-based application
into a single .js file (and associated sourcemap for debugging).


installation
--------------------------------------------------------------------------------

Install globally via: 

    sudo npm -g https://github.com/pmuellr/ang-tangle.git

or maybe the package is on npm at this point and you can use:

    sudo npm -g install ang-tangle

*(note: `sudo` not needed for windows)*

This will install a global command `ang-tangle`.

If you just want to use it as a tool within your project, you can of course
install locally instead of globally (ie, don't use the -g flag).



what it does
--------------------------------------------------------------------------------

You run ang-tangle by passing the name of a directory which contains your
angular JavaScript scripts, HTML files, and JSON data files.  ang-tangle can
also handle CoffeeScript, Markdown, and CSON files.  

In your project, you should create a new directory to store these angular
resources; and just these angular resources.

That directory should have one script - `init.js` (or `init.coffee` or `init.litcoffee`),
which is a script which should create your angular module.

The rest of your angular scripts can be in any directories, but the following 
ones are special:

    animations/
    configs/
    constants/
    controllers/
    directives/
    factories/
    filters/
    providers/
    runs/
    services/
    values/
    views/    // <- for view templates and controller scripts

These names correspond with the methods you can invoke on an angular module
to build and configuration your application.

Scripts in these directories will be invoked as 
[IFFE](http://en.wikipedia.org/wiki/Immediately-invoked_function_expression)s,
passing in two parameters for your use:

* `app` - this is the angular module you created in the `init` script
* `register()` - a function to register the appropriate thing in your
  angular script

The `register()` function is also available in the `init` script, and in fact
needs to be used to register the module that you create:

    register(angular.module("myModule", []))

Then, in a script like `factories/thingee`, you can use the `register` function
to register a service called `thingee` with the angular module you registered
in your `init` script, like so:

    register(function() {
        var shinyNewServiceInstance;
        //factory function body that constructs shinyNewServiceInstance
        return shinyNewServiceInstance;
    });

This is the same thing as doing the following, assuming your module is available
in the variable `myModule`:

    myModule.factory('thingee', function() {
        var shinyNewServiceInstance;
        //factory function body that constructs shinyNewServiceInstance
        return shinyNewServiceInstance;
    });

Basically, `register` makes use of the angular module that you registered in 
the `init` script, the name of the directory the script is in, and the name
of the script.  Removes some of the boiler-plate-y-ness.

ang-tangle will also take `.html` and `.md` files in the `views` subdirectory,
and make them available via a service name `views`.  If you will to keep your
view templates and controllers for those views near each other, you can also
place controllers in scripts here, and the `register()` function will register
the specified function as a controller named for the name of the script file.

The `views` service is an object whose properties are the  base names 
(no directories) of the `.html` or `.md` files, and the values are the 
contents of the files.  

This makes it easy to do your routing without making the browser fetch the
templates remotely.  For instance, you might have a script called 
`configs/routes.js` that looks like this:

    register(function($routeProvider, views) {
        $routeProvider.otherwise({redirectTo: "/"})

        $routeProvider.when("/page1", {
            template: views.page1,
            controller: "page1"
        })

        $routeProvider.when("/page2", {
            template: views.page2,
            controller: "page2"
        })

ang-tangle will also take `.json` and `.cson` files in any directory, and 
make them available via a service named `data`.

The `data` service is an object whose properties are the full file names 
(relative to the main directory) of the `.json` or `.cson` files, and the 
values are the `JSON.parse()`d objects of those files.

Of course, you don't **need** to use the `register()` if you don't want to,
but you will need it if you want to make use of the `views` and `data`
services.  In that case, at least call `register()` in the `init` script to
register the module.

usage
--------------------------------------------------------------------------------

    ang-tangle [options] input-directory output-file
        
        input-directory is a directory of files to ang-tangle-ize
        output-file     is the name of the file to be generated
    
    options:
    
        -v --verbose     be verbose



building `ang-tangle`
--------------------------------------------------------------------------------

To hack on `ang-tangle` code itself, you should first install 
[`jbuild`](https://github.com/pmuellr/jbuild).  Then run
`npm install`, or course.

Run `jbuild` by itself in the project directory to see the tasks available.



`ang-tangle` home
--------------------------------------------------------------------------------

<https://github.com/pmuellr/ang-tangle>



license
--------------------------------------------------------------------------------

Apache License Version 2.0

<http://www.apache.org/licenses/>
