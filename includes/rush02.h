#ifndef RUSH02_H
# define RUSH02_H

# include <fcntl.h>
# include <stdlib.h>
# include <unistd.h>

typedef struct s_dict
{
	char	*key;
	char	*val;
}			t_dict;

typedef struct s_dict_list
{
	t_dict	*entries;
	int		size;
}			t_dict_list;

int         ft_strlen(char *str);
int         ft_strcmp(char *s1, char *s2);
char       *ft_strdup(char *src);
char       *ft_strndup(char *src, int n);
char	*trim_spaces(char *str, int start, int end);

void    print_word(char *word, int *is_first);
void    ft_putstr(char *str);
void    ft_putchar(char c);

t_dict_list	*parse_dictionary(char *path);
char		*dict_lookup(t_dict_list *dict, char *key);
void		free_dict(t_dict_list *dict);

int			is_valid_number(char *str);
char		*trim_leading_zeros(char *str);

int	convert_number(char *str, t_dict_list *dict);

#endif