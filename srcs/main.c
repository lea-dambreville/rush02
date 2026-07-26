#include "ft_dict.h"
#include "ft_read_line.h"
#include "ft_string.h"
#include "ft_print.h"
#include "rush02.h"
#include <stdlib.h>

static int	print_error(char *msg)
{
	ft_putstr(msg, STDERR);
	return (1);
}

// static void	cleanup_dict(t_dict_list *dict)
// {
// 	if (dict)
// 		free_dict(dict);
// }

static int	assign_args(int argc, char **argv, char	**num_str, char **dict_path)
{
	if (argc == 2)
	{
		*dict_path = DEFAULT_DICT;
		*num_str = argv[1];
		return (1);
	}
	else if (argc == 3)
	{
		*dict_path = argv[1];
		*num_str = argv[2];
		return (1);
	}
	else
		return (0);
}

static int	validate_and_conv(char *num_str, t_dict_list *dict)
{
	char	*tmp;

	if (!(is_valid_number(num_str)))
	{
		print_error(ERROR);
		return (0);
	}
	num_str = trim_spaces(num_str, 0, ft_strlen(num_str));
	tmp = num_str;
	num_str = trim_leading_zeros(num_str);
	free(tmp);
	if (!num_str)
	{
		print_error(ERROR);
		return (0);
	}
	if (!(convert_number(num_str, dict)))
	{
		print_error(DICT_ERROR);
		return (0);
	}
	return (1);
}

static void	run_stdin_convert(t_dict_list *dict)
{
	int		is_success;
	char	*line;

	while (1)
	{
		line = ft_read_line(0, &is_success);
		if (!line || !is_success)
		{
			free(line);
			return ;
		}
		if (line[0] == '\0')
		{
			free(line);
			continue ;
		}
		validate_and_conv(line, dict);
		free(line);
	}
}

int	main(int argc, char **argv)
{
	char		*dict_path;
	char		*num_str;
	t_dict_list	*dict;

	if (!assign_args(argc, argv, &num_str, &dict_path))
		return (print_error(ERROR));
	dict = parse_dictionary(dict_path);
	if (!(dict))
		return (print_error(DICT_ERROR));
	if (ft_strcmp(num_str, "-") == 0)
		run_stdin_convert(dict);
	else
	{
		if (!validate_and_conv(num_str, dict))
		{
			free_dict(dict);
			return (FAILURE_EXIT);
		}
	}
	free_dict(dict);
	return (SUCCESS_EXIT);
}
