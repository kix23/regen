#!/bin/sh
###
# Shell Script Template
# Version: 0.000-2a
###

# Usage hint
hilfe() {
	echo "Usage: "$(basename ${0})" [-hv] ";
	return 0;
}

###
# InitVars START

# debug_lvl legt die Gesprächigkeit der Bildschirmausgabe fest
# Normal: 2
debug_lvl="2"
# log_lvl legt die Gesprächigkeit der in der Logdatei fest.
# Um Datei logging auschzuschalten - log lvl unter niedrigsten verbose Aufruf lassen.
log_lvl="0"
log_file="./script.log"

# InitVars END
###

###
# GetOpts START

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

# GetOpts END
###

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
# Verbose Module END
##
