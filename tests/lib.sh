# shellcheck shell=sh
# Shared test helpers for C Piscine — rush02 tests. POSIX sh only.
# Sourced by each tests/ex*.sh and by run_tests.sh.
#
# Provides the same PASS/FAIL/SKIP reporting look as the shell-0x harnesses,
# plus C-specific gates: turn-in/garbage check, strict compile, norminette,
# allowed-functions (nm), and link+run.

# Colors (disabled if not a tty or NO_COLOR set)
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
	C_RED=$(printf '\033[31m'); C_GRN=$(printf '\033[32m')
	C_YEL=$(printf '\033[33m'); C_RST=$(printf '\033[0m')
else
	C_RED=''; C_GRN=''; C_YEL=''; C_RST=''
fi

# Repo root = parent of the tests/ dir this file lives in.
TESTS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT_DIR=$(dirname -- "$TESTS_DIR")
MAINS_DIR="$TESTS_DIR/mains"

# Compiler and 42's strict grade flags.
CC=${CC:-cc}
STRICT_FLAGS="-Wall -Wextra -Werror"

# Per-run counters live in a file so subshells can update them.
_COUNT_FILE=$(mktemp)
# Scratch dir for all compile artifacts; cleaned on exit.
_WORK_DIR=$(mktemp -d)
printf '0 0\n' >"$_COUNT_FILE"
trap 'rm -f "$_COUNT_FILE"; rm -rf "$_WORK_DIR"' EXIT

_bump() { # $1=pass|fail
	read -r p f <"$_COUNT_FILE"
	if [ "$1" = pass ]; then p=$((p + 1)); else f=$((f + 1)); fi
	printf '%s %s\n' "$p" "$f" >"$_COUNT_FILE"
}

# ok NAME  /  no NAME [detail...] -> record a pass/fail.
# All human-readable result lines go to stderr (fd 2) so helpers that also emit
# a value on stdout inside $(...) don't get their PASS/FAIL text captured.
ok() { _bump pass; printf '  %sPASS%s %s\n' "$C_GRN" "$C_RST" "$1" >&2; }
no() {
	_bump fail
	printf '  %sFAIL%s %s\n' "$C_RED" "$C_RST" "$1" >&2
	shift
	for line in "$@"; do printf '       %s\n' "$line" >&2; done
}

# skip NAME REASON -> informational, does not fail the suite.
skip() { printf '  %sSKIP%s %s (%s)\n' "$C_YEL" "$C_RST" "$1" "$2" >&2; }

# assert_eq NAME EXPECTED ACTUAL
assert_eq() {
	name=$1; exp=$2; act=$3
	if [ "$exp" = "$act" ]; then
		ok "$name"
	else
		no "$name" "expected: [$exp]" "actual:   [$act]"
	fi
}

# need_solution EX FILE -> print solution path on stdout, or report RED + fail.
# Usage: SRC=$(need_solution ex00 ft_putchar.c) || return 1
need_solution() {
	_ex=$1; _file=$2
	_path="$ROOT_DIR/$_ex/$_file"
	if [ ! -f "$_path" ]; then
		no "$_ex/$_file exists" "not found at $_path (write the solution)"
		return 1
	fi
	printf '%s\n' "$_path"
}

# check_turnin EX "file1 file2 ..." -> FAIL if the exercise dir contains any
# file other than the allowed turn-in files. Hidden dotfiles are checked too.
# Directories are not allowed unless listed. Returns nonzero on violation.
check_turnin() {
	_ex=$1; shift
	_dir="$ROOT_DIR/$_ex"
	_allowed=" $* "
	_bad=''
	# Enumerate all entries including dotfiles, excluding . and ..
	for _entry in "$_dir"/* "$_dir"/.*; do
		[ -e "$_entry" ] || continue
		_base=${_entry##*/}
		[ "$_base" = "." ] && continue
		[ "$_base" = ".." ] && continue
		case "$_allowed" in
			*" $_base "*) ;;
			*) _bad="$_bad $_base" ;;
		esac
	done
	if [ -n "$_bad" ]; then
		no "$_ex turn-in is clean" "unexpected file(s):$_bad" \
			"allowed:$_allowed"
		return 1
	fi
	ok "$_ex turn-in is clean (only:$_allowed)"
}

# check_turnin_clean EX -> for exercises where the exact file list isn't
# fixed ("Makefile, and files needed for your program"): FAIL if the dir
# (recursively) contains anything that isn't source (.c/.h), the Makefile, or
# a plain directory -- i.e. no committed binaries, .o files, .a archives, or
# other build junk alongside the turn-in.
check_turnin_clean() {
	_ex=$1
	_dir="$ROOT_DIR/$_ex"
	_bad=''
	while IFS= read -r _entry; do
		[ -e "$_entry" ] || continue
		_base=${_entry##*/}
		case "$_base" in
			.|..|.git) continue ;;
		esac
		[ -d "$_entry" ] && continue
		case "$_base" in
			Makefile|*.c|*.h) ;;
			*) _bad="$_bad ${_entry#"$_dir"/}" ;;
		esac
	done <<-EOF
	$(find "$_dir" -mindepth 1)
	EOF
	if [ -n "$_bad" ]; then
		no "$_ex turn-in is clean (no build artifacts)" "unexpected file(s):$_bad"
		return 1
	fi
	ok "$_ex turn-in is clean (Makefile + .c/.h only, no build artifacts)"
}

# compile_strict SRC -> compile solution alone with 42's strict flags.
# Prints the object path on stdout; FAILs (with compiler output) on error.
# Usage: OBJ=$(compile_strict "$SRC") || return 1
compile_strict() {
	_src=$1
	_obj="$_WORK_DIR/$(basename "$_src" .c).o"
	_log="$_WORK_DIR/compile.log"
	if $CC $STRICT_FLAGS -c "$_src" -o "$_obj" >"$_log" 2>&1; then
		ok "compiles clean ($CC $STRICT_FLAGS)"
		printf '%s\n' "$_obj"
	else
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "compiles clean ($CC $STRICT_FLAGS)" "$@"
		return 1
	fi
}

# compile_strict_each "SRC1 SRC2 ..." -> compile each source file separately
# with 42's strict flags (mirrors 42's real per-file libft build). Prints all
# object paths on stdout (one per line); FAILs per-file on error but keeps
# going so every broken file is reported, not just the first.
# Usage: OBJS=$(compile_strict_each "$SRC1 $SRC2") || return 1
compile_strict_each() {
	_ok=1
	for _src in $1; do
		_obj="$_WORK_DIR/$(basename "$_src" .c).o"
		_log="$_WORK_DIR/$(basename "$_src" .c)_compile.log"
		if $CC $STRICT_FLAGS -c "$_src" -o "$_obj" >"$_log" 2>&1; then
			ok "compiles clean: $(basename "$_src") ($CC $STRICT_FLAGS)"
			printf '%s\n' "$_obj"
		else
			set --
			while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
			no "compiles clean: $(basename "$_src") ($CC $STRICT_FLAGS)" "$@"
			_ok=0
		fi
	done
	[ "$_ok" = 1 ]
}

# run_norminette SRC -> norminette gate, or SKIP if norminette not installed.
run_norminette() {
	_src=$1
	if ! command -v norminette >/dev/null 2>&1; then
		skip "norminette" "not installed"
		return 0
	fi
	_log="$_WORK_DIR/norm.log"
	if norminette "$_src" >"$_log" 2>&1; then
		ok "norminette"
	else
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "norminette" "$@"
		return 1
	fi
}

# check_funcs "OBJ1 [OBJ2 ...]" "sym1 sym2 ..." -> FAIL if any object references
# an undefined symbol (a called function) outside the allowlist. Uses nm;
# best-effort. The allowlist is matched against the base symbol name.
# Symbols DEFINED in any of the given objects (e.g. a student's own helper
# function called from another .c in the same build) are never flagged — only
# symbols left undefined across the whole object set are truly external
# calls, since a genuinely undefined symbol would fail to link otherwise.
check_funcs() {
	_objs=$1; shift
	_allowed=" $* "
	_bad=''
	# nm 'T'/'t' entries are symbols defined in this object (its own
	# functions); build the set of names the student defined anywhere in the
	# given objects so cross-file calls to their own helpers aren't flagged.
	# shellcheck disable=SC2086
	_defined=" $(nm $_objs 2>/dev/null | awk '/ [Tt] /{print $3}' | sed 's/^_//' | sort -u | tr '\n' ' ') "
	# nm 'U' entries are undefined symbols (functions the solution calls).
	# Strip a leading underscore (some platforms prefix it) for matching.
	# shellcheck disable=SC2086
	for _sym in $(nm -u $_objs 2>/dev/null | awk '/^ *U /{print $2}'); do
		_name=${_sym#_}
		# Skip compiler/runtime-injected guard symbols the student never
		# wrote (e.g. __stack_chk_fail from -fstack-protector, *_chk
		# fortify wrappers). These are not "functions used".
		case "$_name" in
			_stack_chk_fail|__stack_chk_fail|*_chk) continue ;;
		esac
		# glibc implements some libc-allowed constructs via internal symbols
		# rather than the name the subject grants: reading `errno` compiles
		# to a call to __errno_location, and POSIX basename() (<libgen.h>)
		# links to __xpg_basename. Map these back to the name the allowlist
		# actually grants, so `errno`/`basename` permissions apply correctly
		# instead of always being flagged or always being silently ignored.
		case "$_name" in
			_errno_location) _name=errno ;;
			_xpg_basename) _name=basename ;;
		esac
		# Skip symbols the student defines themselves elsewhere in this
		# object set (own helper functions called across files).
		case "$_defined" in
			*" $_name "*) continue ;;
		esac
		case "$_allowed" in
			*" $_name "*) ;;
			*) _bad="$_bad $_name" ;;
		esac
	done
	if [ -n "$_bad" ]; then
		no "only allowed functions used" "forbidden symbol(s):$_bad" \
			"allowed:$_allowed"
		return 1
	fi
	ok "only allowed functions used (allowed:$_allowed)"
}

# The program's exit status is written to a temp file so callers using
# $(...) (a subshell) can read it afterward with run_status.
_STATUS_FILE="$_WORK_DIR/run_status"
run_status() { cat "$_STATUS_FILE" 2>/dev/null || printf '?\n'; }

# link_main OBJ MAIN_C -> compile + link solution object with the test main.
# The test main is compiled WITHOUT -Werror so scaffolding warnings can't fail
# the student's grade. Prints the resulting binary path on stdout; reports a
# single PASS on success or FAIL (with compiler/linker output) on error.
# Usage: BIN=$(link_main "$OBJ" "$MAIN") || return 1
link_main() {
	_obj=$1; _main=$2
	_main_obj="$_WORK_DIR/$(basename "$_main" .c)_main.o"
	_bin="$_WORK_DIR/run_$(basename "$_main" .c)"
	_log="$_WORK_DIR/link.log"
	if ! $CC -Wall -Wextra -c "$_main" -o "$_main_obj" >"$_log" 2>&1; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "test main compiles" "$@"
		return 1
	fi
	if ! $CC "$_obj" "$_main_obj" -o "$_bin" >"$_log" 2>&1; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "links with test main" "$@"
		return 1
	fi
	printf '%s\n' "$_bin"
}

# link_main_multi "OBJ1 OBJ2 ..." MAIN_C [INCLUDE_FLAGS] -> compile + link
# several solution objects with the test main (for exercises turned in as
# several .c files with no header, e.g. a libft_creator module, or split
# across a headers dir the test main needs -I for). Same contract as
# link_main. INCLUDE_FLAGS (optional) is passed verbatim to the test main's
# compile step, e.g. "-I /path/to/includes".
# Usage: BIN=$(link_main_multi "$OBJS" "$MAIN" "-I $INC_DIR") || return 1
link_main_multi() {
	_objs=$1; _main=$2; _inc=${3:-}
	_main_obj="$_WORK_DIR/$(basename "$_main" .c)_main.o"
	_bin="$_WORK_DIR/run_$(basename "$_main" .c)"
	_log="$_WORK_DIR/link.log"
	# shellcheck disable=SC2086
	if ! $CC -Wall -Wextra $_inc -c "$_main" -o "$_main_obj" >"$_log" 2>&1; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "test main compiles" "$@"
		return 1
	fi
	# shellcheck disable=SC2086
	if ! $CC $_objs "$_main_obj" -o "$_bin" >"$_log" 2>&1; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "links with test main" "$@"
		return 1
	fi
	printf '%s\n' "$_bin"
}

# run_bin BIN [args...] -> run an already-linked binary, capped by RUN_TIMEOUT
# so a buggy (e.g. infinite-loop) solution can't hang the suite. Prints program
# stdout on our stdout; records the exit status for run_status.
run_bin() {
	_bin=$1; shift
	if command -v timeout >/dev/null 2>&1; then
		timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@"
	else
		"$_bin" "$@"
	fi
	printf '%s\n' "$?" >"$_STATUS_FILE"
}

# build_and_run OBJ MAIN_C -> convenience for exercises whose function takes no
# args: link once and run once with no arguments.
# Usage: OUT=$(build_and_run "$OBJ" "$MAIN") || return 1;  st=$(run_status)
build_and_run() {
	_bin=$(link_main "$1" "$2") || return 1
	run_bin "$_bin"
}

# build_make_bin EX BIN_NAME -> `make` the turn-in dir (copied to a scratch
# dir first, so build artifacts never pollute the turn-in) and print the path
# to the resulting binary. FAILs with the Makefile's own build output on
# error. For exercises turned in as a Makefile + standalone program, run via
# argv/stdin/stdout/stderr rather than linked to a test main.
# Usage: BIN=$(build_make_bin ex00 ft_display_file) || return 1
build_make_bin() {
	_ex=$1; _binname=$2
	_src_dir="$ROOT_DIR/$_ex"
	_build_dir="$_WORK_DIR/${_ex}_build"
	_log="$_WORK_DIR/${_ex}_make.log"
	mkdir -p "$_build_dir"
	cp -r "$_src_dir/." "$_build_dir/"
	if ! (cd "$_build_dir" && make) >"$_log" 2>&1; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "make builds $_binname" "$@"
		return 1
	fi
	if [ ! -x "$_build_dir/$_binname" ]; then
		no "make produces ./$_binname" "not found (or not executable) in $_build_dir after make"
		return 1
	fi
	ok "make builds $_binname"
	printf '%s\n' "$_build_dir/$_binname"
}

# run_bin_split BIN [args...] -> run a binary with stdout and stderr captured
# SEPARATELY (unlike run_bin, which only exposes stdout on our stdout). Prints
# nothing on stdout itself; results are read back via out_of/err_of/run_status.
# stdin is redirected from /dev/null so a buggy solution blocking on stdin
# can't hang the suite.
# Usage: run_bin_split "$BIN" arg1 arg2; OUT=$(out_of); ERR=$(err_of)
_OUT_FILE="$_WORK_DIR/run_stdout"
_ERR_FILE="$_WORK_DIR/run_stderr"
run_bin_split() {
	_bin=$1; shift
	if command -v timeout >/dev/null 2>&1; then
		timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	else
		"$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	fi
	printf '%s\n' "$?" >"$_STATUS_FILE"
}
out_of() { cat "$_OUT_FILE" 2>/dev/null; }
err_of() { cat "$_ERR_FILE" 2>/dev/null; }

# --- fd tracing: verify open() file descriptors actually get close()d ---
# There's no black-box way to observe close() calls from outside a process,
# so we build a tiny LD_PRELOAD shim (tests/fixtures/fd_trace_preload.c) that
# logs every open()/close() call the traced binary makes, then diff the two
# sets of fd numbers. Best-effort: if the shim fails to build (no gcc/dlopen
# support), tracing is silently skipped rather than failing the exercise for
# an environment limitation unrelated to the student's code.
_FD_TRACE_SO=""
_fd_trace_build() {
	[ -n "$_FD_TRACE_SO" ] && return 0
	_so="$_WORK_DIR/fd_trace_preload.so"
	if $CC -shared -fPIC -o "$_so" "$TESTS_DIR/fixtures/fd_trace_preload.c" -ldl >"$_WORK_DIR/fd_trace_build.log" 2>&1; then
		_FD_TRACE_SO="$_so"
		return 0
	fi
	return 1
}

# run_bin_traced BIN [args...] -> like run_bin_split, but also records every
# open()/close() syscall to a log readable via fd_trace_log. stdin is
# /dev/null, matching run_bin_split.
run_bin_traced() {
	_bin=$1; shift
	if ! _fd_trace_build; then
		run_bin_split "$_bin" "$@"
		_FD_TRACE_LOG=""
		return
	fi
	_FD_TRACE_LOG="$_WORK_DIR/fd_trace_$$_$(basename "$_bin").log"
	: >"$_FD_TRACE_LOG"
	if command -v timeout >/dev/null 2>&1; then
		LD_PRELOAD="$_FD_TRACE_SO" FD_TRACE_LOG="$_FD_TRACE_LOG" \
			timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	else
		LD_PRELOAD="$_FD_TRACE_SO" FD_TRACE_LOG="$_FD_TRACE_LOG" \
			"$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	fi
	printf '%s\n' "$?" >"$_STATUS_FILE"
}

# assert_fds_closed NAME -> FAIL if the most recent run_bin_traced call opened
# any fd (other than std streams) that was never subsequently closed. SKIPs
# (does not fail the suite) if tracing wasn't available in this environment.
assert_fds_closed() {
	_name=$1
	if [ -z "${_FD_TRACE_LOG:-}" ] || [ ! -s "$_FD_TRACE_LOG" ]; then
		if [ -z "$_FD_TRACE_SO" ]; then
			skip "$_name" "fd tracing unavailable in this environment (LD_PRELOAD shim failed to build)"
			return 0
		fi
	fi
	_leaked=$(awk '
		/^OPEN / { open[$2]=1 }
		/^CLOSE / { delete open[$2] }
		END { for (fd in open) print fd }
	' "$_FD_TRACE_LOG" 2>/dev/null | sort -n | tr '\n' ' ')
	if [ -n "$_leaked" ]; then
		no "$_name" "fd(s) opened but never closed: $_leaked"
	else
		ok "$_name"
	fi
}

# run_bin_stdin BIN STDIN_FILE [args...] -> like run_bin_split, but stdin is
# fed from STDIN_FILE instead of /dev/null (for exercises that must read
# stdin when no file args are given, e.g. a cat clone). Still capped by
# RUN_TIMEOUT so a solution that hangs waiting for more input can't hang the
# suite; STDIN_FILE should be a real file (not a pipe) so EOF is reached.
run_bin_stdin() {
	_bin=$1; _stdin=$2; shift 2
	if command -v timeout >/dev/null 2>&1; then
		timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@" <"$_stdin" >"$_OUT_FILE" 2>"$_ERR_FILE"
	else
		"$_bin" "$@" <"$_stdin" >"$_OUT_FILE" 2>"$_ERR_FILE"
	fi
	printf '%s\n' "$?" >"$_STATUS_FILE"
}

# --- valgrind leak checking ---
# assert_no_leaks NAME BIN [args...] -> run BIN under valgrind --leak-check
# and FAIL if it reports any "definitely lost" or "indirectly lost" bytes, or
# exits via a memory error valgrind itself flags. SKIPs (does not fail the
# suite) if valgrind isn't installed. stdin is /dev/null; capped by
# RUN_TIMEOUT (valgrind's own slowdown is accounted for by scaling it up).
assert_no_leaks() {
	_name=$1; shift
	_bin=$1; shift
	if ! command -v valgrind >/dev/null 2>&1; then
		skip "$_name" "valgrind not installed"
		return 0
	fi
	_log="$_WORK_DIR/valgrind_$$_$(basename "$_bin").log"
	_timeout=$((${RUN_TIMEOUT:-5} * 10))
	if command -v timeout >/dev/null 2>&1; then
		timeout "$_timeout" valgrind --leak-check=full --error-exitcode=97 \
			--log-file="$_log" "$_bin" "$@" <"/dev/null" >/dev/null 2>&1
	else
		valgrind --leak-check=full --error-exitcode=97 \
			--log-file="$_log" "$_bin" "$@" <"/dev/null" >/dev/null 2>&1
	fi
	_st=$?
	if [ "$_st" -eq 124 ] || [ "$_st" -eq 137 ]; then
		no "$_name" "timed out under valgrind (possible infinite loop)"
		return 1
	fi
	_lost=$(awk '
		/definitely lost:/ || /indirectly lost:/ {
			for (i = 1; i <= NF; i++)
				if ($i ~ /^[0-9,]+$/) { gsub(",", "", $i); sum += $i; break }
		}
		END { print sum + 0 }
	' "$_log")
	if [ "$_lost" -gt 0 ] || [ "$_st" -eq 97 ]; then
		set --
		while IFS= read -r _line; do set -- "$@" "$_line"; done <"$_log"
		no "$_name" "$@"
		return 1
	fi
	ok "$_name"
}

# --- malloc-failure injection ---
# There's no black-box way to force a specific malloc() call to fail, so we
# build a tiny LD_PRELOAD shim (tests/fixtures/malloc_fail_preload.c) that
# fails the Nth malloc call (1-based, MALLOC_FAIL_AT) and let a test sweep N
# across every allocation site to verify each one is guarded (checked for
# NULL, doesn't crash, frees what it already held). Best-effort: if the shim
# fails to build, malloc-failure testing is silently skipped rather than
# failing the exercise for an environment limitation unrelated to the
# student's code.
_MALLOC_FAIL_SO=""
_malloc_fail_build() {
	[ -n "$_MALLOC_FAIL_SO" ] && return 0
	_so="$_WORK_DIR/malloc_fail_preload.so"
	if $CC -shared -fPIC -o "$_so" "$TESTS_DIR/fixtures/malloc_fail_preload.c" -ldl >"$_WORK_DIR/malloc_fail_build.log" 2>&1; then
		_MALLOC_FAIL_SO="$_so"
		return 0
	fi
	return 1
}

# count_mallocs BIN [args...] -> number of malloc() calls BIN makes (via the
# same shim, with MALLOC_FAIL_AT unset so nothing actually fails), so a test
# can sweep 1..N. Prints the count on stdout, or nothing if the shim is
# unavailable (caller should treat that as "skip the sweep").
count_mallocs() {
	_bin=$1; shift
	_malloc_fail_build || return 1
	_log="$_WORK_DIR/malloc_count_$$_$(basename "$_bin").log"
	: >"$_log"
	if command -v timeout >/dev/null 2>&1; then
		LD_PRELOAD="$_MALLOC_FAIL_SO" MALLOC_FAIL_LOG="$_log" \
			timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@" <"/dev/null" >/dev/null 2>&1
	else
		LD_PRELOAD="$_MALLOC_FAIL_SO" MALLOC_FAIL_LOG="$_log" \
			"$_bin" "$@" <"/dev/null" >/dev/null 2>&1
	fi
	wc -l <"$_log" | tr -d ' '
}

# run_with_malloc_fail N BIN [args...] -> run BIN with its Nth malloc() call
# forced to return NULL. Behaves like run_bin_split (stdout/stderr captured
# separately, status via run_status); prints nothing on stdout itself.
# Usage: run_with_malloc_fail "$n" "$BIN" arg1; st=$(run_status)
run_with_malloc_fail() {
	_n=$1; shift
	_bin=$1; shift
	if command -v timeout >/dev/null 2>&1; then
		LD_PRELOAD="$_MALLOC_FAIL_SO" MALLOC_FAIL_AT="$_n" \
			timeout "${RUN_TIMEOUT:-5}" "$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	else
		LD_PRELOAD="$_MALLOC_FAIL_SO" MALLOC_FAIL_AT="$_n" \
			"$_bin" "$@" <"/dev/null" >"$_OUT_FILE" 2>"$_ERR_FILE"
	fi
	printf '%s\n' "$?" >"$_STATUS_FILE"
}

# assert_malloc_fail_survives NAME BIN [args...] -> sweep every malloc() call
# BIN makes (1..count), forcing each one to fail in turn, and FAIL if any
# induced failure causes a crash (SIGSEGV/SIGABRT-style exit) rather than a
# clean non-crashing exit. Doesn't assert a *specific* exit code, since the
# right behavior (return NULL, print an error, etc.) is the student's design
# choice -- only "must not crash" is a universal, checkable contract. SKIPs
# if the shim is unavailable in this environment.
assert_malloc_fail_survives() {
	_name=$1; shift
	_bin=$1; shift
	if ! _malloc_fail_build; then
		skip "$_name" "malloc-fail injection unavailable in this environment"
		return 0
	fi
	_count=$(count_mallocs "$_bin" "$@")
	if [ -z "$_count" ] || [ "$_count" -eq 0 ]; then
		skip "$_name" "no malloc() calls observed to inject failure into"
		return 0
	fi
	_bad=''
	_i=1
	while [ "$_i" -le "$_count" ]; do
		run_with_malloc_fail "$_i" "$_bin" "$@"
		_st=$(run_status)
		# A crash shows up as exit >= 128 (killed by signal) under sh's
		# convention, or -1/139 etc. depending on shell; 124 is our own
		# timeout marker from a hang.
		if [ "$_st" -ge 128 ] 2>/dev/null; then
			_bad="$_bad $_i:sig$((_st - 128))"
		fi
		_i=$((_i + 1))
	done
	if [ -n "$_bad" ]; then
		no "$_name" "crashed when malloc call(s) failed:$_bad" "(out of $_count total malloc calls)"
	else
		ok "$_name (swept $_count malloc call(s), no crash on any single failure)"
	fi
}

# report -> final tally for one exercise file; exit status via $?.
report() {
	read -r p f <"$_COUNT_FILE"
	printf '  --> %s passed, %s failed\n' "$p" "$f" >&2
	[ "$f" -eq 0 ]
}
