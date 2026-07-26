#include "ft_convert.h"
#include <stdlib.h>

static int convert_tenth(
	t_triplet *triplet,
	t_print_buf *buf,
	int scale,
	t_dict_list *dict
	)
{
	char	key[2];
	char	*word;
	char	*suffix;

	if (triplet->tenth == 0)
		return (1);
	assign_digit_to_key(key, triplet->tenth);
	word = dict_lookup(dict, key);
	if (!word)
		return (0);
	suffix = get_suffix(dict, scale, TENTH_POS);
	if (!suffix)
	{
		suffix = get_suffix(dict, 0, TENTH_POS);
		if (!suffix)
			return (0);
	}
	ft_append_buf(buf, word, STDOUT);
	ft_append_buf(buf, suffix, STDOUT);
	if (triplet->ones > 0)
		append_hyphen(dict, buf);
	return (1);
}

static int convert_ones(
	t_triplet *triplet,
	t_print_buf *buf,
	int scale,
	t_dict_list *dict
	)
{
	char	key[2];
	char	*word;
	char	*suffix;

	if (triplet->ones == 0)
		return (1);
	assign_digit_to_key(key, triplet->ones);
	word = dict_lookup(dict, key);
	if (!word)
		return (0);
	suffix = get_suffix(dict, scale, ONES_POS);
	if (scale != 0 && !word)
		return (0);
	ft_append_buf(buf, word, STDOUT);
	if (suffix && scale != 0)
		ft_append_buf(buf, suffix, STDOUT);
	return (1);
}

static int	convert_unique(
	t_triplet *triplet,
	t_print_buf *buf,
	int scale,
	t_dict_list *dict
	)
{
	char	key[3];
	char	*word;
	char	*suffix;
	assign_unique_to_key(key, triplet->tenth, triplet->ones);
	word = dict_lookup(dict, key);
	if (!word)
		return (0);
	suffix = get_suffix(dict, scale, ONES_POS);
	if (scale != 0 && !suffix)
		return (0);
	ft_append_buf(buf, word, STDOUT);
	if (suffix)
		ft_append_buf(buf, suffix, STDOUT);
	return (1);
}


int	convert_tenth_ones(
	t_triplet *triplet,
	t_print_buf *buf,
	int scale,
	t_dict_list *dict
	)
{
	int		is_unique;

	if (triplet->tenth == 0 && triplet->ones == 0)
		return (1);
	if (triplet->hundredth > 0)
		append_and(dict, buf);
	if (triplet->tenth > 0)
	{
		is_unique = convert_unique(triplet, buf, scale, dict);
		if (triplet->tenth == 1 && !is_unique)
			return (0);
		if (is_unique)
			return (1);
	}
	if (!convert_tenth(triplet, buf, scale, dict)
		|| !convert_ones(triplet, buf, scale, dict)
		)
		return (0);
	return (1);
}

int	convert_hundredth(
	t_triplet *triplet,
	t_print_buf *buf,
	int scale,
	t_dict_list *dict
	)
{
	char	key[2];
	char	*word;
	char	*suffix;

	if (triplet->hundredth == 0)
		return (1);
	assign_digit_to_key(key, triplet->hundredth);
	word = dict_lookup(dict, key);
	if (!word)
		return (0);
	suffix = get_suffix(dict, scale, HUNDREDTH_POS);
	if (!suffix)
	{
		suffix = get_suffix(dict, 0, HUNDREDTH_POS);
		if (!suffix)
			return (0);
	}
	ft_append_buf(buf, word, STDOUT);
	ft_append_buf(buf, suffix, STDOUT);
	if (triplet->tenth > 0 || triplet->ones > 0)
		append_and(dict, buf);
	return (1);
}
