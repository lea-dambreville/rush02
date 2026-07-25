/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_dict.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 02:33:32 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 03:06:48 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_mem.h"
#include "ft_string.h"
#include "ft_dict.h"
#include <stdlib.h>

char	*dict_lookup(t_dict_list *dict, char *key)
{
	int	i;

	if (!dict || !dict->entries || !key)
		return (NULL);
	i = 0;
	while (i < dict->size)
	{
		if (dict->entries[i].key && ft_strcmp(dict->entries[i].key, key) == 0)
			return (dict->entries[i].val);
		i++;
	}
	return (NULL);
}

void	*free_dict(t_dict_list *dict)
{
	int	i;

	if (!dict)
		return (NULL);
	if (dict->entries)
	{
		i = 0;
		while (i < dict->size)
		{
			if (dict->entries[i].key)
				free(dict->entries[i].key);
			if (dict->entries[i].val)
				free(dict->entries[i].val);
			i++;
		}
		free(dict->entries);
	}
	free(dict);
	return (NULL);
}

void	append_entry(t_dict_list *dict, t_dict *entry)
{
	dict->entries[dict->size].key = entry->key;
	dict->entries[dict->size].val = entry->val;
	dict->size = dict->size + 1;
}

int	realloc_dict(t_dict_list *dict)
{
	dict->entries = ft_realloc(
			dict->entries,
			sizeof(t_dict) * dict->size,
			sizeof(t_dict) * dict->capacity * 2
			);
	if (!dict->entries)
		return (0);
	dict->capacity = dict->capacity * 2;
	return (1);
}
