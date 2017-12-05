#!/bin/sh

###
# InitVars START

# tag regxe
var_start_tag="^# InitVars START$";
var_end_tag="^# InitVars END$";

# InitVars END
###

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
