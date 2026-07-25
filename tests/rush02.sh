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
		_out=$(cd "$ROOT_DIR" && "$BIN" "$_dict" "$_n" 2>/dev/null)
	else
		_out=$(cd "$ROOT_DIR" && "$BIN" "$_n" 2>/dev/null)
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
assert_conv "21" "twenty one"
assert_conv "29" "twenty nine"
assert_conv "99" "ninety nine"

# --- hundreds, including a teen remainder (tests hundred+teen composition,
# not hundred + tens-digit + units-digit) ---
assert_conv "100" "one hundred"
assert_conv "101" "one hundred one"
assert_conv "110" "one hundred ten"
assert_conv "119" "one hundred nineteen"
assert_conv "999" "nine hundred ninety nine"

# --- thousands: exact scale word, scale + remainder, zero-group skipping ---
assert_conv "1000" "one thousand"
assert_conv "1001" "one thousand one"
assert_conv "1020" "one thousand twenty"
assert_conv "2000" "two thousand"
assert_conv "10000" "ten thousand"
assert_conv "100000" "one hundred thousand"
assert_conv "100100" "one hundred thousand one hundred"

# --- million+: chunk-of-3 alignment must hold past the first scale jump ---
assert_conv "1000000" "one million"
assert_conv "123456789" \
	"one hundred twenty three million four hundred fifty six thousand seven hundred eighty nine"

# --- middle group is zero: scale word for that group must be skipped, not
# print a bare/duplicate magnitude word ---
assert_conv "1000001" "one million one"
assert_conv "2000000001" "two billion one"

# --- INT_MAX boundary (subject scope: only 32-bit-int-representable inputs) ---
assert_conv "2147483647" \
	"two billion one hundred forty seven million four hundred eighty three thousand six hundred forty seven"

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
	assert_eq "no args -> \"Error\"" "Error" "$_out"
fi

# argc == 4 (too many args)
_out=$(cd "$ROOT_DIR" && "$BIN" numbers.dict 1 extra 2>/dev/null); _st=$?
if [ "$_st" -eq 0 ]; then
	no "4 args -> \"Error\" (exit 1)" "expected nonzero exit, got 0"
else
	assert_eq "4 args -> \"Error\"" "Error" "$_out"
fi

# --- dictionary errors: missing file, and a number the given dict can't
# represent (subject: "does not allow you to perform the conversion") ---
assert_err "5" "Dict Error" "no_such_file.dict"

_out=$(cd "$ROOT_DIR" && "$BIN" numbers.dict/ 5 2>/dev/null); _st=$?
if [ "$_st" -eq 0 ]; then
	no "dict path is a directory -> \"Dict Error\" (exit 1)" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "dict path is a directory -> \"Dict Error\"" "Dict Error" "$_out"
fi

# A minimal dict missing "hundred" can represent 1-99 but must fail on 100.
_tiny_dict="$_WORK_DIR/tiny.dict"
i=0
{
	while [ "$i" -le 20 ]; do
		printf '%s: w%s\n' "$i" "$i"
		i=$((i + 1))
	done
	printf '30: w30\n90: w90\n'
} >"$_tiny_dict"
_out=$(cd "$ROOT_DIR" && "$BIN" "$_tiny_dict" 100 2>/dev/null); _st=$?
if [ "$_st" -eq 0 ]; then
	no "dict without \"hundred\" entry, input 100 -> \"Dict Error\"" "expected nonzero exit, got 0" "output: [$_out]"
else
	assert_eq "dict without \"hundred\" entry, input 100 -> \"Dict Error\"" "Dict Error" "$_out"
fi

report
