ang-tangle - WEb aPPLicationS
================================================================================

ang-tangle is a tool to easily build the static files for a single-page
web application with multiple views, using

* [AngularJS](http://angularjs.org/)
* [Bootstrap](http://getbootstrap.com/)

and also throws in

* [jQuery](http://jquery.com/)
* [d3](http://d3js.org/)
* [font-awesome](http://fortawesome.github.io/Font-Awesome/)
* [CoffeeScript](http://coffeescript.org/)
* [browserify](http://browserify.org/) (for [Node.js-ish module](http://nodejs.org/api/modules.html) support)

You provide your angular views, controllers, services, directives and 
filters, along with the "shell" of the app (eg, `index.html`), along with
other random files of your choice.

Then run `ang-tangle`, and the following things will happen:

* an `index.html` will be built from the shell of your app
* all the angular bits will be wired together and
  concatenated into a single JavaScript file.
* all the built-in vendor files (jQuery, angular, etc) will
  be added

You should then be able to open the `index.html` file and see your app.

installation
--------------------------------------------------------------------------------

Install globally via: *(`sudo` not needed for windows)*

    sudo npm -g install ang-tangle

This will install a global command `ang-tangle`.




building `ang-tangle`
--------------------------------------------------------------------------------

To hack on `ang-tangle` code itself, you should first install 
[`jbuild`](https://github.com/pmuellr/jbuild).  Run `jbuild`
by itself in the project directory to see the tasks available.

To update the vendor files, edit the `bower-files.coffee` file and
then run `jbuild vendor`.

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
