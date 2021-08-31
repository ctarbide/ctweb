
# Copyright (c) 2021, C. Tarbide.
# All rights reserved.

# Permission to distribute and use this work for any
# purpose is hereby granted provided this copyright
# notice is included in the copy.  This work is provided
# as is, with no warranty of any kind.

/^#@$/ { if (showheader) { showheader = 0; print; print "" } }
{ if (showheader) print }

#@

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

function set_current_block__type(type) {
	return block[cur_block, "type"] = type
}

function set_current_block__source(source) {
	return block[cur_block, "source"] = source
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

function length_current_block_output() {
	return block[cur_block, "output", ".length"] + 0
}

function lastindex_current_block_output() {
	return cur_block SUBSEP "output" SUBSEP (block[cur_block, "output", ".length"] + 0)
}

function get_block_output(block_name, idx) {
	return block[block_name, "output", idx]
}

function push_current_block_chunk(name, target, \
		idx) {
	idx = block[cur_block, "chunk", ".length"]++
	block[cur_block, "chunk", idx, "name"] = name
	block[cur_block, "chunk", idx, "target"] = target
}

function length_current_block_chunk() {
	return block[cur_block, "chunk", ".length"] + 0
}

function get_current_block_chunk__name(idx) {
	return block[cur_block, "chunk", idx, "name"]
}

function get_current_block_chunk__target(idx) {
	return block[cur_block, "chunk", idx, "target"]
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

function get_block__source(name) {
	return block[name, "source"]
}

function push_current_block_sourceprepend(source) {
	block[cur_block, "source-prepend", block[cur_block, "source-prepend", ".length"]++] = source
}

function length_current_block_sourceprepend() {
	return block[cur_block, "source-prepend", ".length"] + 0
}

function get_current_block_sourceprepend(idx) {
	return block[cur_block, "source-prepend", idx]
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

