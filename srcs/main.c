#include "rush02.h"

static int	print_error(char *msg)
{
	ft_putstr(msg);
	return (1);
}

static void	cleanup_dict(t_dict_list *dict)
{
	if (dict != NULL)
		free_dict(dict);
}

int	main(int argc, char **argv)
{
	char *dict_path;
	char *num_str;
	t_dict_list *dict;

	dict_path = "numbers.dict";
	if (argc == 2)
		num_str = argv[1];
	else if (argc == 3)
	{
		dict_path = argv[1];
		num_str = argv[2];
	}
	else
		return (print_error("Error\n"));
	if (!(is_valid_number(num_str)))
		return (print_error("Error\n"));
	dict = parse_dictionary(dict_path);
	if (!(dict))
		return (print_error("Dict Error\n"));
	if (!(convert_number(num_str, dict)))
	{
		cleaning_dict(dict);
		return (print_error("Dict Error\n"));
	}
	cleanup_dict(dict);
	return (0);
}