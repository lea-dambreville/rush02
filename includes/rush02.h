#ifndef RUSH02_H
# define RUSH02_H

# include <fcntl.h>
# include <stdlib.h>
# include <unistd.h>
# include "ft_dict.h"

int         ft_strlen(char *str);
int         ft_strcmp(char *s1, char *s2);
char       *ft_strdup(char *src);
char       *ft_strndup(char *src, int n);
char	*trim_spaces(char *str, int start, int end);

void    print_word(char *word, int *is_first);
void    ft_putstr(char *str);
void    ft_putchar(char c);

int			is_valid_number(char *str);
char		*trim_leading_zeros(char *str);

int	convert_number(char *str, t_dict_list *dict);
t_dict_list	*parse_dictionary(char *path);

#endif
