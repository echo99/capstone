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
When you first download the repository, you will have to compile the existing
CoffeeScript files and JavaScript libraries. They are excluded from the 
repository to prevent issues merge conflicts.

    cd app
    cake integrate

This will compile two files, `public/app.js` and `public/vendor.js`. You can
now open `public/index.html` in any browser to see our page.

While you are editing the CoffeeScript files, you may want them to be
automatically compiled whenever you make changes to them. You can enable this
feature by running the command:

    cake watch

How cool is that?!