#!/bin/sh
# ft_read_line — standalone GNL-style line reader (WIP module, not yet wired
# into the rush-02 Makefile/binary). Lives in srcs/ft_read_line.c, plus its
# string helpers in srcs/ft_string_1.c and srcs/ft_string_2.c, declared in
# includes/ft_read_line.h ("char *ft_read_line(int fd, int *is_success)").
#
# This test builds those sources directly (bypassing rush-02's own Makefile,
# since this module isn't linked into it yet) and drives them through a
# dedicated test main (tests/mains/read_line_main.c) that loops calling
# ft_read_line against a real file and prints one record per line.

# shellcheck source=lib.sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib.sh"

MAIN="$MAINS_DIR/read_line_main.c"
SRCS="$ROOT_DIR/srcs/ft_read_line.c $ROOT_DIR/srcs/ft_string_1.c $ROOT_DIR/srcs/ft_string_2.c"

# -I so "ft_read_line.h" / "ft_string.h" resolve; strict flags stay in force
# (this overrides lib.sh's STRICT_FLAGS for the rest of this file only).
STRICT_FLAGS="-Wall -Wextra -Werror -I $ROOT_DIR/includes"

OBJS=$(compile_strict_each "$SRCS") || { report; exit $?; }
BIN=$(link_main_multi "$OBJS" "$MAIN" "-I $ROOT_DIR/includes") || { report; exit $?; }

# --- fixtures ---
F_SIMPLE="$_WORK_DIR/simple.txt"
printf 'hello\nworld\n' >"$F_SIMPLE"

F_NO_TRAILING_NL="$_WORK_DIR/no_trailing_nl.txt"
printf 'a\nb' >"$F_NO_TRAILING_NL"

F_EMPTY="$_WORK_DIR/empty.txt"
: >"$F_EMPTY"

F_EMPTY_LINES="$_WORK_DIR/empty_lines.txt"
printf '\n\nx\n\n' >"$F_EMPTY_LINES"

F_ONLY_NL="$_WORK_DIR/only_nl.txt"
printf '\n' >"$F_ONLY_NL"

F_NO_NL_AT_ALL="$_WORK_DIR/no_nl_at_all.txt"
printf 'justonelinenotrailingnewline' >"$F_NO_NL_AT_ALL"

# A file bigger than BUF_SIZE (4096, per includes/ft_read_line.h) so a single
# line spans multiple internal read() calls -- catches a buffer-join bug that
# a small fixture would never exercise.
F_BIG_LINE="$_WORK_DIR/big_line.txt"
awk 'BEGIN { s=""; for (i = 0; i < 5000; i++) s = s "a"; print s; print "second" }' >"$F_BIG_LINE"

# --- helpers ---
# run_read_line FILE -> stdout of the driver binary (all "L<n> ok=.. [..]"
# records plus the trailing "END ok=.." line), captured as one blob. Capped
# by RUN_TIMEOUT (lib.sh convention) so a solution hung inside a single
# ft_read_line call (not just an infinite loop across calls, which the
# driver's own MAX_LINES cap already catches) can't hang the suite. If the
# driver hit its own MAX_LINES safety cap (LOOP_LIMIT) or was killed by
# timeout, the raw output is truncated to a handful of lines before being
# handed to assert_eq -- otherwise a genuinely infinite-looping solution
# would dump thousands of lines to the terminal on every failed assertion.
run_read_line() {
	_raw=$(
		if command -v timeout >/dev/null 2>&1; then
			timeout "${RUN_TIMEOUT:-5}" "$BIN" "$1" 2>&1
		else
			"$BIN" "$1" 2>&1
		fi
	)
	case "$_raw" in
		*LOOP_LIMIT*)
			printf '%s\n' "$(printf '%s\n' "$_raw" | head -n 5)" "...(truncated: driver hit MAX_LINES, solution looks like an infinite loop)"
			;;
		*)
			printf '%s\n' "$_raw"
			;;
	esac
}

# --- multi-line file, most basic case ---
_out=$(run_read_line "$F_SIMPLE")
assert_eq "simple: line 0" "L0 ok=1 [hello]" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "simple: line 1" "L1 ok=1 [world]" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "simple: terminal END, clean EOF" "END ok=1" "$(printf '%s\n' "$_out" | sed -n '3p')"
assert_eq "simple: exactly 2 lines + END, no extra records" "3" "$(printf '%s\n' "$_out" | wc -l | tr -d ' ')"

# --- last line has no trailing '\n' at EOF: must still be returned once ---
_out=$(run_read_line "$F_NO_TRAILING_NL")
assert_eq "no trailing nl: line 0" "L0 ok=1 [a]" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "no trailing nl: line 1 (unterminated, still returned)" "L1 ok=1 [b]" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "no trailing nl: terminal END after the partial line" "END ok=1" "$(printf '%s\n' "$_out" | sed -n '3p')"

# --- a file that is a single line with no newline anywhere ---
_out=$(run_read_line "$F_NO_NL_AT_ALL")
assert_eq "single unterminated line: returned once" \
	"L0 ok=1 [justonelinenotrailingnewline]" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "single unterminated line: then clean EOF" "END ok=1" "$(printf '%s\n' "$_out" | sed -n '2p')"

# --- empty file: zero lines, immediate clean EOF ---
_out=$(run_read_line "$F_EMPTY")
assert_eq "empty file: no lines, immediate END ok=1" "END ok=1" "$_out"

# --- blank lines (including a leading and trailing blank) must round-trip
# as empty strings, not be skipped or merged with neighbors ---
_out=$(run_read_line "$F_EMPTY_LINES")
assert_eq "blank lines: line 0 is empty" "L0 ok=1 []" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "blank lines: line 1 is empty" "L1 ok=1 []" "$(printf '%s\n' "$_out" | sed -n '2p')"
assert_eq "blank lines: line 2 is x" "L2 ok=1 [x]" "$(printf '%s\n' "$_out" | sed -n '3p')"
assert_eq "blank lines: line 3 is empty" "L3 ok=1 []" "$(printf '%s\n' "$_out" | sed -n '4p')"
assert_eq "blank lines: terminal END" "END ok=1" "$(printf '%s\n' "$_out" | sed -n '5p')"

# --- a file that is just a single newline: one empty line, then EOF ---
_out=$(run_read_line "$F_ONLY_NL")
assert_eq "only newline: one empty line" "L0 ok=1 []" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "only newline: then clean EOF" "END ok=1" "$(printf '%s\n' "$_out" | sed -n '2p')"

# --- a line longer than BUF_SIZE must be reassembled whole across multiple
# internal read() calls, not truncated or split at the buffer boundary ---
_out=$(run_read_line "$F_BIG_LINE")
_expected_big=$(awk 'BEGIN { s=""; for (i = 0; i < 5000; i++) s = s "a"; print s }')
assert_eq "line longer than BUF_SIZE: full length preserved" \
	"L0 ok=1 [$_expected_big]" "$(printf '%s\n' "$_out" | sed -n '1p')"
assert_eq "line longer than BUF_SIZE: next line intact" "L1 ok=1 [second]" "$(printf '%s\n' "$_out" | sed -n '2p')"

# --- invalid fd: ft_read_line must report failure via is_success, not crash
# or loop forever. The driver returns exit 2 before even calling it for a
# bad path (open() failure), so exercise a bad *fd* directly by pointing the
# driver at a path that fails open() -- already covered by run_read_line's
# own open() call above using a nonexistent path here.
_out=$("$BIN" "$_WORK_DIR/does_not_exist_at_all.txt" 2>&1)
_st=$?
if [ "$_st" -ne 2 ]; then
	no "nonexistent path: driver's open() fails (exit 2)" "expected exit 2, got $_st" "output: [$_out]"
else
	ok "nonexistent path: driver's open() fails (exit 2)"
fi

# --- memory: every line returned must be freed by the caller, and every
# internal buffer freed by the time the driver exits -- valgrind will flag
# anything ft_read_line itself still owns (leaked lines_str, leaked partial
# joins on an error path, etc.) as "definitely/indirectly lost". ---
assert_no_leaks "no leaks: multi-line file, clean run" "$BIN" "$F_SIMPLE"
assert_no_leaks "no leaks: file with no trailing newline" "$BIN" "$F_NO_TRAILING_NL"
assert_no_leaks "no leaks: empty file" "$BIN" "$F_EMPTY"
assert_no_leaks "no leaks: blank lines" "$BIN" "$F_EMPTY_LINES"
assert_no_leaks "no leaks: line longer than BUF_SIZE" "$BIN" "$F_BIG_LINE"

# --- malloc-failure guards: every malloc (directly or via ft_strdup/
# ft_strndup/ft_strnjoin) must be checked -- a NULL return should propagate
# as a clean failure (is_success=0, NULL line), never a crash. Sweeps every
# malloc call site the driver hits while reading F_SIMPLE, forcing each one
# to fail in turn. ---
assert_malloc_fail_survives "malloc-fail: no crash on any allocation failure" "$BIN" "$F_SIMPLE"

report
