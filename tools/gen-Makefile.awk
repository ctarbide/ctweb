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
	if (!objext) { objext = "o" }
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

################ block [recursive-dependency]

function push_block_recursivedependency(block_name, name) {
	block[block_name, "recursive-dependency", block[block_name, "recursive-dependency", ".length"]++] = name
}
function length_block_recursivedependency(block_name) {
	return block[block_name, "recursive-dependency", ".length"] + 0
}
function clear_block_recursivedependency(block_name) {
	return block[block_name, "recursive-dependency", ".length"] = 0
}
function get_block_recursivedependency(block_name, idx) {
	return block[block_name, "recursive-dependency", idx]
}

################ block source

function set_current_block__source(source) {
	return block[cur_block, "source"] = source
}
function get_block__source(name) {
	return block[name, "source"]
}

################ block [source-prepend]

function push_current_block_sourceprepend(source) {
	block[cur_block, "source-prepend", block[cur_block, "source-prepend", ".length"]++] = source
}
function length_current_block_sourceprepend() {
	return block[cur_block, "source-prepend", ".length"] + 0
}
function get_current_block_sourceprepend(idx) {
	return block[cur_block, "source-prepend", idx]
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

################ [deferred]

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

################ end of functions.awk

function set_var_from_env_template(var, def, \
		env) {
	env = ENVIRON[var]
	return var "=" (env ? env : def)
}

function push_chunk_custom(name, target) {
	push_current_block_chunk(name, target)
	push_chunk(name, target)
	map_chunk_target_to_block[target] = cur_block
}

function push_current_block_output_deferred(s) {
	push_deferred(lastindex_current_block_output())
	push_current_block_output(s)
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

function compute_recursive_dependencies(acc, block_name, i, i_len, \
		item, type) {
	while (i < i_len) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type == "c-object") {
			push_block_recursivedependency(acc, item "." objext)
			compute_recursive_dependencies(acc, item, 0, length_block_dependency(item))
		} else {
			push_block_recursivedependency(acc, item)
		}
		i++
	}
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
			# match a primary target
		} else if (!type) {
			# just a plain primary dependency
		} else {
			print "# error: exhaustion: type \"" type "\" (filter out non-primary dependencies)"
			continue
		}
		res++
	}
	return res;
}

function join_primary_dependencies(block_name, curlinelen, \
		res, i, i_len, item, itemlen, type) {
	res = ""
	i_len = length_block_dependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type ~ "^(c-object)$") {
			continue
		} else if (type ~ "^(nofake)$") {
			# it is common for a nofake chunk target
			# match a primary target
		} else if (!type) {
			# just a plain primary dependency
		} else {
			print "# error: exhaustion: type \"" type "\" (filter out non-primary dependencies)"
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

function join_c_objects(block_name, curlinelen, \
		res, i, i_len, item, itemlen, type) {
	res = ""
	i_len = length_block_dependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_dependency(block_name, i)
		type = get_block__type(item)
		if (type != "c-object") {
			continue;
		}
		item = item "." objext
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

function join_recursive_dependencies(block_name, curlinelen, \
		res, i, i_len, item, itemlen, type) {
	if (!length_block_recursivedependency(block_name)) {
		# calculate once
		compute_recursive_dependencies(block_name, block_name, 0, length_block_dependency(block_name))
	}
	res = ""
	i_len = length_block_recursivedependency(block_name)
	for (i=0; i<i_len; i++) {
		item = get_block_recursivedependency(block_name, i)
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

function prefix_primary_dependencies(prefix, block_name) {
	return prefix join_primary_dependencies(block_name, length(prefix))
}

function prefix_c_objects(prefix, block_name) {
	return prefix join_c_objects(block_name, length(prefix))
}

function prefix_recursive_dependencies(prefix, block_name) {
	return prefix join_recursive_dependencies(block_name, length(prefix))
}

/^=[a-zA-Z][a-zA-Z0-9\-_.]*$/ {
	# preamble
	cur_block = substr($0, 2)
	push_block(cur_block)
	next
}

/^,/ {
	# preamble
	push_current_block_output(substr($0, 2))
	next
}

/^type[ \t]/ {
	# preamble
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
		}
	} else {
		print "# error: orphan type"
	}
	next
}

/^dependency[ \t]/ {
	# preamble
	if (cur_block) {
		if (cur_type ~ "^(c-program|c-object)$") {
			push_current_block_dependency($2)
		} else if (cur_type != type_error) {
			print "# error: exhaustion: type: " cur_type
		}
	} else {
		print "# error: orphan dependency"
	}
	next
}

/^source[ \t]/ {
	# preamble
	if (cur_block) {
		if (cur_type == "nofake") {
			set_current_block__source($2)
		} else if (cur_type != type_error) {
			print "# error: exhaustion: type: " cur_type
		}
	} else {
		print "# error: orphan source"
	}
	next
}

/^chunk[ \t]/ {
	# preamble
	if (cur_block) {
		if (cur_type == "nofake") {
			name = $2    # the name inside noweb file
			target = $3  # output filename of this chunk
			if (map_chunk_target_to_block[target]) {
				print "# error: chunk target already defined: " target \
					" in block " map_chunk_target_to_block[target]
			} else {
				push_chunk_custom(name, target)
			}
		} else if (cur_type != type_error) {
			print "# error: exhaustion: type: " cur_type
		}
	} else {
		print "# error: orphan chunk"
	}
	next
}

/^source-prepend[ \t]/ {
	# preamble
	if (cur_block) {
		if (cur_type == "nofake") {
			file = $2
			if (file) {
				push_current_block_sourceprepend(file)
			} else {
				print "# error: missing file to prepend"
			}
		} else if (cur_type != type_error) {
			print "# error: exhaustion: type: " cur_type
		}
	} else {
		print "# error: orphan chunk"
	}
	next
}

/^target-option[ \t]/ {
	# preamble
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
			print "# error: exhaustion: type: " cur_type
		}
	} else {
		print "# error: orphan chunk"
	}
	next
}

/^internal-vars$/ {
	# preamble
	push_current_block_output(set_var_from_env_template("BUILD_AWK", "nawk"))
	push_current_block_output(set_var_from_env_template("BUILD_MAKEFILE", "Makefile"))
	push_current_block_output_deferred("OBJEXT")
	push_current_block_output_deferred("SRC_PREFIX")
	push_current_block_output_deferred("SRC_INCLUDE")
	push_current_block_output_deferred("SUBDIR")
	push_current_block_output_deferred("TOP")
	push_current_block_output_deferred("CAT")
	push_current_block_output_deferred("NOFAKE")
	push_current_block_output_deferred("INSTALL")
	push_current_block_output_deferred("C_PROGRAMS")
	push_current_block_output_deferred("NOFAKE_SOURCES")
	push_current_block_output_deferred("NOFAKE_CHUNKS")
	next
}

/^[ \t]*#/ {
	# preamble
	# print "# comment: " $0
	next
}

/^$/ {
	# preamble
	next
}

/^@$/ {
	# preamble
	if (cur_type == "c-program") {
		num_of_deps = how_many_primary_dependencies(cur_block)
		if (num_of_deps > 1) {
			src = cur_block "-all.c"
			obj = cur_block "-all." objext
			push_current_block_output(prefix_primary_dependencies(src ": actions", cur_block))
			push_current_block_output(prefix_primary_dependencies("\t$(CAT)", cur_block) " \\\n\t    >" src)
			push_current_block_output(obj ": " src)
			push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj " " src)
			push_current_block_output(prefix_c_objects(cur_block ": actions " obj, cur_block))
			push_current_block_output(prefix_c_objects("\t$(LD) $(LDFLAGS) -o " cur_block " " obj " $(LIBS)", cur_block))
		} else if (num_of_deps) {
			obj = cur_block "." objext
			push_current_block_output(prefix_primary_dependencies(obj ": actions", cur_block))
			push_current_block_output(prefix_primary_dependencies("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " obj, cur_block))
			push_current_block_output(prefix_c_objects(cur_block ": actions " obj, cur_block))
			push_current_block_output(prefix_c_objects("\t$(LD) $(LDFLAGS) -o " cur_block " " obj " $(LIBS)", cur_block))
		} else {
			print "# error: exhaustion: no primary dependencies for \"" cur_block "\""
		}
	} else if (cur_type == "nofake") {
		source_orig = get_block__source(cur_block)
		if (length_current_block_sourceprepend()) {
			source = "zz--" source_orig
			source_resolved_path = source
			source_deps = ""
			i_len = length_current_block_sourceprepend()
			for (i=0; i<i_len; i++) {
				source_deps = source_deps " " get_current_block_sourceprepend(i)
			}
			push_current_block_output(source ": actions" source_deps " " source_orig)
			push_current_block_output("\t$(CAT) " source_deps " \\\n\t    '" \
				source_orig "' >'.tmp." source "'")
			push_current_block_output("\t$(MV) '.tmp." source "' '" source "'")
		} else {
			source = source_orig
			source_resolved_path = "$(SRC_PREFIX)" source_orig
		}
		i_len = length_current_block_chunk()
		for (i=0; i<i_len; i++) {
			target = get_current_block_chunk__target(i)
			if (target == source_orig) {
				print "# error: the target and the source are the same: " target
			} else {
				name = get_current_block_chunk__name(i)
				push_current_block_output(target ": " source)
				push_current_block_output("\t$(NOFAKE) -R'" name \
					"' $(NOFAKEFLAGS) '" source_resolved_path "' > '.tmp." target "'")
				push_current_block_output("\t$(MV) '.tmp." target "' '" target "'")
				if (get_current_block_targetoption(target, "executable")) {
					push_current_block_output("\t$(CHMOD_0555) '" target "'")
				}
			}
		}
	} else if (cur_type == "c-object") {
		target = cur_block "." objext
		num_of_deps = how_many_primary_dependencies(cur_block)
		if (num_of_deps > 1) {
			src = cur_block "-all.c"
			push_current_block_output(prefix_primary_dependencies(src ": actions", cur_block))
			push_current_block_output(prefix_primary_dependencies("\t$(CAT)", cur_block) " \\\n\t    >" src)
			push_current_block_output(target ": " src)
			push_current_block_output("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " target " " src)
		} else if (num_of_deps) {
			push_current_block_output(prefix_primary_dependencies(target ": actions", cur_block))
			push_current_block_output(prefix_primary_dependencies("\t$(CC) $(CFLAGS) $(SRC_INCLUDE) -o " target, cur_block))
		} else {
			print "# error: exhaustion: no primary dependencies for \"" cur_block "\""
		}
	} else if (cur_type) {
		if (cur_type != type_error) {
			print "# error: exhaustion: type: " cur_type
		}
	} else if (!length_current_block_output()) {
		push_current_block_output("# error: type not defined in a block without output")
	}
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
	} else {
		print "# error: cannot determine VPATH"
	}
	print ""

	vars["OBJEXT"] = "OBJEXT = " objext
	if (src == ".") {
		vars["CAT"] = "CAT = cat"
	} else {
		vars["CAT"] = "CAT = VPATH=\".:" src "\" " tools_prefix "cat-vpath.sh"
	}
	vars["NOFAKE"] = "NOFAKE = " tools_prefix "nofake"
	vars["INSTALL"] = "INSTALL = " tools_prefix "install.sh"

	vars["C_PROGRAMS"] = prefix_c_programs("C_PROGRAMS =")
	vars["NOFAKE_CHUNKS"] = prefix_nofake_chunks("NOFAKE_CHUNKS =")

	vars["SRC_PREFIX"] = "SRC_PREFIX = " (src == "." ? "" : src "/" )
	vars["SRC_INCLUDE"] = "SRC_INCLUDE = -I'" src "'"
	vars["SUBDIR"] = "SUBDIR = " subdir
	vars["TOP"] = "TOP = " top

	i_len = length_deferred()
	for (i=0; i<i_len; i++) {
		# non-trivial refers to a non-trivial index into block
		nontrivial = get_deferred(i)
		varname = get_block(nontrivial)
		set_block(nontrivial, vars[varname])
	}

	i_len = length_block()
	for (i=0; i<i_len; i++) {
		print "# **************** " get_block(i)
		cur_block = get_block(i)
		cur_type = get_block__type(cur_block)
		if (cur_type == type_error) {
			print "# error: block \"" cur_block "\" has previously reported errors"
		} else {
			j_len = length_current_block_output()
			for (j=0; j<j_len; j++) {
				print get_block_output(cur_block, j)
			}
		}
		print ""
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
