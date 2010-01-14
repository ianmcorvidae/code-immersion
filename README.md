Introduction
============

code-immersion was created for Lee Spector's Fall 2009 course at Hampshire College, "Code Immersion". The class blog can be found at [codeimmersion.i3ci.hampshire.edu](http://codeimmersion.i3ci.hampshire.edu/). The homepage for this code is on github [here](http://github.com/ianmcorvidae/code-immersion) and now also at gitorious [here](http://gitorious.org/code-immersion/code-immersion).

code-immersion is a lightweight PLT Scheme framework for collaborative code-sharing, originally implemented to be run on top of drscheme. The server listens for input from clients, who send code to this machine to be dispatched to the group for their perusal and possible use; this process of group creation should (hopefully) be instructive. 

code-immersion is licensed under the GNU Affero General Public License v3 (or, at your choice, higher).

This is a minimal quick-start file until a proper manual can be created.

To run the server
=================

1. Open up runserver.ss in DrScheme.
2. Run it.

Note: if you're running this for anything but the test of everything that's described below, note your IP; you and others will need it when you run the client/daemon. Consult operating system documentation to learn how to do this, or ask someone!

To run the client/daemon
========================

1. Open up runclient.ss in DrScheme.
2. Run it; answer the questions it asks.
3. Open up project.ss in another window and take off!

To test out everything
======================

1. Follow the server instructions above.
2. Follow the client/daemon instructions above (for server address, when it asks, say 'localhost').
3. In the project.ss window type (help). Try all these commands and make sure they work.

Commands
========

+ (sendtext "text")  
   sends text (text must be in double-quotes)
+ (sendcode 'code)  
   sends code (you'll probably want to quote it, as demonstrated)
+ (gettext "name" index)  
   displays text from others (name in double-quotes, index is a number)
+ (getcode "name" index)  
   displays code from others (name in double-quotes, index is a number)
+ (run "name" index)  
   runs code from others (name in double-quotes, index is a number)
+ (reregister)  
   reregisters with server; do this if you aren't getting messages others are sending
+ (users)  
   returns a list of users; do this if you need such a list (perhaps for iteration)
+ (help)  
   displays short help
+ (long-help)  
   displays the text of this section

Note on code
------------

To send more than one s-expression of code at once, use the form ("all" ...) where ... is replaced with your code. So, to send all three of:
>(display 'foo)
>(newline)
>(display 'bar)  

use:
>(sendcode '("all" (display 'foo) (newline) (display 'bar)))
