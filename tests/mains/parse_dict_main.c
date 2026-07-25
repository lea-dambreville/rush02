#include <stdio.h>
#include "ft_dict.h"
#include "rush02.h"

/*
 * Drives parse_dictionary/dict_lookup/free_dict against argv[1] (a dict
 * file path) and argv[2..] (a list of keys to look up, in order), so the
 * shell test can assert on exact framing:
 *
 *   argv[1] fails to parse -> prints "PARSE_FAIL", exit 1
 *   argv[1] parses         -> prints "SIZE <dict->size>", then one
 *                              "KEY <key> -> <val|NULL>" line per requested
 *                              key, then exits 0
 *
 * free_dict is called before exit either way, so this binary run under
 * valgrind also doubles as a leak check for parse_dictionary's own bookkeeping.
 */
int	main(int argc, char **argv)
{
	t_dict_list	*dict;
	char		*val;
	int			i;

	if (argc < 2)
		return (1);
	dict = parse_dictionary(argv[1]);
	if (!dict)
	{
		printf("PARSE_FAIL\n");
		return (1);
	}
	printf("SIZE %d\n", dict->size);
	i = 2;
	while (i < argc)
	{
		val = dict_lookup(dict, argv[i]);
		if (val)
			printf("KEY %s -> %s\n", argv[i], val);
		else
			printf("KEY %s -> NULL\n", argv[i]);
		i++;
	}
	free_dict(dict);
	return (0);
}
