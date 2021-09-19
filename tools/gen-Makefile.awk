# this file was generated from functions.awk and
# gen-Makefile.nw, see actions for more information

# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.

# objective: generate portable Makefiles from a simple
# description language

BEGIN{
	genbymsg = ENVIRON["GENERATED_BY_MESSAGE"]
	vpath = ENVIRON["VPATH"]
	subdir = ENVIRON["SUBDIR"]
	top = ENVIRON["TOP"]
	objext = ENVIRON["OBJEXT"]
	exesuffix = ENVIRON["EXESUFFIX"]
	if (!objext) { objext = "o" }
	if (!exesuffix) { exesuffix = "" }
	maxlinelen = 72
	type_error = "!error"
}

################ beginning of functions.awk

################ [block]

function push_block(name) {
	block[block[".length"]++] = name
}
function length_block() {
	return block[".length"] + 0
}
function get_block(idx) {
	return block[idx]
}
function set_block(idx, val) {
	return block[idx] = val
}

################ block type

function get_block__type(name) {
	return block[name, "type"]
}
function get_current_block__type() {
	return block[cur_block, "type"]
}
function set_current_block__type(type) {
	return block[cur_block, "type"] = type
}

################ block [output]

function push_block_output(name, value) {
	sub(/^        /, "\t", value)
	block[name, "output", block[name, "output", ".length"]++] = value
}
function push_current_block_output(value) {
	sub(/^        /, "\t", value)
	block[cur_block, "output", block[cur_block, "output", ".length"]++] = value
}
function length_block_output(block_name) {
	return block[block_name, "output", ".length"] + 0
}
function length_current_block_output() {
	return block[cur_block, "output", ".length"] + 0
}
function lastindex_current_block_output() {
	return cur_block SUBSEP "output" SUBSEP (block[cur_block, "output", ".length"] + 0)
}
function get_block_output(block_name, idx) {
	return block[block_name, "output", idx]
}

################ block [chunk]

function push_current_block_chunk(name, target, \
		idx) {
	idx = block[cur_block, "chunk", ".length"]++
	block[cur_block, "chunk", idx, "name"] = name
	block[cur_block, "chunk", idx, "target"] = target
}
function length_current_block_chunk() {
	return block[cur_block, "chunk", ".length"] + 0
}

################ block [chunk] name

function get_current_block_chunk__name(idx) {
	return block[cur_block, "chunk", idx, "name"]
}

################ block [chunk] target

function get_current_block_chunk__target(idx) {
	return block[cur_block, "chunk", idx, "target"]
}

################ block target-option

function set_current_block_targetoption(target, option, value) {
	return block[cur_block, "target-option", target, option] = value
}
function get_current_block_targetoption(target, option) {
	return block[cur_block, "target-option", target, option]
}

################ block [dependency]

function push_current_block_dependency(name) {
	block[cur_block, "dependency", block[cur_block, "dependency", ".length"]++] = name
}
function length_block_dependency(block_name) {
	return block[block_name, "dependency", ".length"] + 0
}
function get_block_dependency(block_name, idx) {
	return block[block_name, "dependency", idx]
}

################ block [source]

function push_current_block_source(source) {
	block[cur_block, "source", block[cur_block, "source", ".length"]++] = source
}
function length_block_source(block_name) {
	return block[block_name, "source", ".length"] + 0
}
function get_block_source(block_name, idx) {
	return block[block_name, "source", idx]
}

################ [chunk]

function push_chunk(name, target, \
		idx) {
	idx = chunk[".length"]++
	chunk[idx, "name"] = name
	chunk[idx, "target"] = target
}
function length_chunk() {
	return chunk[".length"] + 0
}
function get_chunk__target(idx) {
	return chunk[idx, "target"]
}

################ [gl0]

function push_gl0(item) {
	gl0[gl0[".length"]++] = item
}
function length_gl0() {
	return gl0[".length"] + 0
}
function get_gl0(idx) {
	return gl0[idx]
}
function lastindex_gl0() {
	return (gl0[".length"] + 0)
}
function clear_gl0() {
	return gl0[".length"] = 0
}

################ end of functions.awk

function set_var_from_env_template(var, def, \
		env) {
	env = ENVIRON[var]
	return var "=" (env ? env : def)
}

function join_block_names_by_type(curlinelen, type, \
		res, i, i_len, item, itemlen) {
	res = ""
	i_len = length_block()
	for (i=0; i<i_len; i++) {
		item = get_block(i)
		if (get_block__type(item) != type) {
			continue
		}
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n    " item
			curlinelen = 4 + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}

function join_c_programs(curlinelen) {
	return join_block_names_by_type(curlinelen, "c-program")
}

function prefix_c_programs(prefix) {
	return prefix join_c_programs(length(prefix))
}

function join_nofake_chunks(curlinelen, \
		res, i, i_len, item, itemlen) {
	res = ""
	i_len = length_chunk()
	for (i=0; i<i_len; i++) {
		item = get_chunk__target(i)
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n    " item
			curlinelen = 4 + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}

function prefix_nofake_chunks(prefix) {
	return prefix join_nofake_chunks(length(prefix))
}
function join_c_objects(block_name, curlinelen, new_line_prefix, \
		res, i, i_len, item, itemlen, type) {
	res = ""
	if (!new_line_prefix) {
		new_line_prefix = "    "
	}
	new_line_prefix_len = length(new_line_prefix)
	i_len = length_block_dependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type != "c-object") {
			continue
		}
		item = item "." objext
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n" new_line_prefix item
			curlinelen = new_line_prefix_len + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}
function join_sources(block_name, curlinelen, new_line_prefix, \
		res, i, i_len, item, itemlen) {
	res = ""
	if (!new_line_prefix) {
		new_line_prefix = "    "
	}
	new_line_prefix_len = length(new_line_prefix)
	i_len = length_block_source(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_source(block_name, i)
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n" new_line_prefix item
			curlinelen = new_line_prefix_len + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}
function join_gl0(curlinelen, new_line_prefix, \
		res, i, i_len, item, itemlen) {
	res = ""
	if (!new_line_prefix) {
		new_line_prefix = "    "
	}
	new_line_prefix_len = length(new_line_prefix)
	i_len = length_gl0()
	for (i=0; i<i_len; i++) {
		item = get_gl0(i)
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n" new_line_prefix item
			curlinelen = new_line_prefix_len + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}
function prefix_gl0(prefix, new_line_prefix) {
	return prefix join_gl0(length(prefix), new_line_prefix)
}
function how_many_primary_dependencies(block_name, \
		res, i, i_len, item) {
	res = 0
	i_len = length_block_dependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type ~ "^(c-object)$") {
			continue
		} else if (type ~ "^(nofake)$") {
			# it is common for a nofake chunk target
			# match a primary dependency, just proceed
		} else if (!type) {
			# just a plain primary dependency
		} else {
			print "# error: exhaustion: " FILENAME ":" FNR ": type \"" type "\" (filtering out non-primary dependencies)"
			continue
		}
		res++
	}
	return res;
}
function join_primary_dependencies(block_name, curlinelen, uses_vpath, new_line_prefix, \
		res, i, i_len, item, itemlen, type) {
	res = ""
	if (!new_line_prefix) {
		new_line_prefix = "    "
	}
	new_line_prefix_len = length(new_line_prefix)
	i_len = length_block_dependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type ~ "^(c-object)$") {
			continue
		} else if (type ~ "^(nofake)$") {
			# it is common for a nofake chunk target
			# match a primary dependency, just proceed
		} else if (!type) {
			# just a plain primary dependency
		} else {
			print "# error: exhaustion: " FILENAME ":" FNR ": type \"" type "\" (filtering out non-primary dependencies)"
			continue
		}
		if (!type && !uses_vpath) {
			# just a plain primary dependency that lives
			# in vpath
			item = "'$(SRC_PREFIX)" item "'"
		}
		itemlen = length(item)
		curlinelen += 1 + itemlen
		# + 2 to account for the possibility of " \\"
		if ((curlinelen + 2) > maxlinelen) {
			res = res " \\\n" new_line_prefix item
			curlinelen = new_line_prefix_len + itemlen
		} else {
			res = res " " item
		}
	}
	return res
}
function prefix_primary_dependencies(prefix, block_name, uses_vpath, new_line_prefix) {
	return prefix join_primary_dependencies(block_name, length(prefix), uses_vpath, new_line_prefix)
}

function prefix_c_objects(prefix, block_name, new_line_prefix) {
	return prefix join_c_objects(block_name, length(prefix), new_line_prefix)
}

function prefix_sources(prefix, block_name, new_line_prefix) {
	return prefix join_sources(block_name, length(prefix), new_line_prefix)
}

/^=[a-zA-Z][a-zA-Z0-9\-_.]*$/ {
	nerrors = 0
	cur_block = substr($0, 2)
	push_block(cur_block)
	next
}

/^,/ {
	nerrors = 0
	push_current_block_output(substr($0, 2))
	next
}

/^type[ \t]/ {
	nerrors = 0
	if (cur_block) {
		cur_type = get_block__type(cur_block)
		if (cur_type) {
			# type redefinition isn't expected
			if (cur_type != type_error) {
				# report once
				print "# error: in block \"" cur_block "\", redefining type from " cur_type " to " $2
				set_current_block__type(cur_type = type_error)
			}
		} else {
			# setting type for the first time
			set_current_block__type(cur_type = $2)
			if (cur_type == "c-object") {
				target = cur_block "." objext
				is_generated_target[target]++
			} else if (cur_type == "c-program") {
				target = cur_block exesuffix
				is_generated_target[target]++
			} else if (cur_type == "nofake") {
				# nofake can have multiple targets, see chunks
			} else if (cur_type == "internal-vars") {
				# internal-vars has no target
			} else {
				print "# error: exhaustion: " FILENAME ":" FNR ": type " cur_type
			}
		}
	} else {
		print "# error: orphan type"
	}
	next
}

/^dependency[ \t]/ {
	nerrors = 0
	if (cur_block) {
		if (cur_type ~ "^(c-program|c-object)$") {
			push_current_block_dependency($2)
		} else if (cur_type != type_error) {
			print "# error: exhaustion: " FILENAME ":" FNR ": type: " cur_type
		}
	} else {
		print "# error: orphan dependency"
	}
	next
}

/^source[ \t]/ {
	nerrors = 0
	if (cur_block) {
		if (cur_type ~ "^(nofake|c-program|c-object)$") {
			push_current_block_source($2)
		} else if (cur_type != type_error) {
			print "# error: exhaustion: " FILENAME ":" FNR ": type: " cur_type
		}
	} else {
		print "# error: orphan source"
	}
	next
}

/^chunk[ \t]/ {
	nerrors = 0
	if (cur_block) {
		if (cur_type == "nofake") {
			name = $2    # name inside noweb file
			target = $3  # output filename of this chunk
			if (!target) {
				if (name ~ "^[a-zA-Z0-9_]") {
					target = name
				} else {
					print "# error: cannot determine an appropriate target filename from chunk name \"" name "\""
				}
			}
			if (target) {
				if (map_chunk_target_to_block[target]) {
					print "# error: chunk target already defined: " target \
						" in block " map_chunk_target_to_block[target]
				} else {
					is_generated_target[target]++
					push_current_block_chunk(name, target)
					push_chunk(name, target)
					map_chunk_target_to_block[target] = cur_block
				}
			}
		} else if (cur_type != type_error) {
			print "# error: exhaustion: " FILENAME ":" FNR ": type: " cur_type
		}
	} else {
		print "# error: orphan chunk"
	}
	next
}

/^target-option[ \t]/ {
	nerrors = 0
	if (cur_block) {
		if (cur_type == "nofake") {
			target = $2
			if (target) {
				option = $3
				if (option) {
					value = $4
					if (length(value)) {
						set_current_block_targetoption(target, option, value)
					} else {
						print "# error: value is empty for target-option"
					}
				} else {
					print "# error: option is not defined for target-option"
				}
			} else {
				print "# error: target is not defined for target-option"
			}
		} else if (cur_type != type_error) {
			print "# error: exhaustion: " FILENAME ":" FNR ": type: " cur_type
		}
	} else {
		print "# error: orphan chunk"
	}
	next
}

/^[ \t]*#/ {
	nerrors = 0
	# print "# comment: " $0
	next
}

/^$/ {
	nerrors = 0
	next
}

/^@$/ {
	nerrors = 0
	cur_block = 0
	cur_type = 0
	next
}

{
	if (!found) {
		print "# warn: unprocessed line: \"" $0 "\""
	} else {
		found = 0
	}
}

END{
	print "# automatically generated, please to not edit"
	if (genbymsg) {
		print "# " genbymsg
		print ""
	}

	tools_prefix = ""

	if (vpath == ".") {
		# in source build
		src = vpath
		if (top == ".") {
			# toplevel
			tools_prefix = "tools/"
		} else {
			tools_prefix = top "/tools/"
		}
	} else if (vpath ~ /\// && subdir) {
		# absolute vpath
		src = vpath "/" subdir
		print "VPATH = " src
		tools_prefix = vpath "/tools/"
		print ""
	} else if (vpath && subdir && top) {
		# relative vpath
		if (subdir == "." && top == ".") {
			# toplevel
			src = vpath
			print "VPATH = " src
			tools_prefix = vpath "/tools/"
		} else {
			src = vpath "/" top "/" subdir
			print "VPATH = " src
			tools_prefix = vpath "/" top "/tools/"
		}
		print ""
	} else {
		print "# error: cannot determine VPATH"
	}

	vars["OBJEXT"] = "OBJEXT = " objext
	vars["EXESUFFIX"] = "EXESUFFIX = " exesuffix
	vars["NOFAKE"] = "NOFAKE = " tools_prefix "nofake"
	vars["INSTALL"] = "INSTALL = " tools_prefix "install.sh"

	vars["C_PROGRAMS"] = prefix_c_programs("C_PROGRAMS =")
	vars["NOFAKE_CHUNKS"] = prefix_nofake_chunks("NOFAKE_CHUNKS =")

	if (src == ".") {
		vars["SRC_PREFIX"] = "SRC_PREFIX ="
		vars["SRC_INCLUDE"] = "SRC_INCLUDE = -I."
	} else {
		vars["SRC_PREFIX"] = "SRC_PREFIX = " src "/"
		vars["SRC_INCLUDE"] = "SRC_INCLUDE = -I. -I'" src "'"
	}

	vars["SUBDIR"] = "SUBDIR = " subdir
	vars["TOP"] = "TOP = " top

	h_len = length_block()
	for (h=0; h<h_len; h++) {
		cur_block = get_block(h)
		cur_type = get_block__type(cur_block)
		if (cur_type == type_error) {
			print "# error: block \"" cur_block "\" has previously reported errors"
			print ""
		} else {
			print "# **************** " cur_block " " (cur_type ? "(type: " cur_type ")" : "(no type)")
			if (cur_type == "c-program") {
				source_len = length_block_source(cur_block)
				if (source_len == 1) {
					source = get_block_source(cur_block, 0)
					obj = source
					if (sub(/\.c$/, "." objext, obj)) {
						if (!is_generated_target[obj]) {
							push_current_block_output(prefix_primary_dependencies(obj ": " source, cur_block, 1, "    "))
							if (is_generated_target[source]) {
								push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " '" source "'")
							} else {
								push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " '$(SRC_PREFIX)" source "'")
							}
						}
						target = cur_block exesuffix
						push_current_block_output(prefix_c_objects(target ": " obj, cur_block, "    "))
						push_current_block_output(prefix_c_objects("\t$(LD) $(LDFLAGS) -o " cur_block " $(LIBS)", cur_block, "\t    ") " " obj)
					} else {
						push_current_block_output("# error: exhaustion: c-program \"" cur_block "\" source: \"" source "\"")
					}
				} else if (source_len) {
					push_current_block_output("# error: c-program \"" cur_block "\" expects 1 source, " source_len " provided")
				} else {
					push_current_block_output("# error: c-program \"" cur_block "\" has no source")
				}
			} else if (cur_type == "nofake") {
				i_len = length_current_block_chunk()
				for (i=0; i<i_len; i++) {
					name = get_current_block_chunk__name(i)
					target = get_current_block_chunk__target(i)
					j_len = length_block_source(cur_block)
					if (!j_len) {
						print "# error: there are no sources defined to generate target \"" target "\""
						next
					}
					clear_gl0()
					for (j=0; j<j_len; j++) {
						source = get_block_source(cur_block, j)
						if (target == source) {
							print "# error: the target and the source are the same: \"" target "\""
							next
						}
						push_gl0("'$(SRC_PREFIX)" source "'")
					}
					push_current_block_output(prefix_sources(target ":", cur_block))
					push_current_block_output(prefix_gl0("\t$(NOFAKE) -R'" name "' $(NOFAKEFLAGS)", "\t    ") \
						" \\\n\t    >'.tmp." target "'")
					push_current_block_output("\t$(MV) '.tmp." target "' '" target "'")
					if (get_current_block_targetoption(target, "executable")) {
						push_current_block_output("\t$(CHMOD_0555) '" target "'")
					} else {
						push_current_block_output("\t$(CHMOD_0444) '" target "'")
					}
				}
			} else if (cur_type == "c-object") {
				source_len = length_block_source(cur_block)
				if (source_len == 1) {
					source = get_block_source(cur_block, 0)
					obj = cur_block "." objext
					target = obj
					push_current_block_output(prefix_primary_dependencies(target ": " source, cur_block, 1, "    "))
					if (is_generated_target[source]) {
						push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " '" source "'")
					} else {
						push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " '$(SRC_PREFIX)" source "'")
					}
				} else if (source_len) {
					push_current_block_output("# error: c-object \"" cur_block "\" expects 1 source, " source_len " provided")
				} else {
					push_current_block_output("# error: c-object \"" cur_block "\" has no source")
				}
			} else if (cur_type == "internal-vars") {
				push_current_block_output(set_var_from_env_template("BUILD_AWK", "nawk"))
				push_current_block_output(set_var_from_env_template("BUILD_MAKEFILE", "Makefile"))
				push_current_block_output(vars["OBJEXT"])
				push_current_block_output(vars["EXESUFFIX"])
				push_current_block_output(vars["SRC_PREFIX"])
				push_current_block_output(vars["SRC_INCLUDE"])
				push_current_block_output(vars["SUBDIR"])
				push_current_block_output(vars["TOP"])
				push_current_block_output(vars["NOFAKE"])
				push_current_block_output(vars["INSTALL"])
				push_current_block_output(vars["C_PROGRAMS"])
				push_current_block_output(vars["NOFAKE_SOURCES"])
				push_current_block_output(vars["NOFAKE_CHUNKS"])
			} else if (cur_type) {
				if (cur_type != type_error) {
					print "# error: exhaustion: " FILENAME ":" FNR ": type: " cur_type
				}
			} else if (!length_current_block_output()) {
				push_current_block_output("# error: type not defined in a block without output")
			}
			j_len = length_current_block_output()
			for (j=0; j<j_len; j++) {
				print get_block_output(cur_block, j)
			}
			print ""
		}
	}

	if (length_block_output("")) {
		print "# error: " length_block_output("") " unknown lines (empty)"
		print ""
	}

	if (length_block_output(0)) {
		print "# error: " length_block_output(0) " unknown lines (0)"
		print ""
	}
}
