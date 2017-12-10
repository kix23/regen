#!/bin/sh

###
# InitVars START

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

#opt_arg_linetest='^.*[[:alpha:]]*)\s[[:alpha:]]*=\"\${OPTARG}\";;$';

# InitVars END
###

##
# Modul START
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
# Modul ENDE regen
##
