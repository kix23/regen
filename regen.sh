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

fc_force="1";

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
# Modul START Filecheck
# Version: 0.000-1b

##
# Input File Test
# Datei existiert und ist lesbar
#
# Argumente:
#		$1 Infile
# Rückgabe:
#		0 Infile existiert und ist lesbar.
#		1 existiert nicht oder ist nicht lesbar.
#
mod_check_infile() {
	# Check if infile is given
	[ -z ${1} ] \
	&& verbose 1 "No infile given." \
	&& return 1 ;
	# Check if infile exists,
	[ ! -z ${1} ] \
	&& verbose 6 "Infile: "${1} \
	&& [ ! -f ${1} ] \
	&& verbose 6 "Infile not found." \
	&& return 1 ;
	# Check if infile is readable
	[ -f ${1} ] && [ -r ${1} ] \
	&& verbose 6 "Infile found and readable." \
	&& return 0 \
	|| ( [ -f ${1} ] && [ ! -r ${1} ] \
	&& verbose 1 "Infile found but not readable." \
	&& return 1 ) ;
}

##
# Output File Test
# Datei existiert und ist Beschreibbar
# Falls Datei nicht existiert -
# Zielverzeichnis auf Beschreibbarkeit prüfen.
#
# Argumente:
#		$1 outfile
#
# Rückgabe:
#		0 Datei kann geschrieben werden
#		1 irgendein Fehler
#
mod_check_outfile(){
	# Check if outfile is given
	[ -z ${1} ] \
	&& ( verbose 1 "No outfile given."  \
	&& return 1 || exit );
	[ ! -z ${1} ] \
	&& verbose 6 "Outfile: "${1};

	# Check if outfile is a Directory
	[ -d ${1} ] \
	&& ( verbose 1 "Outfile is a Directory. Meh want a file." \
	&& return 1 || exit );

	# Check if outfile does not exist but can be created in given Outfile Directory
	[ ! -f ${1} ]  \
	&& verbose 6 "Outfile does not exist." \
	&& [ ! -d $(dirname "${1}") ] \
	&& verbose 1 "Output Directory not found: "$(dirname "${1}") \
	&& return 1 \
	|| [ -w $(dirname "${1}") ] \
	&& verbose 6 "Output Direcotry writable: "$(dirname "${1}") \
	&& return 0 \
	|| ( verbose 1 "Output Direcotry not writable: "$(dirname "${1}") \
	&& return 1 ) || exit ;

	# Check if outfile exists and is writable:
	# Do not overwrite if not forced.
	[ -w ${1} ] && [ ! -d ${1} ] \
	&& verbose 6 "Outfile exists and is writable." \
	&& [ "${fc_force}" = "1" ] \
	&& verbose 6 "Replacing existing file." \
	&& return 0 \
	|| [ -w ${1} ] && [ "${fc_force}" != "1" ] \
	&& verbose 1 "Overwrite existing file? Use -f" \
	&& return 1;

	# Maybe outfile exists but isn't writable
	[ -f ${1} ] && [ ! -w ${1} ] && [ ! -d ${1} ] \
	&& ( verbose 1 "Outfile exists but is not writable." && return 1 || exit );
}

# Modul ENDE Filecheck
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
	mod_check_infile ${base_file} \
	&& mod_check_infile ${base_file} && verbose 4 "Basefile: "${1} \
	&& mod_check_infile ${mod_file} && verbose 4 "Progfile: "${2} \
	&& mod_check_outfile ${outfile} && verbose 4 "Outfile : "${3} \
	&& [ ! -z "${var_start_tag}" ] && [ ! -z "${var_end_tag}" ] \
	&& verbose 3 "Lookup Tags..." \
	&& tag_start_line=$(($(grep -n "${var_start_tag}" ${mod_file} | cut -d: -f1)+1)) \
	&& tag_end_line=$(($(grep -n "${var_end_tag}" ${mod_file} | cut -d: -f1)-1)) \
	&& [ "${tag_start_line}" != "" ] && [ "${tag_start_line}" != "-1" ] \
	&& [ "${tag_end_line}" != "" ] && [ "${tag_end_line}" != "-1" ] \
	&& tag_zeilenvorschub=$(($(grep -n "${var_end_tag}" ${base_file} | cut -d: -f1)-1)) \
	&& verbose 3 "Updating Script..." \
	&& verbose 5 "Writing before tag..." \
	&& head -${tag_zeilenvorschub} ${base_file} > ${outfile} \
	&& verbose 5 "Writing Insertion..." \
	&& sed -n ${tag_start_line},${tag_end_line}p ${mod_file} >> ${outfile} \
	&& verbose 5 "Completing Core..." \
	&& tail +$((${tag_zeilenvorschub}+1)) ${base_file} >> ${outfile} \
	&& verbose 5 "Adding Programm..." \
	&& tail +$((${tag_end_line}+3)) ${mod_file} >> ${outfile} \
	&& verbose 3 "Setup..." \
	&& chmod 755 ${outfile} \
	&& return 0 \
	|| return 1
}

regen_write $1 $2 $3
