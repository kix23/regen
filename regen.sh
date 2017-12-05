#!/bin/sh
###
# Shell Script Template
# Version: 0.1
###

# Usage hint
hilfe() {
	echo "Usage: "$(basename ${0})" [-hv] infile outflie";
}

# debug_lvl legt die Gesprächigkeit der Bildschirmausgabe fest
# Normal: 2
debug_lvl="2"
# log_lvl legt die Gesprächigkeit der in der Logdatei fest.
# Um Datei logging auschzuschalten - log lvl unter niedrigsten verbose Aufruf lassen.
log_lvl="0"
log_file="./script.log"

while getopts hv opt
	do
	 case ${opt} in
		 h) hilfe && exit;;
		 v) debug_lvl=$((${debug_lvl}+1));;
		 *) hilfe && return 1;;
	 esac
	done
# Falls Argumente nach Optionen Zeiger zurücksetzen.
shift $(($OPTIND-1))

##
# Verbose Ausgabe und Logging
#
#	Argumente:
#		$1 Loglevel
#		$2 Ausgabestring
#
verbose(){
	if [ "$1" != "" ]; then
		[ ${debug_lvl} -ge $1 ] && echo "# "$2;
		[ ${log_lvl} -ge $1 ] && ( touch ${log_file} && echo "# "${2} >> ${log_file} );
		return 0;
	fi;
}
# Verbose Module ENDE
##

# Create a new Shell Script and strip comments:
#
# Argumente:
#    $1 Infile
#    $2 Outfile
#
[ -r ${1} ] && [ ! -z ${2} ] \
&& verbose 5 "Readable Input file found:" ${1} \
|| (verbose 1 "No readable Input file found." && return 1 ) || exit \
&& verbose 3 "Infile : "${1} \
&& verbose 3 "Outfile: "${2} \
&& cp ${1} ./${2} \
&& verbose 4 "Lookup shebang line..." \
&& shebang_line=$(head -1 ${1}) \
&& verbose 3 "Removing Comments." \
&& sed -Ei '/^\s*#.*|^$|^\s*;|\n/d' ${2} \
&& verbose 4 "Recreate shebang line." \
&& sed -i '1 i\'${shebang_line}'' ${2} \
&& verbose 5 "Setup..." \
&& chmod 755 ${2} \
&& verbose 3 "READY."
