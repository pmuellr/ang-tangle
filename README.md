<tt style="color:limegreen">ang-tangle</tt> - tangles source files into an angular application
================================================================================

<tt style="color:limegreen">ang-tangle</tt> is a tool that can collect your 
static JavaScript, HTML, and JSON resources 
for an [AngularJS](http://angularjs.org/)-based application
into a single .js file, and associated sourcemap for debugging.



installation
--------------------------------------------------------------------------------

Install globally via: 

    sudo npm -g install ang-tangle

*(note: `sudo` not needed for windows)*

This will install a global command <tt style="color:limegreen">ang-tangle</tt>.

If you just want to use it as a tool within your project, you can of course
install locally instead of globally (ie, don't use the -g flag).



what it does
--------------------------------------------------------------------------------

You run <tt style="color:limegreen">ang-tangle</tt> by passing the name of a 
directory which contains your angular JavaScript scripts, HTML files, 
and JSON data files.  <tt style="color:limegreen">ang-tangle</tt> can
also handle CoffeeScript and Markdown files.   

From here in, we'll reference this directory as the "input directory".

In your project, you should create a new directory - the input directory - 
to store these angular resources; and just these angular resources.
<tt style="color:limegreen">ang-tangle</tt>
doesn't handle images, css files, etc.  It only handles the following files:

* `.js`
* `.coffee`
* `.litcoffee`
* `.html`
* `.md`
* `.json`

The input directory should have at least one script in it - `init.js` 
(or `init.coffee` or `init.litcoffee`), which is a script which should 
create your angular module.  

The rest of your angular scripts can be in the input directory also, or any 
subdirectory of the input directory.

<tt style="color:limegreen">ang-tangle</tt> will also take 
`.html` and `.md` files in any directory,
and make them available via a service named `views`.
The `views` service is an object whose properties are the names 
of the `.html` or `.md` files relative to the input directory, 
and the values are the contents of the files.  

<tt style="color:limegreen">ang-tangle</tt> will also take 
`.json` files in any directory, 
and  make them available via a service named `data`.
The `data` service is an object whose properties are the names 
of the `.json` files relative to the input directory,
and values are the `JSON.parse()`d objects of those files.



the `AngTangle` object
--------------------------------------------------------------------------------

Your scripts have access to a object named `AngTangle`.  The `AngTangle` object
has the same methods as the 
[angular `module` object](http://docs.angularjs.org/api/angular.Module), and is
bound to the module you create in the `init` script.

There is one additional method on the `AngTangle` object - `module()`, which
is used to create the module in `init` script.  The signature is the same 
as the [`angular.module()`](http://docs.angularjs.org/api/angular.module)
function.  

You should create your angular module with:

    AngTangle.module(name[, requires], configFn)

just like you do with `angular.module()`.  

If you call the `module()` function with no arguments, it will
return the module you previously created with `AngTangle.module(...)`.

Another goodie is that various registration methods of the angular `module` object,
like [`Module::service()`](http://docs.angularjs.org/api/angular.Module) can
be used without the name parameter.  The name used when making the actual call
will be the name of the script, without any path or extension.  For instance,
if you have file `views/hello.js`, whose contents are:

    AngTangle.controller(function(...){...})

This will be invoked internally as:

    AngTangle.module().controller("hello", function(...){...})



usage
--------------------------------------------------------------------------------

    ang-tangle [options] input-directory output-file
        
        input-directory is a directory of files to ang-tangle-ize
        output-file     is the name of the file to be generated
    
    options:
    
        -v --verbose     be verbose



samples
--------------------------------------------------------------------------------

There are two sample applications available with the project.  Check the 
[samples directory](https://github.com/pmuellr/ang-tangle/tree/master/samples).

You should be able to run the finished samples in your browser using the
awesome [rawgithub.com service](https://rawgithub.com/).

* <https://rawgithub.com/pmuellr/ang-tangle/master/samples/sample-01/index.html>
* <https://rawgithub.com/pmuellr/ang-tangle/master/samples/sample-02/index.html>



building <tt style="color:limegreen">ang-tangle</tt>
--------------------------------------------------------------------------------

To hack on <tt style="color:limegreen">ang-tangle</tt> code itself, you should first install 
[`jbuild`](https://github.com/pmuellr/jbuild).  Then run
`npm install`, or course.

Run `jbuild` by itself in the project directory to see the tasks available.



<tt style="color:limegreen">ang-tangle</tt> home
--------------------------------------------------------------------------------

<https://github.com/pmuellr/ang-tangle>



license
--------------------------------------------------------------------------------

Apache License Version 2.0

<http://www.apache.org/licenses/>
