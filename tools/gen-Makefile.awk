
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

	block[".length"] = 0
	chunk[".length"] = 0
}

function push_block(name) {
	block[block[".length"]++] = name
	block_output[name, ".length"] = 0
}

/^=[a-z0-9\-_.]+$/ {
	cur_block = substr($0, 2)
	push_block(cur_block)
}

function push_chunk(name, target,		idx) {
	idx = block_chunk[cur_block, ".length"]+0
	block_chunk[cur_block, idx, "name"] = name
	block_chunk[cur_block, idx, "target"] = target
	block_chunk[cur_block, ".length"]++

	idx = chunk[".length"]+0
	chunk[idx, "name"] = name
	chunk[idx, "target"] = target
	chunk[".length"]++

	map_chunk_target_to_block[target] = cur_block
}

function push_line(s) {
	sub(/^        /, "\t", s)
	block_output[cur_block, block_output[cur_block, ".length"]++] = s
}

function push_line_deferred(s) {
	deferred[deferred[".length"]++] = cur_block SUBSEP (block_output[cur_block, ".length"]+0)
	push_line(s)
}

function join_block_names_by_type(curlinelen, type,		res, count, item, itemlen) {
	res = ""
	count = block[".length"]
	for (i=0; i<count; i++) {
		item = block[i]
		if (block_type[item] != type) {
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
		if (block_type[item] != "nofake") {
			continue
		}
		item = block_source[item]
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

/^,/ {	push_line(substr($0, 2)) }

/^@$/ {
	if (cur_type == "c-program") {
		src = cur_block "-all.c"
		obj = cur_block "-all." objext

		push_line(prefix_dependencies(src ":", cur_block))
		push_line(prefix_dependencies("        $(CAT)", cur_block) " \\\n\t    >" src)

		push_line(obj ": " src)
		push_line("\t$(CC) $(CFLAGS) -o " obj " " src)

		push_line(cur_block ": " obj)
		push_line("\t$(LD) $(LDFLAGS) -o " cur_block " " obj " $(LIBS)")

		cur_type = 0
	} else if (cur_type == "nofake") {
		source = block_source[cur_block]
		print "# **************************************************************** source: [" source "]"
        } else if (cur_type) {
		print "# error: exaustion: type: " cur_type
	}
	cur_block = 0
}

/^type[ \t]/ {
	if (cur_block) {
		cur_type = $2
		block_type[cur_block] = cur_type
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
			block_source[cur_block] = $2
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

function export(var, def) {
	env = ENVIRON[var]
	return var "=" (env ? env : def)
}

/^internal-vars$/ {
	push_line(export("BUILD_AWK", "nawk"))
	push_line(export("BUILD_MAKEFILE", "Makefile"))
	push_line("OBJEXT=" objext)
	push_line_deferred("C_PROGRAMS")
	push_line_deferred("NOFAKE_SOURCES")
	push_line_deferred("NOFAKE_CHUNKS")
	push_line_deferred("CAT")
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
		vars["CAT"] = "CAT = cat"
	} else if (vpath ~ /\// && subdir) {
		# absolute vpath
		print "VPATH = " vpath "/" subdir
		vars["CAT"] = "CAT = VPATH=\"" vpath "/" subdir "\" " vpath "/tools/cat-vpath.sh"
		print ""
	} else if (vpath && subdir && top) {
		# relative vpath
		print "VPATH = " vpath "/" top "/" subdir
		vars["CAT"] = "CAT = VPATH=\"" vpath "/" top "/" subdir "\" " vpath "/" top "/tools/cat-vpath.sh"
	} else {
		print "# error: cannot determine VPATH"
	}

	vars["C_PROGRAMS"] = prefix_c_programs("C_PROGRAMS =")
	vars["NOFAKE_SOURCES"] = prefix_nofake_sources("NOFAKE_SOURCES =")
	vars["NOFAKE_CHUNKS"] = prefix_nofake_chunks("NOFAKE_CHUNKS =")

	ilen = deferred[".length"]
	for (i=0; i<ilen; i++) {
		d = deferred[i]
		block_output[d] = vars[block_output[d]]
	}

	ilen = block[".length"]
	for (i=0; i<ilen; i++) {
		print "# **************** " block[i]
		cur_block = block[i]
		jlen = block_output[cur_block, ".length"]
		for (j=0; j<jlen; j++) {
			print block_output[cur_block, j]
		}
		print ""
	}

	if (block_output["", ".length"]) {
		print "# WARNING: " block_output["", ".length"] " unknown lines (empty)"
		print ""
	}

	if (block_output[0, ".length"]) {
		print "# WARNING: " block_output[0, ".length"] " unknown lines (0)"
		print ""
	}
}
