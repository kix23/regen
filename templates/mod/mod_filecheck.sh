#!/bin/sh

###
# InitVars START

# filecheck force write:
fc_force="1";

# InitVars END
###

###
# GetOpts START

		# filecheck force_write
		f) fc_force="1";;

# GetOpts END
###

###
# Modul START
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

# Modul ENDE Filecheck
##
