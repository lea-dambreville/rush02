/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   convert_3.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mran <mran@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 17:16:01 by mran              #+#    #+#             */
/*   Updated: 2026/07/26 17:16:59 by mran             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_convert.h"
#include <stdlib.h>

void	assign_digit_to_key(char *key, int n)
{
	key[0] = n + '0';
	key[1] = '\0';
}

void	assign_unique_to_key(char *key, int tenth, int ones)
{
	key[0] = tenth + '0';
	key[1] = ones + '0';
	key[2] = '\0';
}

char	*tenth_lookup(t_dict_list *dict, int tenth)
{
	char	key[3];

	assign_unique_to_key(key, tenth, 0);
	return (dict_lookup(dict, key));
}

static char	*get_magnitude_key(int scale_idx, int pos)
{
	char	*key;
	int		zeros;
	int		i;

	zeros = (scale_idx * 3) + pos;
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

char	*get_suffix(t_dict_list *dict, int scale_idx, int pos)
{
	char	*key;
	char	*suffix;

	key = get_magnitude_key(scale_idx, pos);
	if (!key)
		return (NULL);
	suffix = dict_lookup(dict, key);
	free(key);
	return (suffix);
}
