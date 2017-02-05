Easy80-IDE is supposed to be compiled and developed using FPC 3.0.0 or newer and
Lazarus 1.7 or newer. One might try older versions but no support will be 
provided.

Compiling
---------
To compile easy80-ide a number of libraries need to be compiled first and
tools need to be run. Until we have a proper build system this needs to be done
manually. Until that time the following description needs to be followed;

1. install/compile components
  a. external\kcontrols\packages\kcontrols\kcontrolslaz.lpk
  b. lazcontroldsgn.lpk         (lazarus supplied package) 
  
2. build and run tools
  a. tools\hash_update.pp   (this tool will create hash.inc. Needs to be run 
                             before official releases)
  b. tools\icons_update.pp  (this tool will create an image resource file for 
                             the IDE. Needs to be run after each commit)
