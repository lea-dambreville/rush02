#ifndef RUSH02_H
# define RUSH02_H

# define DEFAULT_DICT "numbers.dict"
# define ERROR "Error\n"
# define DICT_ERROR "Dict Error\n"
# define SUCCESS_EXIT 0
# define FAILURE_EXIT 1

# include "ft_dict.h"

int			is_valid_number(char *str);
char		*trim_leading_zeros(char *str);
int			convert_number(char *str, t_dict_list *dict);
t_dict_list	*parse_dictionary(char *path);

#endif
