#ifndef RUSH02_H
# define RUSH02_H

# define DEFAULT_DICT "numbers.dict"
# define ERROR "Error\n"
# define DICT_ERROR "Dict Error\n"

# include "ft_dict.h"

void		print_word(char *word, int *is_first);
void		ft_putstr(char *str);
void		ft_putchar(char c);
int			is_valid_number(char *str);
char		*trim_leading_zeros(char *str);
int			convert_number(char *str, t_dict_list *dict);
t_dict_list	*parse_dictionary(char *path);

#endif
