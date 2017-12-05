#!/bin/sh
###
# Shell Script Template
# Version: 0.000-2a
###

# Usage hint
hilfe() {
	echo "Usage: "$(basename ${0})" [-hv] Template Programm Outfile";
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

# tag regxe
var_start_tag="^# InitVars START$";
var_end_tag="^# InitVars END$";

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

###
# regen Script
# Version: 0.001-1a
#
# Creats New Shell Script and Insert Vars
#
# Argumente:
#    $1 Basefile (Template)
#    $2 Progfile (Programm to insert in Template)
#    $3 Outfile
#
regen_write() {
               base_file=${1};
			mod_file=${2};
               outfile=${3};
			[ -r ${1} ] \
			|| (verbose 5 "No Readable Base file found." && return 1) || exit \
               && verbose 4 "Basefile: "${1} \
			&& [ -r ${2} ] \
			|| (verbose 5 "No Readable Programm file found." && return 1) || exit \
               && verbose 4 "Progfile: "${2} \
               && verbose 4 "Outfile : "${3} \
			&& [ ! -z "${var_start_tag}" ] && [ ! -z "${var_end_tag}" ] \
               && verbose 3 "Lookup Tags..." \
               && tag_start_line=$(($(grep -n "${var_start_tag}" ${mod_file} | cut -d: -f1)+1)) \
               && tag_end_line=$(($(grep -n "${var_end_tag}" ${mod_file} | cut -d: -f1)-1)) \
               && [ "${tag_start_line}" != "" ] && [ "${tag_start_line}" != "-1" ] \
               && [ "${tag_end_line}" != "" ] && [ "${tag_end_line}" != "-1" ] \
               && tag_zeilenvorschub=$(($(grep -n "${var_end_tag}" ${base_file} | cut -d: -f1)-1)) \
               && verbose 3 "Updating Script..." \
               && head -${tag_zeilenvorschub} ${base_file} > ${outfile} \
               && sed -n ${tag_start_line},${tag_end_line}p ${mod_file} >> ${outfile} \
               && tail +$((${tag_zeilenvorschub}+1)) ${base_file} >> ${outfile} \
               && tail +$((${tag_end_line}+3)) ${mod_file} >> ${outfile} \
               && return 0 \
               || return 1
}

regen_write $1 $2 $3
