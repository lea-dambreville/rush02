#include "rush02.h"

static char	*get_magnitude_key(int scale_idx)
{
	char	*key;
	int		zeros;
	int		i;

	zeros = scale_idx * 3;
	key = (char *)malloc(sizeof(char) * (zeros + 2));
	if (!key)
		return (NULL);
	key[0] = '1';
	i = 1;
	while (i <= zeros)
	{
		key[i] = '0';
		i++;
	}
	key[i] = '\0';
	return (key);
}

static int	convert_triplet(int num, t_dict_list *dict, int *is_first)
{
	char	key[4];
	char	*word;

	if (num >= 100)
	{
		key[0] = (num / 100) + '0';
		key[1] = '\0';
		if (!(word = dict_lookup(dict, key)) || !(dict_lookup(dict, "100")))
			return (0);
		print_word(word, is_first);
		print_word(dict_lookup(dict, "100"), is_first);
		num %= 100;
	}
	if (num >= 20)
	{
		key[0] = ((num / 10) * 10 / 10) + '0';
		key[1] = '0';
		key[2] = '\0';
		if (!(word = dict_lookup(dict, key)))
			return (0);
		print_word(word, is_first);
		num %= 10;
	}
	if (num > 0)
	{
		key[0] = num + '0';
		key[1] = '\0';
		if (!(word = dict_lookup(dict, key)))
			return (0);
		print_word(word, is_first);
	}
	return (1);
}

static int	process_group(int num, int scale_idx, t_dict_list *dict, int *is_first)
{
	char	*mag_key;
	char	*mag_word;

	if (num == 0)
		return (1);
	if (!convert_triplet(num, dict, is_first))
		return (0);
	if (scale_idx > 0)
	{
		mag_key = get_magnitude_key(scale_idx);
		if (!mag_key)
			return (0);
		mag_word = dict_lookup(dict, mag_key);
		free(mag_key);
		if (!mag_word)
			return (0);
		print_word(mag_word, is_first);
	}
	return (1);
}

static int	parse_sub_group(char *str, int end_idx)
{
	int	num;
	int	start_idx;

	start_idx = end_idx - 3;
	if (start_idx < 0)
		start_idx = 0;
	num = 0;
	while (start_idx < end_idx)
	{
		num = num * 10 + (str[start_idx] - '0');
		start_idx++;
	}
	return (num);
}

int	convert_number(char *str, t_dict_list *dict)
{
	int	len;
	int	scale_idx;
	int	is_first;
	int	num;

	if (ft_strcmp(str, "0") == 0)
	{
		if (!dict_lookup(dict, "0"))
			return (0);
		ft_putstr(dict_lookup(dict, "0"));
		ft_putchar('\n');
		return (1);
	}
	len = ft_strlen(str);
	scale_idx = (len - 1) / 3;
	is_first = 1;
	while (scale_idx >= 0)
	{
		num = parse_sub_group(str, len - (scale_idx * 3));
		if (!process_group(num, scale_idx, dict, &is_first))
			return (0);
		scale_idx--;
	}
	ft_putchar('\n');
	return (1);
}
