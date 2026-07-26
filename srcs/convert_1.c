#include "rush02.h"
#include "ft_math.h"
#include "ft_convert.h"
#include "ft_string.h"
#include <stdlib.h>

static int	convert_triplet(
	int num,
	int scale,
	t_dict_list	*dict,
	t_print_buf	*buf
)
{
	char		*word;
	t_triplet	triplet;

	if (num == 0)
	{
		word = dict_lookup(dict, "0");
		if (!word)
			return (0);
		ft_append_buf(buf, word, STDOUT);
		return (1);
	}
	triplet.hundredth = num / 100;
	triplet.tenth = (num % 100) / 10;
	triplet.ones = num % 10;
	if (!convert_hundredth(&triplet, buf, scale, dict))
		return (0);
	if (!convert_tenth_ones(&triplet, buf, scale, dict))
		return (0);
	return (1);
}

static int	process_group(
	t_conv_ctx	*ctx,
	t_print_buf *buf,
	t_dict_list *dict,
	int *is_first
)
{
	char	*suffix;

	if (ctx->to_conv == 0 && (!*is_first || ctx->scale !=0))
		return (1);
	if (!*is_first)
		append_comma(dict, buf);
	if (!convert_triplet(ctx->to_conv, ctx->scale, dict, buf))
		return (0);
	if (ctx->scale != 0)
	{
		suffix = get_suffix(dict, ctx->scale, ONES_POS);
		if (!suffix)
			return (0);
		ft_append_buf(buf, " ", STDOUT);
		ft_append_buf(buf, suffix, STDOUT);
	}
	*is_first = 0;
	return (1);
}

int	convert_number(char *str, t_dict_list *dict)
{
	int			len;
	int			size;
	t_conv_ctx	ctx;
	t_print_buf	buf;
	int			is_first;

	len = ft_strlen(str);
	buf.size = 0;
	ctx.scale = (len - 1) / 3;
	is_first = 1;
	while (ctx.scale >= 0)
	{
		size = ft_min(3, len - (ctx.scale * 3));
		ctx.to_conv = ft_antoi(str, size);
		if (!process_group(&ctx, &buf, dict, &is_first))
			return (0);
		str = str + size;
		ctx.scale--;
	}
	ft_append_buf(&buf, "\n", STDOUT);
	ft_flush(&buf, STDOUT);
	return (1);
}

// static int	convert_triplet(int num, t_dict_list *dict, int *is_first)
// {
// 	char	key[4];
// 	char	*word;

// 	if (num >= 100)
// 	{
// 		key[0] = (num / 100) + '0';
// 		key[1] = '\0';
// 		if (!(word = dict_lookup(dict, key)) || !(dict_lookup(dict, "100")))
// 			return (0);
// 		print_word(word, is_first);
// 		print_word(dict_lookup(dict, "100"), is_first);
// 		num %= 100;
// 	}
// 	if (num >= 20)
// 	{
// 		key[0] = ((num / 10) * 10 / 10) + '0';
// 		key[1] = '0';
// 		key[2] = '\0';
// 		if (!(word = dict_lookup(dict, key)))
// 			return (0);
// 		print_word(word, is_first);
// 		num %= 10;
// 	}
// 	if (num > 0)
// 	{
// 		key[0] = num + '0';
// 		key[1] = '\0';
// 		if (!(word = dict_lookup(dict, key)))
// 			return (0);
// 		print_word(word, is_first);
// 	}
// 	return (1);
// }

// static int	process_group(int num,
//	int scale_idx, t_dict_list *dict, int *is_first)
// {
// 	char	*mag_key;
// 	char	*mag_word;

// 	if (num == 0)
// 		return (1);
// 	if (!convert_triplet(num, dict, is_first))
// 		return (0);
// 	if (scale_idx > 0)
// 	{
// 		mag_key = get_magnitude_key(scale_idx);
// 		if (!mag_key)
// 			return (0);
// 		mag_word = dict_lookup(dict, mag_key);
// 		free(mag_key);
// 		if (!mag_word)
// 			return (0);
// 		print_word(mag_word, is_first);
// 	}
// 	return (1);
// }

// static int	parse_sub_group(char *str, int end_idx)
// {
// 	int	num;
// 	int	start_idx;

// 	start_idx = end_idx - 3;
// 	if (start_idx < 0)
// 		start_idx = 0;
// 	num = 0;
// 	while (start_idx < end_idx)
// 	{
// 		num = num * 10 + (str[start_idx] - '0');
// 		start_idx++;
// 	}
// 	return (num);
// }

// int	convert_number(char *str, t_dict_list *dict)
// {
// 	int	len;
// 	int	scale_idx;
// 	int	is_first;
// 	int	num;

// 	if (ft_strcmp(str, "0") == 0)
// 	{
// 		if (!dict_lookup(dict, "0"))
// 			return (0);
// 		ft_putstr(dict_lookup(dict, "0"));
// 		ft_putchar('\n');
// 		return (1);
// 	}
// 	len = ft_strlen(str);
// 	scale_idx = (len - 1) / 3;
// 	is_first = 1;
// 	while (scale_idx >= 0)
// 	{
// 		num = parse_sub_group(str, len - (scale_idx * 3));
// 		if (!process_group(num, scale_idx, dict, &is_first))
// 			return (0);
// 		scale_idx--;
// 	}
// 	ft_putchar('\n');
// 	return (1);
// }
