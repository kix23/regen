# regen
Lazy rainy Sunday...
Here is a Template for Shellscripts with standard Functions.

run:
`regen.sh template/template.sh template/examples/regen.sh regen_updated.sh`

This a Version made things a bit more complicated. To create this Script you have to do some steps:
```bash
./regen.sh ./templates/mod/mod_filecheck.sh ./templates/mod/mod_regen.sh regen_stage_1.sh \
&& ./regen.sh ./templates/template.sh ./regen_stage_1.sh ./regen_stage_2.sh \
&& ./regen.sh ./regen_stage_2.sh ./templates/examples/regen.sh ./regen_stage_3.sh \
&& ./regen_stage_3.sh ./regen_stage_2.sh ./templates/examples/regen.sh ./regen_clone.sh \
&& ./regen_clone.sh ./regen_stage_2.sh ./templates/examples/regen.sh ./regen_clone_test.sh
```

to create updated regen script.  

# Goal
~~Be a script, which creates a Template for other Scripts~~

Be a script, which creates Scripts with an actual Template Version.  

...and you see im trying to get familar with this git thing...

## Status:
Educational use only.  
Modular since 0.001-2a

### What, if template changes?
Ok. I got a few ideas for this.  

## Versioning

Version Sting might be: __0.123-4a__

0. I think it's ready for prod. use if this is >0
1. release with new content.
2. update
3. patch
4. dev
5. a|b alpha / beta

### Version History
__0.001-2a__
+ Moved example/regen.sh to mod/mod_regen.sh
+ example/regen.sh is now the programm file only.
+ Going complete Modular.
+ Added filecheck Module

__0.001-1a__
+ Insert taglines in Template to find Variable Sections
+ Add example directory for Scripts and the Script itself.
+ Moved Vorlagen to template.
+ Added example regen prog.
+ Removed outfile test. Be careful again. :P

__0.001__
+ Be a Script, whitch creates a Template for other Scripts. Done.
+ Chaged versioning

__0.0001a__
+ Insert versioning
+ Restoring comments && insert test if outfile exists ...hmpf...

__0.1 pre__
+ Template and regen script to copy and strip the template.  
