#include "ft_convert.h"

void	append_comma(t_dict_list *dict, t_print_buf *buf)
{
	char	*word;

	word = dict_lookup(dict, ",");
	if (!word)
		word = DEFAULT_COMMA;
	ft_append_buf(buf, word, STDOUT);
	ft_append_buf(buf, " ", STDOUT);
}

void	append_and(t_dict_list *dict, t_print_buf *buf)
{
	char	*word;

	word = dict_lookup(dict, "and");
	if (!word)
		word = DEFAULT_AND;
	ft_append_buf(buf, " ", STDOUT);
	ft_append_buf(buf, word, STDOUT);
	ft_append_buf(buf, " ", STDOUT);
}

void	append_hyphen(t_dict_list *dict, t_print_buf *buf)
{
	char	*word;

	word = dict_lookup(dict, "-");
	if (!word)
		word = DEFAULT_HYPHEN;
	ft_append_buf(buf, word, STDOUT);
}