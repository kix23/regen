#!/bin/sh
#Create a new Shell Script and strip comments:
#
# Argumente:
#    $1 Infile
#    $2 Outfile
#
[ -r ${1} ] && [ ! -z ${2} ] \
&& cp ${1} ./${2} \
&& shebang_line=$(head -1 ${1}) \
&& sed -Ei '/^\s*#.*|^$|^\s*;|\n/d' ${2} \
&& sed -i '1 i\'${shebang_line}'' ${2} \
&& chmod 755 ./${2}
