#!/bin/sh
# rush02 — number-to-words converter.
# Turn-in: Makefile + srcs/ + includes/ (a Makefile-built program, not a
# per-exercise .c file), invoked as `./rush-02 [dict_path] <number>`.
#
# Contract asserted here (see srcs/main.c):
#   - argc must be 2 (number only, default dict "numbers.dict") or 3
#     (dict_path number); anything else -> "Error\n", exit 1.
#   - is_valid_number() rejects non-numeric input -> "Error\n", exit 1.
#   - Any dictionary problem (missing file, unreadable, or a lookup miss
#     during conversion) -> "Dict Error\n", exit 1.
#   - Otherwise: the converted words on stdout, newline-terminated, exit 0.

# shellcheck source=lib.sh
. "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)/lib.sh"

# Turn-in scope is srcs/ + includes/ (checked separately since the module
# root also holds this test harness, .git, README.md, numbers.dict, etc.,
# none of which check_turnin_clean's generic sweep should be judging).
check_turnin_clean "srcs"
check_turnin_clean "includes"

BIN=$(build_make_bin "." rush-02) || { report; exit $?; }

# rush-02's default dictionary path is relative to CWD ("numbers.dict"), so
# run it from the module root where that file lives.
run_rush() (cd "$ROOT_DIR" && "$1" "$2" "$3" 2>&1)

# assert_conv NUMBER EXPECTED_WORDS -> run with the default dict, compare
# stdout (trailing newline stripped by $()) and require exit 0.
assert_conv() {
	_n=$1; _exp=$2
	_out=$(cd "$ROOT_DIR" && "$BIN" "$_n" 2>/dev/null)
	_st=$?
	if [ "$_st" -ne 0 ]; then
		no "convert($_n) == \"$_exp\"" "expected exit 0, got $_st" "output: [$_out]"
		return
	fi
	assert_eq "convert($_n) == \"$_exp\"" "$_exp" "$_out"
}

# assert_err NUMBER EXPECTED_MSG [DICT_PATH] -> require exit 1 and the exact
# fixed error string (subject mandates "Error\n" / "Dict Error\n" literally).
assert_err() {
	_n=$1; _exp=$2; _dict=${3:-}
	if [ -n "$_dict" ]; then
		_out=$(cd "$ROOT_DIR" && "$BIN" "$_dict" "$_n" 2>&1)
	else
		_out=$(cd "$ROOT_DIR" && "$BIN" "$_n" 2>&1)
	fi
	_st=$?
	if [ "$_st" -eq 0 ]; then
		no "$_n -> \"$_exp\" (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
		return
	fi
	assert_eq "$_n -> \"$_exp\"" "$_exp" "$_out"
}

# --- golden path: single digits, the whole dictionary's atomic words ---
assert_conv "0" "zero"
assert_conv "1" "one"
assert_conv "5" "five"
assert_conv "9" "nine"

# --- teens: 10-19 are direct dictionary entries, not "ten" + unit ---
assert_conv "10" "ten"
assert_conv "11" "eleven"
assert_conv "15" "fifteen"
assert_conv "19" "nineteen"

# --- tens boundary: 20 is a direct entry; 21-29 are "twenty" + unit ---
assert_conv "20" "twenty"
assert_conv "21" "twenty-one"
assert_conv "29" "twenty-nine"
assert_conv "99" "ninety-nine"

# --- hundreds, including a teen remainder (tests hundred+teen composition,
# not hundred + tens-digit + units-digit) ---
assert_conv "100" "one hundred"
assert_conv "101" "one hundred and one"
assert_conv "110" "one hundred and ten"
assert_conv "119" "one hundred and nineteen"
assert_conv "999" "nine hundred and ninety-nine"

# --- thousands: exact scale word, scale + remainder, zero-group skipping ---
assert_conv "1000" "one thousand"
assert_conv "1001" "one thousand, one"
assert_conv "1020" "one thousand, twenty"
assert_conv "2000" "two thousand"
assert_conv "10000" "ten thousand"
assert_conv "100000" "one hundred thousand"
assert_conv "100100" "one hundred thousand, one hundred"

# --- million+: chunk-of-3 alignment must hold past the first scale jump ---
assert_conv "1000000" "one million"
assert_conv "123456789" \
	"one hundred and twenty-three million, four hundred and fifty-six thousand, seven hundred and eighty-nine"

# --- middle group is zero: scale word for that group must be skipped, not
# print a bare/duplicate magnitude word ---
assert_conv "1000001" "one million, one"
assert_conv "2000000001" "two billion, one"

# --- INT_MAX boundary (subject scope: only 32-bit-int-representable inputs) ---
assert_conv "2147483647" \
	"two billion, one hundred and forty-seven million, four hundred and eighty-three thousand, six hundred and forty-seven"

# --- leading zeros / leading '+' / leading whitespace: is_valid_number()
# accepts these (see srcs/parse_num.c), so they must still convert, not
# silently produce empty output ---
assert_conv "007" "seven"
assert_conv "+5" "five"
assert_conv "0" "zero"

# --- invalid input: argc / non-numeric -> plain "Error\n" ---
assert_err "-5" "Error"
assert_err "abc" "Error"
assert_err "" "Error"
assert_err "12a" "Error"
assert_err "1.5" "Error"

# argc == 1 (no number at all)
_out=$(cd "$ROOT_DIR" && "$BIN" 2>/dev/null); _st=$?
if [ "$_st" -eq 0 ]; then
	no "no args -> \"Error\" (exit 1)" "expected nonzero exit, got 0"
else
	assert_err "no args -> \"Error\"" "Error" "$_out"
fi

# argc == 4 (too many args)
_out=$(cd "$ROOT_DIR" && "$BIN" numbers.dict 1 extra 2>/dev/null); _st=$?
if [ "$_st" -eq 0 ]; then
	no "4 args -> \"Error\" (exit 1)" "expected nonzero exit, got 0"
else
	assert_err "4 args -> \"Error\"" "Error" "$_out"
fi

# ============================================================
# BONUS: "-", ",", and "and" for closer-to-correct written English.
#
# Convention asserted (British style, the common textbook form for reading
# numbers aloud/in prose):
#   - hyphen joins a tens word directly to a units word: "twenty-one", not
#     "twenty one" (only within a single ten's remainder, 21-99 excluding
#     the decade words themselves).
#   - "and" precedes the final sub-100 remainder whenever ANY higher part
#     (hundreds, thousands, millions, ...) precedes it: "one hundred and
#     one", "one thousand and one", "one million and one". No "and" when
#     there is no such remainder ("one hundred", "one thousand").
#   - a comma separates each 3-digit (thousand) group in numbers with more
#     than one such group: "one million, two hundred and thirty-four
#     thousand, five hundred and sixty-seven".
# These are currently unimplemented (see convert.c/print_word: words are
# always joined by a single space) -- expected RED until the bonus is done.
# ============================================================

assert_conv "21" "twenty-one"
assert_conv "99" "ninety-nine"
assert_conv "101" "one hundred and one"
assert_conv "100" "one hundred"
assert_conv "123" "one hundred and twenty-three"
assert_conv "1000" "one thousand"
assert_conv "1001" "one thousand, one"
assert_conv "1101" "one thousand, one hundred and one"
assert_conv "1234" "one thousand, two hundred and thirty-four"
assert_conv "1000000" "one million"
assert_conv "1000001" "one million, one"
assert_conv "1234567" \
	"one million, two hundred and thirty-four thousand, five hundred and sixty-seven"

# ============================================================
# BONUS: same exercise in another language via a translated dictionary.
#
# numbers_th.dict (Thai) is the reference translated dictionary for this
# bonus -- it's atomic/space-joined (see the file's own header comment for
# why full Thai concatenation and the 10^4/10^5 scale words aren't
# reachable through convert_number's chunk-of-3 grouping), so what IS
# reachable must convert correctly through the exact same binary and code
# path as English, just fed a different -I dict argument.
# ============================================================

assert_th() {
	_n=$1; _exp=$2
	_out=$(cd "$ROOT_DIR" && "$BIN" numbers_th.dict "$_n" 2>/dev/null)
	_st=$?
	if [ "$_st" -ne 0 ]; then
		no "th convert($_n) == \"$_exp\"" "expected exit 0, got $_st" "output: [$_out]"
		return
	fi
	assert_eq "th convert($_n) == \"$_exp\"" "$_exp" "$_out"
}

assert_th "0" "ศูนย์"
assert_th "5" "ห้า"
assert_th "20" "ยี่สิบ"
assert_th "99" "เก้าสิบ เก้า"
assert_th "100" "หนึ่ง ร้อย"
assert_th "1000" "หนึ่ง พัน"
assert_th "10000" "หนึ่ง หมื่น"
assert_th "10000" "หนึ่ง แสน"
assert_th "1000000" "หนึ่ง ล้าน"

# ============================================================
# BONUS: read numbers from stdin, one per line, when the number argument
# is "-". Per the subject's example: `./rush-02 -` (default dict, no dict
# arg) reads and converts each line until EOF, printing one result per
# line; `./rush-02 <dict> -` should work the same way with an explicit
# dict. Currently unimplemented -- main.c never special-cases "-", so it
# gets validated as a literal number string and rejected as "Error".
# ============================================================

# assert_stdin [DICT] LINES EXPECTED_LINES -> feed LINES (already
# newline-joined) to `./rush-02 -` (or `./rush-02 DICT -`), compare stdout
# line-for-line against EXPECTED_LINES, require exit 0.
assert_stdin() {
	if [ "$#" -eq 3 ]; then
		_dict=$1; _in=$2; _exp=$3
	else
		_dict=""; _in=$1; _exp=$2
	fi
	_stdin_file="$_WORK_DIR/stdin_input.txt"
	printf '%s' "$_in" >"$_stdin_file"
	if [ -n "$_dict" ]; then
		_out=$(cd "$ROOT_DIR" && "$BIN" "$_dict" - <"$_stdin_file" 2>/dev/null)
	else
		_out=$(cd "$ROOT_DIR" && "$BIN" - <"$_stdin_file" 2>/dev/null)
	fi
	_st=$?
	if [ "$_st" -ne 0 ]; then
		no "stdin: [$_in] -> [$_exp]" "expected exit 0, got $_st" "output: [$_out]"
		return
	fi
	assert_eq "stdin: [$_in] -> [$_exp]" "$_exp" "$_out"
}

# single number via stdin, default dict
assert_stdin "42
" "forty-two"

# the subject's own worked example: two lines, one per number, in order
assert_stdin "42
0
" "forty-two
zero"

# explicit dict path still works with "-" as the number arg
assert_stdin "numbers.dict" "5
" "five"

# an invalid line among otherwise-valid ones: must not silently skip it or
# crash the whole stream -- exact behavior (abort vs. per-line Error) is the
# implementer's call, so this only asserts SOMETHING sane happens, not a
# specific line-level contract; tighten once the bonus defines it.
_stdin_bad_file="$_WORK_DIR/stdin_bad.txt"
printf '42\nabc\n7\n' >"$_stdin_bad_file"
_out=$(cd "$ROOT_DIR" && timeout "${RUN_TIMEOUT:-5}" "$BIN" - <"$_stdin_bad_file" 2>&1)
_st=$?
if [ "$_st" -eq 124 ]; then
	no "stdin: invalid line among valid ones doesn't hang" "timed out (possible infinite loop)"
else
	ok "stdin: invalid line among valid ones doesn't hang (exit $_st, output: [$_out])"
fi

# --- memory: reading from stdin loops (parse the dict once, then
# allocate/convert/free per line), so a leak that only happens on the 2nd+
# iteration -- e.g. re-parsing the dict every line without freeing the
# previous one, or not freeing a per-line number buffer -- needs MULTIPLE
# lines to surface. A single-line run alone would miss that class of bug.
# assert_no_leaks_stdin doesn't cd on its own (same contract as
# assert_no_leaks), and rush-02's default dict path is relative to
# ROOT_DIR, so each call below runs inside a `cd "$ROOT_DIR" && ...` subshell.
_leak_stdin_single="$_WORK_DIR/leak_stdin_single.txt"
printf '42\n' >"$_leak_stdin_single"
(cd "$ROOT_DIR" && assert_no_leaks_stdin "no leaks: stdin, single line" "$BIN" "$_leak_stdin_single" -)

_leak_stdin_multi="$_WORK_DIR/leak_stdin_multi.txt"
printf '42\n0\n999\n7\n123456789\n' >"$_leak_stdin_multi"
(cd "$ROOT_DIR" && assert_no_leaks_stdin "no leaks: stdin, multiple lines (per-iteration leak check)" \
	"$BIN" "$_leak_stdin_multi" -)

# an invalid line mid-stream must not leak whatever was partially allocated
# for that line before validation rejected it.
_leak_stdin_bad="$_WORK_DIR/leak_stdin_bad.txt"
printf '42\nabc\n7\n' >"$_leak_stdin_bad"
(cd "$ROOT_DIR" && assert_no_leaks_stdin "no leaks: stdin, invalid line mid-stream" "$BIN" "$_leak_stdin_bad" -)

# explicit dict path + "-": the dict itself must still be freed exactly
# once at the end, not once per line and not leaked.
_leak_stdin_dict="$_WORK_DIR/leak_stdin_dict.txt"
printf '5\n10\n100\n' >"$_leak_stdin_dict"
(cd "$ROOT_DIR" && assert_no_leaks_stdin "no leaks: stdin with explicit dict path" \
	"$BIN" "$_leak_stdin_dict" numbers.dict -)

report
