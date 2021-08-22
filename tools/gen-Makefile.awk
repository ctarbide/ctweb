
# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.


# objective: generate portable Makefiles from a simple
# description language

BEGIN{
	objext = ENVIRON["OBJEXT"]
	if (!objext) { objext = "o" }
	maxlinelen = 72
}

function push_block(name) {
	block[block[".length"]++] = name
}

/^=[a-z0-9\-_.]+$/ {
	cur_block = substr($0, 2)
	push_block(cur_block)
}

function push_chunk(name, target,		idx) {
	idx = block[cur_block, "chunk", ".length"]+0
	block[cur_block, "chunk", idx, "name"] = name
	block[cur_block, "chunk", idx, "target"] = target
	block[cur_block, "chunk", ".length"]++

	idx = chunk[".length"]+0
	chunk[idx, "name"] = name
	chunk[idx, "target"] = target
	chunk[".length"]++

	map_chunk_target_to_block[target] = cur_block
}

function push_block_output(s) {
	sub(/^        /, "\t", s)
	idx = block[cur_block, "output", ".length"]+0
	block[cur_block, "output", idx] = s
	block[cur_block, "output", ".length"]++
}

function push_block_output_deferred(s) {
	deferred[deferred[".length"]++] = cur_block SUBSEP "output" SUBSEP (block[cur_block, "output", ".length"]+0)
	push_block_output(s)
}

function join_block_names_by_type(curlinelen, type,		res, count, item, itemlen) {
	res = ""
	count = block[".length"]
	for (i=0; i<count; i++) {
		item = block[i]
		if (block[item, "type"] != type) {
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

function join_nofake_sources_base(curlinelen,		res, count, item, itemlen) {
	res = ""
	count = block[".length"]
	for (i=0; i<count; i++) {
		item = block[i]
		if (block[item, "type"] != "nofake") {
			continue
		}
		item = block[item, "source"]
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

function join_nofake_sources(curlinelen) {
	return join_nofake_sources_base(curlinelen)
}

function prefix_nofake_sources(prefix) {
	return prefix join_nofake_sources(length(prefix))
}

function join_nofake_chunks_base(curlinelen,		res, count, item, itemlen) {
	res = ""
	count = chunk[".length"]
	for (i=0; i<count; i++) {
		item = chunk[i, "target"]
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

function join_nofake_chunks(curlinelen) {
	return join_nofake_chunks_base(curlinelen)
}

function prefix_nofake_chunks(prefix) {
	return prefix join_nofake_chunks(length(prefix))
}

function join_dependencies(block_name, curlinelen,		res, count, item, itemlen) {
	res = ""
	count = dependency[block_name, ".length"]+0
	for (i=0; i<count; i++) {
		item = dependency[block_name, i]
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

function prefix_dependencies(prefix, block_name) {
	return prefix join_dependencies(block_name, length(prefix))
}

/^,/ {	push_block_output(substr($0, 2)) }

/^@$/ {
	if (cur_type == "c-program") {
		src = cur_block "-all.c"
		obj = cur_block "-all." objext

		push_block_output(prefix_dependencies(src ":", cur_block))
		push_block_output(prefix_dependencies("        $(CAT)", cur_block) " \\\n\t    >" src)

		push_block_output(obj ": " src)
		push_block_output("\t$(CC) $(CFLAGS) -o " obj " " src)

		push_block_output(cur_block ": " obj)
		push_block_output("\t$(LD) $(LDFLAGS) -o " cur_block " " obj " $(LIBS)")
	} else if (cur_type == "nofake") {
		source_orig = block[cur_block, "source"]
		ilen = block[cur_block, "chunk", ".length"]+0
		if (block[cur_block, "source-prepend", ".length"]) {
			source = "zz--" source_orig
			source_deps = ""
			ilen = block[cur_block, "source-prepend", ".length"]
			for (i=0; i<ilen; i++) {
				source_deps = source_deps " " block[cur_block, "source-prepend", i]
			}
			source_resolved_path = source
			push_block_output(source ":" source_deps " " source_orig)
			push_block_output("        $(CAT) " source_deps " \\\n\t    '" \
				source_orig "' >'.tmp." source "'")
			push_block_output("        $(MV) '.tmp." source "' '" source "'")
		} else {
			source = source_orig
			source_resolved_path = "$(SRC_PREFIX)" source_orig
		}
		for (i=0; i<ilen; i++) {
			target = block[cur_block, "chunk", i, "target"]
			if (target == source_orig) {
				print "# error: the target and the source are the same: " target
			} else {
				name = block[cur_block, "chunk", i, "name"]
				push_block_output(target ": " source)
				push_block_output("        $(NOFAKE) -R'" name \
					"' $(NOFAKEFLAGS) '" source_resolved_path "' > '.tmp." target "'")
				push_block_output("        $(MV) '.tmp." target "' '" target "'")
				if (block[cur_block, "target-option", target, "executable"]) {
					push_block_output("        $(CHMOD_0755) '" target "'")
				}
			}
		}
	} else if (cur_type) {
		print "# error: exaustion: type: " cur_type
	} else if (!block[cur_block, "output", ".length"]) {
		push_block_output("# error: type not defined in a block without output")
	}
	cur_block = 0
	cur_type = 0
}

/^type[ \t]/ {
	if (cur_block) {
		cur_type = $2
		block[cur_block, "type"] = cur_type
	} else {
		print "# error: orphan type"
	}
}

/^dependency[ \t]/ {
	if (cur_type == "c-program") {
		if (cur_block) {
			dependency[cur_block, dependency[cur_block, ".length"]++] = $2
		} else {
			print "# error: orphan dependency"
		}
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
	}
}

/^source[ \t]+/ {
	if (cur_type == "nofake") {
		if (cur_block) {
			block[cur_block, "source"] = $2
		} else {
			print "# error: orphan source"
		}
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
        }
}

/^chunk[ \t]+/ {
	if (cur_type == "nofake") {
		if (cur_block) {
			name = $2    # the name inside noweb file
			target = $3  # output filename of this chunk
			if (map_chunk_target_to_block[target]) {
				print "# error: chunk target already defined: " target \
					" in block " map_chunk_target_to_block[target]
			} else {
				push_chunk(name, target)
			}
		} else {
			print "# error: orphan chunk"
		}
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
        }
}

/^source-prepend[ \t]+/ {
	if (cur_type == "nofake") {
		if (cur_block) {
			file = $2
			if (file) {
				idx = block[cur_block, "source-prepend", ".length"]++
				block[cur_block, "source-prepend", idx] = file
			} else {
				print "# error: missing file to prepend"
			}
		} else {
			print "# error: orphan chunk"
		}
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
        }
}

/^target-option[ \t]+/ {
	if (cur_type == "nofake") {
		if (cur_block) {
			target = $2
			if (target) {
				option = $3
				if (option) {
					value = $4
					if (length(value)) {
						block[cur_block, "target-option", target, option] = value
					} else {
						print "# error: value is empty for target-option"
					}
				} else {
					print "# error: option is not defined for target-option"
				}
			} else {
				print "# error: target is not defined for target-option"
			}
		} else {
			print "# error: orphan chunk"
		}
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
        }
}

function export(var, def) {
	env = ENVIRON[var]
	return var "=" (env ? env : def)
}

/^internal-vars$/ {
	push_block_output(export("BUILD_AWK", "nawk"))
	push_block_output(export("BUILD_MAKEFILE", "Makefile"))
	push_block_output("OBJEXT=" objext)
	push_block_output_deferred("SRC_PREFIX")
	push_block_output_deferred("SUBDIR")
	push_block_output_deferred("TOP")
	push_block_output_deferred("CAT")
	push_block_output_deferred("NOFAKE")
	push_block_output_deferred("C_PROGRAMS")
	push_block_output_deferred("NOFAKE_SOURCES")
	push_block_output_deferred("NOFAKE_CHUNKS")
}

END{
	print ""
	print "# automatically generated, please to not edit"
	genbymsg = ENVIRON["GENERATED_BY_MESSAGE"]
	if (genbymsg) { print "# " genbymsg }
	print ""

	vpath = ENVIRON["VPATH"]
	subdir = ENVIRON["SUBDIR"]
	top = ENVIRON["TOP"]

	if (vpath == ".") {
		# in source build
		src = vpath
		vars["CAT"] = "CAT = cat"
		vars["NOFAKE"] = "NOFAKE = " top "/tools/nofake"
	} else if (vpath ~ /\// && subdir) {
		# absolute vpath
		src = vpath "/" subdir
		print "VPATH = " src
		vars["CAT"] = "CAT = VPATH=\"" vpath "/" subdir "\" " vpath "/tools/cat-vpath.sh"
		vars["NOFAKE"] = "NOFAKE = " vpath "/tools/nofake"
	} else if (vpath && subdir && top) {
		# relative vpath
		src = vpath "/" top "/" subdir
		print "VPATH = " src
		vars["CAT"] = "CAT = VPATH=\"" vpath "/" top "/" subdir "\" " vpath "/" top "/tools/cat-vpath.sh"
		vars["NOFAKE"] = "NOFAKE = " vpath "/" top "/tools/nofake"
	} else {
		print "# error: cannot determine VPATH"
	}
	print ""

	vars["C_PROGRAMS"] = prefix_c_programs("C_PROGRAMS =")
	vars["NOFAKE_SOURCES"] = prefix_nofake_sources("NOFAKE_SOURCES =")
	vars["NOFAKE_CHUNKS"] = prefix_nofake_chunks("NOFAKE_CHUNKS =")

	vars["SRC_PREFIX"] = "SRC_PREFIX = " (src == "." ? "" : src "/" )
	vars["SUBDIR"] = "SUBDIR = " subdir
	vars["TOP"] = "TOP = " top

	ilen = deferred[".length"]
	for (i=0; i<ilen; i++) {
		d = deferred[i]
		block[d] = vars[block[d]]
	}

	ilen = block[".length"]
	for (i=0; i<ilen; i++) {
		print "# **************** " block[i]
		cur_block = block[i]
		jlen = block[cur_block, "output", ".length"]
		for (j=0; j<jlen; j++) {
			print block[cur_block, "output", j]
		}
		print ""
	}

	if (block["", "output", ".length"]) {
		print "# WARNING: " block["", "output", ".length"] " unknown lines (empty)"
		print ""
	}

	if (block[0, "output", ".length"]) {
		print "# WARNING: " block[0, "output", ".length"] " unknown lines (0)"
		print ""
	}
}
