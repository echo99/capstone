Capstone Game
=============

Setup
-----
Before you can start programming in CoffeeScript, you will have to set up your
programming environment.

First, make sure you have [node.js](http://nodejs.org/) installed.

Then, install CoffeeScript using the following command:

    npm install -g coffee-script

These other tools may also be helpful to install:

    npm install -g uglify-js
    npm install -g coffeelint


Compiling
---------
For your convenience, there is a Cakefile located in the root of the
repository. This file defines many CoffeeScript-related tasks that you can run
from the terminal. The first time you run any cake task, you may notice that it
will take some time to install all of the required node modules. Do not worry,
for this will only happen once, or whenever a new module is added to the
Cakefile.

When you first download the repository, you will have to compile the
CoffeeScript source files and JavaScript libraries into the client JavaScript
files. They are excluded from the repository to prevent issues with merge
conflicts. From the repo's root directory, run the following command:

    cake integrate

This will compile two files, `public/app.js` and `public/vendor.js`. You can
now open `public/index.html` in any browser to see our game page. Or, you can
got to `public/setup.html`, which has a button that will open the game in a new
window.

While you are editing the CoffeeScript files, you may want them to be
automatically compiled whenever you make changes to them. You can enable this
feature by running the command:

    cake watch

How cool is that?!

If you want to see all the available cake tasks and their descriptions, simply
run:

    cake


Running
-------
Now that you've compiled the code, you probably want to try running it. There
are two options to do so:

1) Open `public/index.html` in any browser. For Chrome, you will have to
   disable web security to open local web files.

2) Run `coffee server.coffee` from the root of the repository. This will start
   a node server. Once it starts, you can open `http://localhost:8080` in any
   browser to view the main page.


Coding Conventions
------------------
Basically, just check for lint problems as you are working on your files. The
Cakefile has been set up so that it will check for problems each time your code
passes the syntax checker. Other than that, document your code as well as you
can so that others can understand how to use your APIs or what you are doing.

### Indentation
We are using two spaces to indent. *DO NOT USE TABS!!!*

### Line Width
85 characters max per line. This helps keep code readable especially on small
screens, or for putting code side-by-side.

### Documentation
We are using [Codo](https://github.com/netzpirat/codo) format to document our
code. Using this allows us to generate nice documentation files. You can
install it using `npm install -g codo`. The following is an example class
documented in codo:

```CoffeeScript
# The base animal class
#
class Animal

  # Construct a new animal
  #
  # @param [String] name The name of the animal
  #
  constructor: (@name) ->

  # Get the animal's name
  #
  # @return [String] Name of animal
  #
  getName: ->
    return @name
```


IDEs and Plugins
----------------
### Emacs


### NetBeans
[NetBeans](https://netbeans.org/)  
[NetBeans CoffeeScript Plugin](http://plugins.netbeans.org/plugin/39007)

### Sublime Text 2
[Sublime Text 2](http://www.sublimetext.com/2)  
[Sublime Better CoffeeScript](https://github.com/aponxi/sublime-better-coffeescript) -
  CoffeeScript syntax highlighting and more  
[CoffeeComplete Plus](https://github.com/justinmahar/SublimeCSAutocompletePlus#customizing-autocomplete-trigger) -
  CoffeeScript autocompletion  
[SublimeLinter](https://github.com/slang800/SublimeLinter) -
  Sublime Text linter with CoffeeScript support