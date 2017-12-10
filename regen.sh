#!/bin/sh
###
# Shell Script Template
# Version: 0.000-2a
###

# Usage hint
hilfe() {
	echo "Usage: "$(basename ${0})" [-fhv] BaseFile SnippetFile Outfile";
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


# filecheck force write:
fc_force="1";


mod_std_dir="Vorlagen/mod/";
mod_std_prefix="mod_";
mod_std_suffix=".sh";
module="core";
#Regxe
var_start_tag="^# InitVars START";
var_end_tag="^# InitVars END";
var_writeline=${var_end_tag};

mod_start_tag="^# Modul START";
mod_end_tag="^# Modul END";
mod_writeline="^# Modulblock END";

opt_start_tag="^# GetOpts START";
opt_end_tag="^# GetOpts END";
opt_writeline='^\s*v) debug_lvl=$((${debug_lvl}+1));;';
opt_arg_linetest='^.*[[:alpha:]]*)\s.*=\"\${OPTARG}\";;$';

arg_start_tag="^# Args START";
arg_end_tag="^# Args END";
arg_writeline=${opt_end_tag};

src_start_tag="^# Script START";
src_end_tag="^# Script END";
src_writeline=${src_start_tag};

# InitVars END
###

###
# GetOpts START

while getopts fhv opt
	do
	 case ${opt} in
		h) hilfe && exit;;

		# filecheck force_write
		f) fc_force="1";;

		v) debug_lvl=$((${debug_lvl}+1));;
		*) hilfe && return 1;;
	 esac
	done
# Falls Argumente nach Optionen Zeiger zurücksetzen.
shift $(($OPTIND-1))

# GetOpts END
###

###
# Args START

# Args END
###

###
# Modulblock START

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

# Modul: filecheck
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
	&& verbose 1 "No infile given." && hilfe \
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
#		1 Datei kann nicht geschrieben werden oder exisitiert (überschreiben variable fc_force auf 1 setzen -> option -f )
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

# Modul: Tagfile
# Version 0.000-2a
#
# tagfile_test
#
# test if open and close tag exist in a file
# Sets the linenumbers of the tags variables in
# ${tag_start_line} and ${tag_start_line}
#
# Args:
#    $1 Infile
#    $2 Starttag
#    $3 Endtag
#
tagfile_test() {
     verbose 6 "tagfile: Testing for complete Tag: ${2} ${3}" \
     && tag_start_line=$(grep -n "${2}" ${1} | cut -d: -f1) \
     && tag_end_line=$(grep -n "${3}" ${1} | cut -d: -f1) \
     && verbose 6 "tagfile: Startline #"${tag_start_line}" Endline #"${tag_end_line} \
     && [ "${tag_start_line}" != "" ] \
     && [ "${tag_start_line}" != "-1" ] \
     && [ "${tag_end_line}" != "" ] \
     && [ "${tag_end_line}" != "-1" ] \
     && verbose 6 "Tags found." \
     && return 0 \
     || ( verbose 6 "Tags not found." && return 1 )
}
#
# tagfile_write
#
# Write tagged content of a File before or behind a tagline in destination file.
#
# Args:
#    $1 Infile
#    $2 Outfile
#    $3 Starttag
#    $4 Endtag
#    $5 Offset Start End line
#    $6 Writeline
#    $7 Schreibe Vor/Hinter (-1|+1)
#
tagfile_write() {
     tmp_outfile=$(mktemp /tmp/child_script.XXXXXX) \
     && tag_start_line=$(($(grep -n "${3}" ${1} | cut -d: -f1)-$(echo ${5}))) \
     && tag_end_line=$(($(grep -n "${4}" ${1} | cut -d: -f1)+$(echo ${5}))) \
     && [ "${tag_start_line}" != "" ] \
     && [ "${tag_start_line}" != "-1" ] \
     && [ "${tag_end_line}" != "" ] \
     && [ "${tag_end_line}" != "-1" ] \
     && tag_zeilenvorschub=$(($(grep -n "${6}" ${2} | cut -d: -f1)$(echo ${7}))) \
     && verbose 6 "tagfile: Insert Line #"${tag_zeilenvorschub} \
     && [ ${tag_zeilenvorschub} != "-1" ] \
     && head -${tag_zeilenvorschub} ${2} > ${tmp_outfile} \
     && sed -n ${tag_start_line},${tag_end_line}p ${1} >> ${tmp_outfile} \
     && tail +$((${tag_zeilenvorschub}+1)) ${2} >> ${tmp_outfile} \
     && mv ${tmp_outfile} ${2} \
     && return 0 \
     || ( rm ${tmp_outfile} && return 1 )
}

# Modul: regen
# Version: 0.001-2a
#
# Creats New Shell Script and Insert Vars
#
# Argumente:
#    $1 Basefile (Template)
#    $2 Progfile (Programm to insert in Template)
#    $3 Outfile
#
# Requires: filecheck
#
regen_write() {
	base_file=${1};
	mod_file=${2};
	outfile=${3};
	mod_check_infile ${base_file} \
	&& mod_check_infile ${base_file} && verbose 4 "Basefile: "${1} \
	&& mod_check_infile ${mod_file} && verbose 4 "Progfile: "${2} \
	&& mod_check_outfile ${outfile} && verbose 4 "Outfile : "${3} \
	&& verbose 3 "Creating core..." \
	&& cp ${base_file} ${outfile} \
	&& verbose 3 "Updating Script..." \
	&& verbose 3 "Modul: "${mod_file} \
	&& verbose 3 "Lookup Tags..."

	[ ! -z "${var_start_tag}" ] && [ ! -z "${var_end_tag}" ] \
	&& tagfile_test ${mod_file} "${var_start_tag}" "${var_end_tag}" \
	&& verbose 5 "Placing Vars..." \
	&& tagfile_write ${mod_file} ${outfile} "${var_start_tag}" "${var_end_tag}" "-1" "${var_writeline}" "-1" \

	[ ! -z "${mod_start_tag}" ] && [ ! -z "${mod_end_tag}" ] \
	&& tagfile_test ${mod_file} "${mod_start_tag}" "${mod_end_tag}" \
	&& verbose 5 "Placing Functions..." \
	&& tagfile_write ${mod_file} ${outfile} "${mod_start_tag}" "${mod_end_tag}" "-1" "${mod_writeline}" "-1"

	[ ! -z "${opt_start_tag}" ] && [ ! -z "${opt_end_tag}" ] \
	&& tagfile_test ${mod_file} "${opt_start_tag}" "${opt_end_tag}" \
	&& verbose 5 "Placing Options..." \
	&& verbose 5 "Tricky part: Adding Optlines to GetOpts..." \
	verbose 5 "Searching Module Options..." \
	&& tagfile_test ${mod_file} "${opt_start_tag}" "${opt_end_tag}" \
	|| ( verbose 5 "No Opts for ${mod_file}" && return 1 )  \
	&& verbose 5 "Parsing Module Options..." \
	&& [ ! -z ${tag_start_line} ] && [ ! -z ${tag_end_line} ] \
	&& verbose 5 "Fixed Opts..." \
	&& options_line=$(sed -n ${tag_start_line},${tag_end_line}p ${mod_file} | grep ')' | grep -v "${opt_arg_linetest}" | cut -d')' -f1 | tr -d '\t' | tr -d ' ' | tr -d '\n' ) ;

	tagfile_test ${mod_file} "${opt_arg_linetest}" "${opt_end_tag}" \
	&& optarg_spec=$(grep "${opt_arg_linetest}" ${mod_file}) \
	&& verbose 5 "With optarg..." \
	&& tagfile_test ${mod_file} "${opt_start_tag}" "${opt_end_tag}" \
	&& options_line=${options_line}$(sed -n ${tag_start_line},${tag_end_line}p ${mod_file} | grep ')' | grep "${opt_arg_linetest}" | cut -d')' -f1 | tr -d '\t' | tr -d ' ' | tr -d '\n' | sed "s/.\{1\}/&:/g" ) ;

	[ ! -z "${options_line}" ] \
	&& tagfile_write ${mod_file} ${outfile} "${opt_start_tag}" "${opt_end_tag}" "-1" "${opt_writeline}" "-1" \
	&& verbose 4 "Adding Optlines..." \
	&& sed -i "s/^while getopts /while getopts ${options_line}/" ${outfile} ;

	[ ! -z "${arg_start_tag}" ] && [ ! -z "${arg_end_tag}" ] \
	&& tagfile_test ${mod_file} "${arg_start_tag}" "${arg_end_tag}" \
	&& verbose 5 "Placing Arguments..." \
	&& tagfile_write ${mod_file} ${outfile} "${arg_start_tag}" "${arg_end_tag}" "-1" "${arg_writeline}" "-1" \

	[ ! -z "${src_start_tag}" ] && [ ! -z "${src_end_tag}" ] \
	&& tagfile_test ${mod_file} "${src_start_tag}" "${src_end_tag}" \
	&& verbose 5 "Placing Script..." \
	&& tagfile_write ${mod_file} ${outfile} "${src_start_tag}" "${src_end_tag}" "-1" "${src_writeline}" "+1" ;

	verbose 3 "Setup..." \
	&& chmod 755 ${outfile} \
	&& return 0 \
	|| return 1 ;
}
# Modulblock END
###

###
# Script START

# regen Script
#
# Arguments:
#    $1 Template
#    $2 Snippet
#    $3 Outfile
#
regen_write $1 $2 $3
# Script END
###
