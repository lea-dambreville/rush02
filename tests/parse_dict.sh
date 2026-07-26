#!/bin/sh
# parse_dictionary / dict_lookup / free_dict -- srcs/parse_dict.c, currently
# mid-refactor (depends on ft_read_line.c for I/O, ft_dict.c for
# dict_lookup/free_dict/append_dict/realloc_dict, and ft_mem.c for
# ft_realloc -- not yet wired into the rush-02 Makefile as a working build).
# This test builds the module's own sources directly (same approach as
# tests/read_line.sh) and drives them through a dedicated main
# (tests/mains/parse_dict_main.c) that parses a given dict file and looks up
# requested keys.

# shellcheck source=lib.sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib.sh"

MAIN="$MAINS_DIR/parse_dict_main.c"
SRCS="$ROOT_DIR/srcs/parse_dict.c $ROOT_DIR/srcs/ft_dict.c $ROOT_DIR/srcs/ft_mem.c $ROOT_DIR/srcs/ft_read_line.c $ROOT_DIR/srcs/ft_string_1.c $ROOT_DIR/srcs/ft_string_2.c $ROOT_DIR/srcs/ft_string_3.c"

STRICT_FLAGS="-Wall -Wextra -Werror -I $ROOT_DIR/includes"

OBJS=$(compile_strict_each "$SRCS") || { report; exit $?; }
BIN=$(link_main_multi "$OBJS" "$MAIN" "-I $ROOT_DIR/includes") || { report; exit $?; }

# --- fixtures ---
F_GOOD="$_WORK_DIR/good.dict"
printf '0: zero\n1: one\n2: two\n10: ten\n100: hundred\n' >"$F_GOOD"

# Extra whitespace between the number and ':' and between ':' and the value
# must be trimmed (trim_spaces), and blank lines in between must simply be
# skipped, not treated as malformed. Per the subject's grammar
# ([number][0-n spaces]:[0-n spaces][printable]) the line must start with
# the number itself -- no leading spaces before it.
F_WHITESPACE="$_WORK_DIR/whitespace.dict"
printf '0  :   zero  \n\n1:one\n\n2:  two\n' >"$F_WHITESPACE"

# A line with no ':' at all is malformed -- per parse_line, colon_idx runs
# to the terminating '\0' and the line is rejected.
F_NO_COLON="$_WORK_DIR/no_colon.dict"
printf '0: zero\n1 one\n2: two\n' >"$F_NO_COLON"

# An empty key (":value") or empty value ("key:") trims to an empty span,
# which trim_spaces reports as NULL -- parse_dict_data must reject the whole
# dictionary rather than silently store a NULL key/val.
F_EMPTY_KEY="$_WORK_DIR/empty_key.dict"
printf '0: zero\n: oneword\n2: two\n' >"$F_EMPTY_KEY"

F_EMPTY_VAL="$_WORK_DIR/empty_val.dict"
printf '0: zero\n1:\n2: two\n' >"$F_EMPTY_VAL"

# Duplicate keys: dict_lookup does a linear scan and returns the FIRST match
# (see srcs/parse_dict.c dict_lookup), so the earlier entry should win.
F_DUP_KEY="$_WORK_DIR/dup_key.dict"
printf '5: five\n5: FIVE_AGAIN\n' >"$F_DUP_KEY"

F_EMPTY_FILE="$_WORK_DIR/empty_file.dict"
: >"$F_EMPTY_FILE"

# A dict with more entries than DEFAULT_ENTRIES_SIZE (64, per ft_dict.h) must
# still parse correctly -- catches a fixed-capacity array that never grows.
F_MANY="$_WORK_DIR/many.dict"
i=0
while [ "$i" -lt 100 ]; do
	printf '%d: v%d\n' "$i" "$i" >>"$F_MANY"
	i=$((i + 1))
done

# --- helper ---
# run_pd FILE [keys...] -> stdout of the driver binary. Capped by RUN_TIMEOUT.
run_pd() {
	if command -v timeout >/dev/null 2>&1; then
		timeout "${RUN_TIMEOUT:-5}" "$BIN" "$@" 2>&1
	else
		"$BIN" "$@" 2>&1
	fi
}

# --- well-formed dict: correct size, correct lookups, missing key -> NULL ---
_out=$(run_pd "$F_GOOD" "0" "100" "999")
assert_eq "good dict: size" "SIZE 5" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "good dict: lookup 0" "KEY 0 -> zero" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "good dict: lookup 100" "KEY 100 -> hundred" "$(printf '%s\n' "$_out" | sed -n '3p')"
assert_eq "good dict: lookup missing key -> NULL" "KEY 999 -> NULL" "$(printf '%s\n' "$_out" | sed -n '4p')"

# --- whitespace around key/value trimmed; blank lines skipped ---
_out=$(run_pd "$F_WHITESPACE" "0" "1" "2")
assert_eq "whitespace: size (blank lines skipped)" "SIZE 3" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "whitespace: key trimmed" "KEY 0 -> zero" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "whitespace: val trimmed, no leading space" "KEY 1 -> one" "$(printf '%s\n' "$_out" | sed -n '3p')"
assert_eq "whitespace: val trimmed with extra internal spacing" "KEY 2 -> two" "$(printf '%s\n' "$_out" | sed -n '4p')"

# --- malformed input: whole dictionary must fail to parse, not silently
# skip the bad line and continue (parse_dictionary returns NULL) ---
_out=$(run_pd "$F_NO_COLON")
_st=$?
if [ "$_st" -eq 0 ]; then
	no "line with no colon -> PARSE_FAIL (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "line with no colon -> PARSE_FAIL" "PARSE_FAIL" "$_out"
fi

_out=$(run_pd "$F_EMPTY_KEY")
_st=$?
if [ "$_st" -eq 0 ]; then
	no "empty key (\":value\") -> PARSE_FAIL (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "empty key (\":value\") -> PARSE_FAIL" "PARSE_FAIL" "$_out"
fi

_out=$(run_pd "$F_EMPTY_VAL")
_st=$?
if [ "$_st" -eq 0 ]; then
	no "empty value (\"key:\") -> PARSE_FAIL (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "empty value (\"key:\") -> PARSE_FAIL" "PARSE_FAIL" "$_out"
fi

# --- duplicate keys: first entry wins (linear scan in dict_lookup) ---
_out=$(run_pd "$F_DUP_KEY" "5")
assert_eq "duplicate key: first entry wins" "KEY 5 -> five" "$(printf '%s\n' "$_out" | sed -n '2p')"

# --- empty file: zero entries is not itself malformed; NULL/0 depends on the
# subject's contract, but at minimum it must not crash and lookups on it
# must return NULL cleanly ---
_out=$(run_pd "$F_EMPTY_FILE" "0")
_st=$?
if [ "$_st" -eq 0 ]; then
	assert_eq "empty dict file: size 0" "SIZE 0" "$(printf '%s\n' "$_out" | sed -n '1p')"
	assert_eq "empty dict file: any lookup -> NULL" "KEY 0 -> NULL" "$(printf '%s\n' "$_out" | sed -n '2p')"
else
	assert_eq "empty dict file: PARSE_FAIL is also an acceptable contract" "PARSE_FAIL" "$_out"
fi

# --- nonexistent path: must fail cleanly, not crash ---
_out=$(run_pd "$_WORK_DIR/does_not_exist.dict" "0")
_st=$?
if [ "$_st" -eq 0 ]; then
	no "nonexistent dict path -> PARSE_FAIL (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "nonexistent dict path -> PARSE_FAIL" "PARSE_FAIL" "$_out"
fi

# --- a dict path that is a directory: open() succeeds, read() fails (EISDIR)
# -- must not crash, must be treated as a parse failure ---
_out=$(run_pd "$_WORK_DIR" "0")
_st=$?
if [ "$_st" -eq 0 ]; then
	no "dict path is a directory -> PARSE_FAIL (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "dict path is a directory -> PARSE_FAIL" "PARSE_FAIL" "$_out"
fi

# --- more entries than the initial fixed capacity (64): storage must grow,
# not silently drop/overflow past the 65th entry ---
_out=$(run_pd "$F_MANY" "0" "63" "64" "99")
assert_eq "many entries: size reflects all 100 lines" "SIZE 100" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "many entries: first entry" "KEY 0 -> v0" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "many entries: at the default-capacity boundary" "KEY 63 -> v63" "$(printf '%s\n' "$_out" | sed -n '3p')"
assert_eq "many entries: just past the default-capacity boundary" "KEY 64 -> v64" "$(printf '%s\n' "$_out" | sed -n '4p')"
assert_eq "many entries: last entry" "KEY 99 -> v99" "$(printf '%s\n' "$_out" | sed -n '5p')"

# --- dict_lookup edge cases per its own NULL guards ---
_out=$(run_pd "$F_GOOD" "")
assert_eq "lookup empty-string key -> NULL" "KEY  -> NULL" "$(printf '%s\n' "$_out" | sed -n '2p')"

# --- memory: parse_dictionary's own allocations (dict, entries array, each
# key/val string) plus ft_read_line's internal buffer must all be freed by
# the time this process exits, on both success and failure paths ---
assert_no_leaks "no leaks: well-formed dict, successful parse+lookups" "$BIN" "$F_GOOD" "0" "100" "999"
assert_no_leaks "no leaks: whitespace-heavy dict" "$BIN" "$F_WHITESPACE" "0"
assert_no_leaks "no leaks: malformed dict (parse failure path)" "$BIN" "$F_NO_COLON"
assert_no_leaks "no leaks: empty key (parse failure path)" "$BIN" "$F_EMPTY_KEY"
assert_no_leaks "no leaks: nonexistent path (open failure path)" "$BIN" "$_WORK_DIR/does_not_exist.dict"
assert_no_leaks "no leaks: many entries (capacity growth path)" "$BIN" "$F_MANY" "k99"

# --- malloc-failure guards: every malloc (dict itself, entries array, each
# ft_strdup/ft_strndup'd key/val, plus growth reallocations) must be checked
# -- a NULL return should propagate as a clean parse failure, never a crash.
assert_malloc_fail_survives "malloc-fail: no crash on any allocation failure (good dict)" "$BIN" "$F_GOOD" "0"
assert_malloc_fail_survives "malloc-fail: no crash on any allocation failure (many entries)" "$BIN" "$F_MANY" "k99"

report
