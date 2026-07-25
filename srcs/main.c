#include "ft_dict.h"
#include "rush02.h"

static int	print_error(char *msg)
{
	ft_putstr(msg);
	return (1);
}

static void	cleanup_dict(t_dict_list *dict)
{
	if (dict)
		free_dict(dict);
}

int	main(int argc, char **argv)
{
	char *dict_path;
	char *num_str;
	t_dict_list *dict;

	dict_path = DEFAULT_DICT;
	if (argc == 2)
		num_str = argv[1];
	else if (argc == 3)
	{
		dict_path = argv[1];
		num_str = argv[2];
	}
	else
		return (print_error(ERROR));
	if (!(is_valid_number(num_str)))
		return (print_error(ERROR));
	dict = parse_dictionary(dict_path);
	if (!(dict))
		return (print_error(DICT_ERROR));
	if (!(convert_number(num_str, dict)))
	{
		cleanup_dict(dict);
		return (print_error(DICT_ERROR));
	}
	cleanup_dict(dict);
	return (0);
}
