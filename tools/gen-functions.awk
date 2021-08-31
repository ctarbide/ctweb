
# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.

/^#@$/ { if (showheader) { showheader = 0; print; print "" } }
{ if (showheader) print }

#@

# objective: generate some utility functions using awk,
# for awk. why? dry?

# usage: awk -f gen-functions.awk < gen-functions.awk
# usage: awk -f gen-functions.awk < gen-functions.awk | awk -f -

BEGIN{
	# length property name
	lprop = "\".length\""
}

function tabify(s) {
	gsub(/        /, "\t", s)
	return s
}

# sch - source code hooks

/^#[0-9]/ {
	num = substr($0,2,1) + 0
	sch[num, sch[num, ".len"]++] = substr($0,3)
}

function sch_get(num, \
		res, i_len) {
	res = ""
	i_len = sch[num, ".len"] + 0
	for (i=0; i<i_len; i++) {
		res = res "\n" sch[num, i]
	}
	return substr(res, 2);
}

function print_sch(num, \
		tmp) {
	tmp = sch_get(num)
	if (tmp) print tmp;
}

function sch_clean() {
	for (i=0; i<10; i++) {
		sch[i, ".len"] = 0
	}
}

# generic field list

/^#F/ {
	gfl[gfl[".len"]++] = substr($0,3)
}
function gfl_length() { return gfl[".len"] + 0 }
function gfl_get(num) { return gfl[num+0] }
function gfl_clean() { gfl[".len"] = 0; gfl[0] = "" }
function gfl_join(sep, \
		res, i_len) {
	res = gfl_get(0)
	i_len = gfl_length()
	for (i=1; i<i_len; i++) {
		res = res sep gfl_get(i)
	}
	return res
}

#

/^#</ { sym = substr($0,3); fnameprefix = sym }
/^#O/ { operation = substr($0,3) }
/^#P/ { fnameprefix = substr($0,3) }
/^#S/ { fnamesuffix = substr($0,3) }
/^#A/ { args = (args ? args ", " : "" ) substr($0,3) }
/^#K/ { keys = (keys ? keys ", " : "" ) substr($0,3) }
/^#V/ { value = substr($0,3) }
/^#I/ {
	idx0 = (idx0 ? idx0 " SUBSEP " : "" ) substr($0,3)
	idx1 = (idx1 ? idx1 ", " : "" ) substr($0,3)
}
/^#>$/ {
	if (operation == "push") {
		if (keys) { keys = keys ", " }
		if (gfl_length()) {
			print_sch(0)
			print "function push_" fnameprefix fnamesuffix "(" (args ? args ", " : "") gfl_join(", ") ", \\\n\t\tidx) {"
			print_sch(1)
			print tabify("        idx = " sym "[" keys lprop "]++")
			i_len = gfl_length()
			for (i=0; i<i_len; i++) {
				field = gfl_get(i)
				print tabify("        " sym "[" keys "idx, \"" field  "\"] = " field)
			}
		} else {
			print_sch(0)
			print "function push_" fnameprefix fnamesuffix "(" args ") {"
			print_sch(1)
			print tabify("        " sym "[" keys sym "[" keys lprop "]++] = " value)
		}
		print "}"
	} else if (operation == "length") {
		print "function length_" fnameprefix fnamesuffix "(" args ") {"
		print tabify("        return " sym "[" (keys ? keys ", " : "" ) lprop "] + 0")
		print "}"
	} else if (operation == "get") {
		print "function get_" fnameprefix fnamesuffix "(" args ") {"
		print tabify("        return " sym "[" keys "]")
		print "}"
	} else if (operation == "set") {
		print "function set_" fnameprefix fnamesuffix "(" args ") {"
		print tabify("        return " sym "[" keys "] = " value)
		print "}"
	} else if (operation == "lastindex") {
		print "function lastindex_" fnameprefix fnamesuffix "(" args ") {"
		print tabify("        return " (idx0 ? idx0 " SUBSEP " : "") "(" sym "[" (idx1 ? idx1 ", " : "" ) lprop "] + 0)")
		print "}"
	} else if (operation) {
		print "# error: unknown operation: " operation
	} else {
		print "# error: operation not defined"
	}

	print ""

	sym = ""
	operation = ""
	fnameprefix = ""
	fnamesuffix = ""
	args = ""
	keys = ""
	value = ""

	idx0 = ""
	idx1 = ""

	sch_clean()
	gfl_clean()
}

################ block

#<block
#Opush
#Aname
#Vname
#>

#<block
#Olength
#>

#<block
#Oget
#Aidx
#Kidx
#>

#<block
#Oset
#Aidx
#Aval
#Kidx
#Vval
#>

#<block
#Oget
#S__type
#Aname
#Kname
#K"type"
#>

#<block
#Oset
#Pcurrent_block
#S__type
#Atype
#Vtype
#Kcur_block
#K"type"
#>

#<block
#Oset
#Pcurrent_block
#S__source
#Asource
#Vsource
#Kcur_block
#K"source"
#>

################ block output

#<block
#Opush
#S_output
#Aname
#Avalue
#Kname
#K"output"
#Vvalue
#1	sub(/^        /, "\t", value)
#>

#<block
#Opush
#Pcurrent_block
#S_output
#Avalue
#Kcur_block
#K"output"
#Vvalue
#1	sub(/^        /, "\t", value)
#>

#<block
#Olength
#S_output
#Ablock_name
#Kblock_name
#K"output"
#>

#<block
#Olength
#Pcurrent_block
#S_output
#Kcur_block
#K"output"
#>

#<block
#Olastindex
#Pcurrent_block
#S_output
#Icur_block
#I"output"
#>

#<block
#Oget
#S_output
#Ablock_name
#Aidx
#Kblock_name
#K"output"
#Kidx
#>

################ block chunk

#<block
#Opush
#Pcurrent_block
#S_chunk
#Fname
#Ftarget
#Kcur_block
#K"chunk"
#>

#<block
#Olength
#Pcurrent_block
#S_chunk
#Kcur_block
#K"chunk"
#>

#<block
#Oget
#Pcurrent_block
#S_chunk__name
#Aidx
#Kcur_block
#K"chunk"
#Kidx
#K"name"
#>

#<block
#Oget
#Pcurrent_block
#S_chunk__target
#Aidx
#Kcur_block
#K"chunk"
#Kidx
#K"target"
#>

################ block dependency

#<block
#Opush
#Pcurrent_block
#S_dependency
#Aname
#Vname
#Kcur_block
#K"dependency"
#>

#<block
#Olength
#S_dependency
#Ablock_name
#Kblock_name
#K"dependency"
#>

#<block
#Oget
#S_dependency
#Ablock_name
#Aidx
#Kblock_name
#K"dependency"
#Kidx
#>

################ block source

#<block
#Oget
#S__source
#Aname
#Kname
#K"source"
#>

################ block source-prepend

#<block
#Opush
#Pcurrent_block
#S_sourceprepend
#Asource
#Vsource
#Kcur_block
#K"source-prepend"
#>

#<block
#Olength
#Pcurrent_block
#S_sourceprepend
#Kcur_block
#K"source-prepend"
#>

#<block
#Oget
#Pcurrent_block
#S_sourceprepend
#Aidx
#Kcur_block
#K"source-prepend"
#Kidx
#>

################ chunk

#<chunk
#Opush
#Fname
#Ftarget
#>

#<chunk
#Olength
#>

#<chunk
#Oget
#S__target
#Aidx
#Kidx
#K"target"
#>

################ deferred

#<deferred
#Opush
#Avarname
#Vvarname
#>

#<deferred
#Olength
#>

#<deferred
#Oget
#Aidx
#Kidx
#>

#<deferred
#Olastindex
#>
