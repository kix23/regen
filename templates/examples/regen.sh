#!/bin/sh
###
# InitVars START

# InitVars END
###
###
# Script START
# regen Script
# Version: 0.002-1a
#
# Arguments:
#    $1 Module -m OptArg seperated by comma ,
#    $2 Script
#    $3 Outfile
#
verbose 1 "Module: ${module} Script: $1 Outfile: ${2}"
regen_write "${module}" ${2}
regen_write "templates/examples/"$(basename "${1}") ${2} "" "" ".sh"
# Script END
###
