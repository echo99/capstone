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