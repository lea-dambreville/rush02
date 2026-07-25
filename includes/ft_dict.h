/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_dict.h                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 01:44:13 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 03:05:15 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_DICT_H
# define FT_DICT_H

# define DEFAULT_ENTRIES_SIZE 64

typedef struct s_dict
{
	char	*key;
	char	*val;
}	t_dict;

typedef struct s_dict_list
{
	t_dict	*entries;
	int		size;
	int		capacity;
}	t_dict_list;

char		*dict_lookup(t_dict_list *dict, char *key);
void		*free_dict(t_dict_list *dict);
void		append_entry(t_dict_list *dict, t_dict *entry);
int			realloc_dict(t_dict_list *dict);

#endif
