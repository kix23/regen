#!/bin/sh
##
# Modul START
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

# Modul ENDE Tagfile
##
