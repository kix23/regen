#!/bin/sh

###
# InitVars START
mod_std_dir="templates/mod/";
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

##
# GetOpts START ModMod Module

		m) module="${OPTARG}";;

# GetOpts END ModMod Module
##

##
# Modul START
# Modul: regen
# Version: 0.001-3a
#
# Creats New Shell Script and Insert Vars
#
# Argumente:
#		$1 Modulnamen -m OptArg (Durch Komma "," getrennt)
#		$2 Outfile
#		$3 Modul Directory
#		$4 Modul Prefix
#		$5 Modul Suffix
#
# Requires: filecheck,tagfile
#
regen_write() {
	verbose 2 "Given Modules: "${1}
	verbose 5 "Outfile: "${2}
	mod_check_outfile ${2} && touch ${2}

	for modul in $(echo $1 | sed "s/,/ /g")
		do
			optarg_spec=""
			mod_file=${3-${mod_std_dir}}${4-${mod_std_prefix}}${modul}${5-${mod_std_suffix}}

			[ "${modul}" = "core" ] \
			&& verbose 3 "Copying core file..." \
			&& cat "${mod_file}" > ${2} && continue

			[ "${modul}" != "core" ] \
			&& mod_check_infile ${mod_file} \
			|| (verbose 1 "Modul: ${modul} nicht gefunden." && return 1) || exit \
			&& verbose 3 "Adding Module: "${modul} \
			&& tagfile_write ${mod_file} ${2} "${mod_start_tag}" "${mod_end_tag}" "-1" "${mod_writeline}" "-1"

			verbose 5 "${modul}: Searching Module Vars..." \
			&& tagfile_write ${mod_file} ${2} "${var_start_tag}" "${var_end_tag}" "-1" "${var_writeline}" "+1" \
			&& verbose 4 "${modul}: Adding Module Vars..." \
			|| verbose 5 "${modul}: No Vars for ${modul}"

			verbose 5 "${modul}: Searching Module Options..." \
			&& tagfile_test ${mod_file} "${opt_start_tag}" "${opt_end_tag}" \
			|| ( verbose 5 "${modul}: No Opts for ${modul}" && return 1 )  \
			&& verbose 5 "${modul}: Parsing Module Options..." \
			&& [ ! -z ${tag_start_line} ] && [ ! -z ${tag_end_line} ] \
			&& verbose 5 "${modul}: Fixed Opts..." \
			&& options_line=$(sed -n ${tag_start_line},${tag_end_line}p ${mod_file} | grep ')' | grep -v "${opt_arg_linetest}" | cut -d')' -f1 | tr -d '\t' | tr -d ' ' | tr -d '\n' )

			tagfile_test ${mod_file} "${opt_arg_linetest}" "${opt_end_tag}" \
			&& optarg_spec=$(grep "${opt_arg_linetest}" ${mod_file}) \
			&& verbose 5 "${modul}: With optarg..." \
			&& tagfile_test ${mod_file} "${opt_start_tag}" "${opt_end_tag}" \
			&& options_line=${options_line}$(sed -n ${tag_start_line},${tag_end_line}p ${mod_file} | grep ')' | grep "${opt_arg_linetest}" | cut -d')' -f1 | tr -d '\t' | tr -d ' ' | tr -d '\n' | sed "s/.\{1\}/&:/g" )

			[ ! -z "${options_line}" ] \
			&& tagfile_write ${mod_file} ${2} "${opt_start_tag}" "${opt_end_tag}" "-1" "${opt_writeline}" "-1" \
			&& verbose 4 "${modul}: Adding Optlines..." \
			&& sed -i "s/^while getopts /while getopts ${options_line}/" ${2}

			verbose 5 "${modul}: Searching Module Args" \
			&& tagfile_test ${mod_file} "${arg_start_tag}" "${arg_end_tag}" \
			&& [ "${tag_start_line}" != "-1" ] \
			&& verbose 4 "${modul}: Adding Module Args..." \
			&& tagfile_write ${mod_file} ${2} "${arg_start_tag}" "${arg_end_tag}" "-1" "${arg_writeline}" "-1" \
			|| (verbose 5 "${modul}: No Args for ${modul}")

			[ ! -z "${src_start_tag}" ] && [ ! -z "${src_end_tag}" ] \
			&& tagfile_test ${mod_file} "${src_start_tag}" "${src_end_tag}" \
			&& verbose 5 "Placing Script..." \
			&& tagfile_write ${mod_file} ${2} "${src_start_tag}" "${src_end_tag}" "-1" "${src_writeline}" "+1" ;

			verbose 3 "Setup..." \
			&& chmod 755 ${2}
		done
}

# Modul ENDE regen
##
