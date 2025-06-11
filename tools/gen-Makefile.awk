# This file was generated from gen-Makefile.nw.
# Please do not edit.

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
	toolsdirprefix = ENVIRON["TOOLSDIRPREFIX"]
	if (!vpath) vpath = "."
	if (!top) top = "."
	if (!objext) objext = "o"
	maxlinelen = 72
	nerrors = 0
	reading_file = 1
}
END{
	reading_file = 0
	if (nerrors) {
		exit 1
	}
}


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

function get_block__type(name) {
	return block[name, "type"]
}

function get_current_block__type() {
	return block[cur_block, "type"]
}

function set_current_block__type(type) {
	return block[cur_block, "type"] = type
}

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

function get_block_output(block_name, idx) {
	return block[block_name, "output", idx]
}

function lastindex_current_block_output() {
	return cur_block SUBSEP "output" SUBSEP (block[cur_block, "output", ".length"] + 0)
}

function push_current_block_chunk(name, target, \
		idx) {
	idx = block[cur_block, "chunk", ".length"]++
	block[cur_block, "chunk", idx, "name"] = name
	block[cur_block, "chunk", idx, "target"] = target
}

function length_block_chunk(block_name) {
	return block[block_name, "chunk", ".length"] + 0
}

function get_current_block_chunk__name(idx) {
	return block[cur_block, "chunk", idx, "name"]
}

function get_current_block_chunk__target(idx) {
	return block[cur_block, "chunk", idx, "target"]
}

function set_current_block_targetoption(target, option, value) {
	return block[cur_block, "target-option", target, option] = value
}

function get_current_block_targetoption(target, option) {
	return block[cur_block, "target-option", target, option]
}

function push_current_block_dependency(name) {
	block[cur_block, "dependency", block[cur_block, "dependency", ".length"]++] = name
}

function length_block_dependency(block_name) {
	return block[block_name, "dependency", ".length"] + 0
}

function get_block_dependency(block_name, idx) {
	return block[block_name, "dependency", idx]
}

function push_current_block_source(source) {
	block[cur_block, "source", block[cur_block, "source", ".length"]++] = source
}

function length_block_source(block_name) {
	return block[block_name, "source", ".length"] + 0
}

function get_block_source(block_name, idx) {
	return block[block_name, "source", idx]
}

function push_chunk(name, target, \
		idx) {
	idx = chunk[".length"]++
	chunk[idx, "name"] = name
	chunk[idx, "target"] = target
}

function length_chunk() {
	return chunk[".length"] + 0
}

# target is unique among blocks and chunks

function get_chunk__target(idx) {
	return chunk[idx, "target"]
}
function push_deferred(varname) {
	deferred[deferred[".length"]++] = varname
}

function length_deferred() {
	return deferred[".length"] + 0
}

function get_deferred(idx) {
	return deferred[idx]
}

function lastindex_deferred() {
	return (deferred[".length"] + 0)
}

# generic list 0, for local, temporary uses

function push_gl0(item) {
	gl0[gl0[".length"]++] = item
}

function length_gl0() {
	return gl0[".length"] + 0
}

function get_gl0(idx) {
	return gl0[idx]
}

function clear_gl0() {
	return gl0[".length"] = 0
}

function join_ARGV(sep, \
		i, i_len, res) {
	if (ARGC < 2) return ""
	res = ARGV[1]
	i_len = ARGC
	for (i=2; i<i_len; i++) res = res sep ARGV[i]
	return res
}
function show_error(errmsg) {
	nerrors++
	print("# ERROR: " errmsg)
}
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
		if (type ~ /^c-object$/) {
			continue
		} else if (type ~ /^nofake(-awk)?$/) {
			# it is common for a nofake chunk target
			# match a primary dependency, just proceed
		} else if (!type) {
			if (generated_from_type[item] ~ /^c-object$/) {
				continue
			}
			# just a plain primary dependency
		} else {
			show_error("exhaustion-1: " FILENAME ":" FNR ": type \"" type "\" (filtering out non-primary dependencies)")
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
		if (type ~ /^c-object$/) {
			continue
		} else if (type ~ /^nofake(-awk)?$/) {
			# it is common for a nofake chunk target
			# match a primary dependency, just proceed
		} else if (!type) {
			if (generated_from_type[item] ~ /^c-object$/) {
				continue
			}
			# just a plain primary dependency
		} else {
			show_error("exhaustion-1: " FILENAME ":" FNR ": type \"" type "\" (filtering out non-primary dependencies)")
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
function join_all_nofake_sources(curlinelen, uses_vpath, new_line_prefix, \
		block_name, res, i, i_len, j, j_len, item, itemlen, type, visited) {
	res = ""
	if (!new_line_prefix) {
		new_line_prefix = "    "
	}
	new_line_prefix_len = length(new_line_prefix)
	j_len = length_block()
	for (j=0; j<j_len; j++) {
		block_name = get_block(j);
		type = get_block__type(block_name)
		if (type !~ /^nofake(-awk)?$/) {
			continue
		}
		i_len = length_block_source(block_name)
		for (i=0; i<i_len; i++) {
			item = get_block_source(block_name, i)
			if (visited[item]++) {
				continue
			}
			type = get_block__type(item)
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
	}
	return res
}
function prefix_all_nofake_sources(prefix, uses_vpath, new_line_prefix) {
	return prefix join_all_nofake_sources(length(prefix), uses_vpath, new_line_prefix)
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
function prefix_sources(prefix, block_name, new_line_prefix) {
	return prefix join_sources(block_name, length(prefix), new_line_prefix)
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
			if (generated_from_type[item] != "c-object") {
				continue
			}
		}
		sub("\\." objext "$", "", item)
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
function prefix_c_objects(prefix, block_name, new_line_prefix) {
	return prefix join_c_objects(block_name, length(prefix), new_line_prefix)
}
function mark_as_generated_target(target) {
	generated_targets[target]++
	if (cur_block) {
		generated_from_block[target] = cur_block
	} else {
		show_error("Generated target \"" target "\" is not associated with a block.")
	}
	if (cur_type) {
		generated_from_type[target] = cur_type
	} else {
		show_error("Generated target \"" target "\" is not associated with a block type.")
	}
}
function is_generated_target(item) {
	return generated_targets[item]
}
function push_current_block_output_deferred(s) {
	push_deferred(lastindex_current_block_output())
	push_current_block_output(s)
}

/^=[a-zA-Z][a-zA-Z0-9\-_.]*$/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	cur_block = substr($0, 2)
	push_block(cur_block)
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^,/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	push_current_block_output(substr($0, 2))
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^type[ \t]/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	if (cur_block) {
		cur_type = get_block__type(cur_block)
		if (cur_type) {
			# type redefinition isn't expected
			show_error("in block \"" cur_block "\", redefining type from " cur_type " to " $2)
		} else {
			# setting type for the first time
			set_current_block__type(cur_type = $2)
		}
	} else {
		show_error("orphan type")
	}
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^dependency[ \t]/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	if (cur_block) {
		if (cur_type ~ /^(c-program|c-object)$/) {
			push_current_block_dependency($2)
		} else {
			show_error("exhaustion-3: " FILENAME ":" FNR ": type: " cur_type)
		}
	} else {
		show_error("orphan dependency")
	}
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^source[ \t]/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	if (cur_block) {
		if (cur_type ~ /^(nofake(-awk)?|c-program|c-object)$/) {
			push_current_block_source($2)
		} else {
			show_error("exhaustion-4: " FILENAME ":" FNR ": type: " cur_type)
		}
	} else {
		show_error("orphan source")
	}
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^chunk[ \t]/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	if (cur_block) {
		if (cur_type ~ /^nofake(-awk)?$/) {
			name = $2    # name inside noweb file
			target = $3  # output filename of this chunk
			if (!target) {
				if (name ~ "^[a-zA-Z0-9_]") {
					target = name
				} else {
					show_error("Cannot determine an appropriate target filename from chunk name \"" name "\".")
				}
			}
			if (target) {
				if (map_chunk_target_to_block[target]) {
					show_error("chunk target already defined: " target \
						" in block " map_chunk_target_to_block[target])
				} else {
					push_current_block_chunk(name, target)
					push_chunk(name, target)
					map_chunk_target_to_block[target] = cur_block
				}
			}
		} else {
			show_error("exhaustion-5: " FILENAME ":" FNR ": type: " cur_type)
		}
	} else {
		show_error("orphan chunk")
	}
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^target-option[ \t]/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	if (cur_block) {
		if (cur_type ~ /^nofake(-awk)?$/) {
			target = $2
			if (target) {
				option = $3
				if (option) {
					value = $4
					if (length(value)) {
						set_current_block_targetoption(target, option, value)
					} else {
						show_error("value is empty for target-option")
					}
				} else {
					show_error("option is not defined for target-option")
				}
			} else {
				show_error("target is not defined for target-option")
			}
		} else {
			show_error("exhaustion-6: " FILENAME ":" FNR ": type: " cur_type)
		}
	} else {
		show_error("orphan chunk")
	}
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^[ \t]*#/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	# print "# comment: " $0
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^$/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	# no-op
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

/^@$/ {
	if (nerrors) {
		print "\nERROR: preamble: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
	cur_block = 0
	cur_type = 0
	if (nerrors) {
		print "\nERROR: epilog: Exiting with failure due to the presence of errors.\n"
		exit 1
	} else next
}

END{
	print "# automatically generated, please to not edit"
	if (genbymsg) {
		print "# " genbymsg
		print "# input files: " join_ARGV(", ")
		print ""
	}

	top_src_dir = ""
	tools_prefix = ""

	if (vpath == ".") {
		# in source build
		src = vpath
		if (top == ".") {
			# toplevel
			top_src_dir = "."
			tools_prefix = "./" toolsdirprefix
		} else {
			top_src_dir = top
			tools_prefix = top "/" toolsdirprefix
		}
		print "# inside source tree build, VPATH not required"
	} else if (vpath ~ /\// && subdir) {
		# absolute vpath
		src = vpath "/" subdir
		print "VPATH = " src
		top_src_dir = vpath
		tools_prefix = vpath "/" toolsdirprefix
	} else if (vpath && subdir && top) {
		# relative vpath
		if (subdir == "." && top == ".") {
			# toplevel
			src = vpath
			print "VPATH = " src
			top_src_dir = vpath
			tools_prefix = vpath "/" toolsdirprefix
		} else {
			src = vpath "/" top "/" subdir
			print "VPATH = " src
			top_src_dir = vpath "/" top
			tools_prefix = vpath "/" top "/" toolsdirprefix
		}
	} else {
		show_error("Cannot determine VPATH.")
	}

	print "VPATH_FROM_TOP = " vpath
	print ""

	if (nerrors) {
		print "\nERROR: Exiting with failure due to the presence of errors.\n"
		exit 1
	}

	vars["OBJEXT"] = "OBJEXT = " objext
	vars["EXESUFFIX"] = "EXESUFFIX = " exesuffix
	vars["NOFAKE"] = "NOFAKE = " tools_prefix "nofake"
	vars["NOFAKE_SH"] = "NOFAKE_SH = " tools_prefix "nofake.sh"
	vars["INSTALL"] = "INSTALL = " tools_prefix "install.sh"

	vars["C_PROGRAMS"] = prefix_c_programs("C_PROGRAMS =")
	vars["NOFAKE_SOURCES"] = prefix_all_nofake_sources("NOFAKE_SOURCES =", 1)
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
	vars["TOP_SRC_DIR"] = "TOP_SRC_DIR = " top_src_dir

	# process all blocks
	h_len = length_block()
	for (h=0; h<h_len; h++) {
		cur_block = get_block(h)
		cur_type = get_block__type(cur_block)
		if (cur_type == "c-program") {
			source_len = length_block_source(cur_block)
			if (source_len == 1) {
				source = get_block_source(cur_block, 0)
				obj = source
				if (sub(/\.c$/, "." objext, obj)) {
					if (!is_generated_target(obj)) {
						mark_as_generated_target(obj)
						push_current_block_output(prefix_primary_dependencies(obj ": " source, cur_block, 1, "    "))
						if (!is_generated_target(source)) {
							source = "$(SRC_PREFIX)" source
						}
						push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " '" source "'")
					}
					target = cur_block exesuffix
					mark_as_generated_target(target)
					push_current_block_output(prefix_c_objects(target ": " obj, cur_block, "    "))
					push_current_block_output(prefix_c_objects("\t$(LD) $(LDFLAGS) -o " cur_block " $(LIBS)", cur_block, "\t    ") " " obj)
				} else {
					show_error("exhaustion-8: c-program \"" cur_block "\" source: \"" source "\"")
				}
			} else if (source_len) {
				show_error("c-program \"" cur_block "\" expects 1 source, " source_len " provided")
			} else {
				show_error("c-program \"" cur_block "\" has no source")
			}
		} else if (cur_type == "nofake") {
			i_len = length_block_source(cur_block)
			if (i_len) {
				for (idx in known_sources) delete known_sources[idx]
				clear_gl0()
				for (i=0; i<i_len; i++) {
					item = get_block_source(cur_block, i)
					known_sources[item]++
					type = get_block__type(item)
					if (!type) {
						# just a plain primary dependency that lives
						# in vpath
						item = "'$(SRC_PREFIX)" item "'"
					}
					push_gl0(item)
				}
				i_len = length_block_chunk(cur_block)
				if (!i_len) {
					show_error("There are no chunks defined (thus no targets).")
				}
				for (i=0; i<i_len && nerrors == 0; i++) {
					name = get_current_block_chunk__name(i)
					target = get_current_block_chunk__target(i)
					if (known_sources[target]) {
						show_error("The target and the source are the same: \"" target "\".")
						break
					}
					if (is_generated_target(target)) {
						show_error("The target \"" target "\" is already being generated.");
						break
					}
					mark_as_generated_target(target ".stamp")
					mark_as_generated_target(target)
					push_current_block_output(".STAMP: " target ".stamp")
					push_current_block_output(prefix_sources(target ":", cur_block))
					if (get_current_block_targetoption(target, "executable")) {
						chmod = "$(CHMOD_0555)"
					} else {
						chmod = "$(CHMOD_0444)"
					}
					push_current_block_output( prefix_gl0( \
						"\t@CHMOD='" chmod "' $(NOFAKE_SH) -R'" name "' $(NOFAKEFLAGS)", \
						"\t    ") " -o '" target "'")
				}
			} else {
				show_error("There are no sources defined to generate the targets.")
			}
		} else if (cur_type == "nofake-awk") {
			i_len = length_block_source(cur_block)
			if (i_len) {
				for (idx in known_sources) delete known_sources[idx]
				clear_gl0()
				for (i=0; i<i_len; i++) {
					item = get_block_source(cur_block, i)
					known_sources[item]++
					type = get_block__type(item)
					if (!type) {
						# just a plain primary dependency that lives
						# in vpath
						item = "'$(SRC_PREFIX)" item "'"
					}
					push_gl0(item)
				}
				s1_prefix = cur_block
				if (sub(/\.nw$/, "", s1_prefix)) target = cur_block
				else target = s1_prefix "-s1.nw"
				s1_awk = s1_prefix "-s1.awk"
				s1_ops = s1_prefix "-s1.ops"
				s1_nw = target
				mark_as_generated_target(s1_awk)
				mark_as_generated_target(s1_ops)
				mark_as_generated_target(target)
				push_gl0("'" s1_nw "'")
				if (!known_sources[target]) {
					push_current_block_output(prefix_sources(target ":", cur_block))
					push_current_block_output(prefix_sources("\t$(NOFAKE) -Rgenerator", cur_block) " \\")
					push_current_block_output("\t    > '.tmp." s1_awk "'")
					push_current_block_output("\t$(MV) '.tmp." s1_awk "' '" s1_awk "'")
					push_current_block_output(prefix_sources("\t$(NOFAKE) -Roperations", cur_block) " \\")
					push_current_block_output("\t    > '.tmp." s1_ops "'")
					push_current_block_output("\t$(MV) '.tmp." s1_ops "' '" s1_ops "'")
					push_current_block_output("\t$(AWK) -f '" s1_awk "' '" s1_ops "' \\")
					push_current_block_output("\t    > '.tmp." target "'")
					push_current_block_output("\t$(MV) '.tmp." target "' '" target "'")
					push_current_block_output("\t$(CHMOD_0444) '" s1_awk "' '" s1_ops "' '" target "'")
					push_current_block_output("")
					i_len = length_block_chunk(cur_block)
					if (!i_len) {
						show_error("There are no chunks defined (thus no targets).")
					}
					for (i=0; i<i_len && nerrors == 0; i++) {
						name = get_current_block_chunk__name(i)
						target = get_current_block_chunk__target(i)
						if (known_sources[target]) {
							show_error("The target and the source are the same: \"" target "\".")
							break
						}
						if (is_generated_target(target)) {
							show_error("The target \"" target "\" is already being generated.");
							break
						}
						mark_as_generated_target(target ".stamp")
						mark_as_generated_target(target)
						push_current_block_output(".STAMP: " target ".stamp")
						push_current_block_output(target ": " s1_nw)
						if (get_current_block_targetoption(target, "executable")) {
							chmod = "$(CHMOD_0555)"
						} else {
							chmod = "$(CHMOD_0444)"
						}
						push_current_block_output( prefix_gl0( \
							"\t@CHMOD='" chmod "' $(NOFAKE_SH) -R'" name "' $(NOFAKEFLAGS)", \
							"\t    ") " -o '" target "'")
					}
				} else {
					show_error("The target and the source are the same: \"" target "\".")
				}
			} else {
				show_error("There are no sources defined to generate the targets.")
			}
		} else if (cur_type == "c-object") {
			source_len = length_block_source(cur_block)
			if (source_len == 1) {
				source = get_block_source(cur_block, 0)
				target = cur_block
				sub("\\." objext "$", "", target)
				target = target "." objext
				mark_as_generated_target(target)
				if (!is_generated_target(source)) {
					source = "$(SRC_PREFIX)" source
				}
				push_current_block_output(prefix_primary_dependencies(target ": " source, cur_block, 1, "    "))
				push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " target " '" source "'")
			} else if (source_len) {
				show_error("c-object \"" cur_block "\" expects 1 source, " source_len " provided")
			} else {
				show_error("c-object \"" cur_block "\" has no source")
			}
		} else if (cur_type == "internal-vars") {
			push_current_block_output(set_var_from_env_template("AWK", "nawk"))
			push_current_block_output(set_var_from_env_template("BUILD_MAKEFILE", "Makefile"))
			push_current_block_output_deferred("OBJEXT")
			push_current_block_output_deferred("EXESUFFIX")
			push_current_block_output_deferred("SRC_PREFIX")
			push_current_block_output_deferred("SRC_INCLUDE")
			push_current_block_output_deferred("SUBDIR")
			push_current_block_output_deferred("TOP")
			push_current_block_output_deferred("TOP_SRC_DIR")
			push_current_block_output_deferred("NOFAKE")
			push_current_block_output_deferred("NOFAKE_SH")
			push_current_block_output_deferred("INSTALL")
			push_current_block_output_deferred("C_PROGRAMS")
			push_current_block_output_deferred("NOFAKE_SOURCES")
			push_current_block_output_deferred("NOFAKE_CHUNKS")
			push_current_block_output_deferred("GENERATED_TARGETS")
		} else if (cur_type == "generated") {
			mark_as_generated_target(cur_block)
		} else if (cur_type) {
			show_error("exhaustion-7: " FILENAME ":" FNR ": type: " cur_type)
		} else if (!length_block_output(cur_block)) {
			show_error("type not defined in an empty block")
		}
		if (nerrors) {
			print "\nERROR: Exiting with failure due to the presence of errors.\n"
			exit 1
		}
	}

	# compute some vars
	clear_gl0()
	for (item in generated_targets) {
		if (generated_targets[item]) {
			# always do a proper check for items in awk arrays
			# when using 'for in'
			push_gl0(item)
		}
	}
	vars["GENERATED_TARGETS"] = prefix_gl0("GENERATED_TARGETS =")

	i_len = length_deferred()
	for (i=0; i<i_len; i++) {
		# non-trivial refers to a non-trivial index into block
		nontrivial = get_deferred(i)
		varname = get_block(nontrivial)
		set_block(nontrivial, vars[varname])
	}

	# output all blocks
	i_len = length_block()
	for (i=0; i<i_len; i++) {
		cur_block = get_block(i)
		cur_type = get_block__type(cur_block)
		print "# **************** " cur_block " " (cur_type ? "(type: " cur_type ")" : "(no type)")
		j_len = length_block_output(cur_block)
		for (j=0; j<j_len; j++) {
			print get_block_output(cur_block, j)
		}
		print ""
	}

	if (length_block_output("")) {
		show_error(length_block_output("") " unknown lines (empty)")
		print ""
	}

	if (length_block_output(0)) {
		show_error(length_block_output(0) " unknown lines (0)")
		print ""
	}

	if (nerrors) {
		print "\nERROR: Exiting with failure due to the presence of errors.\n"
		exit 1
	}
}

