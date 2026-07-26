/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_dict.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mran <mran@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 17:09:05 by mran              #+#    #+#             */
/*   Updated: 2026/07/26 20:35:33 by mran             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "rush02.h"
#include "ft_dict.h"
#include "ft_string.h"
#include "ft_read_line.h"
#include "ft_print.h"
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

static int	print_error(char *msg)
{
	ft_putstr(msg, STDERR);
	return (1);
}

static t_dict	parse_line(char *line)
{
	t_dict	entry;
	int		colon_idx;
	int		len;

	colon_idx = ft_strchr(line, ':');
	if (colon_idx == -1)
	{
		entry.key = NULL;
		entry.val = NULL;
	}
	else
	{
		len = ft_strlen(line);
		entry.key = trim_spaces(line, 0, colon_idx);
		entry.val = trim_spaces(line, colon_idx + 1, len);
		if (!entry.key || !entry.val)
		{
			free(entry.key);
			free(entry.val);
		}
	}
	return (entry);
}

static int	parse_dict_data(int fd, t_dict_list *dict)
{
	t_dict	entry;
	char	*line;
	int		is_success;

	while (1)
	{
		line = ft_read_line(fd, &is_success);
		if (!is_success)
			return (0);
		else if (!line)
			break ;
		if (line[0] == '\0')
		{
			free(line);
			continue ;
		}
		entry = parse_line(line);
		free(line);
		if (entry.key == NULL || entry.val == NULL)
			return (print_error(DICT_ERROR));
		if ((dict->size == dict->capacity) && !realloc_dict(dict))
			return (0);
		append_entry(dict, &entry);
	}
	return (1);
}

t_dict_list	*parse_dictionary(char *path)
{
	int			fd;
	t_dict_list	*dict;

	dict = malloc(sizeof(t_dict_list) * 1);
	if (!dict)
		return (NULL);
	dict->capacity = DEFAULT_ENTRIES_SIZE;
	dict->size = 0;
	dict->entries = malloc(sizeof(t_dict) * DEFAULT_ENTRIES_SIZE);
	if (!dict->entries)
		return (free_dict(dict));
	fd = open(path, O_RDONLY);
	if (fd < 0)
		return (free_dict(dict));
	if (!parse_dict_data(fd, dict))
	{
		close(fd);
		return (free_dict(dict));
	}
	close(fd);
	return (dict);
}
// t_dict_list	*parse_dictionary(char *path)
// {
// 	char		*buf;
// 	char		*line;
// 	t_dict_list	*dict;
// 	int			i;
// 	int			j;

// 	buf = read_file_to_buffer(path);
// 	if (!buf)
// 		return (NULL);
// 	dict = (t_dict_list *)malloc(sizeof(t_dict_list));
// 	if (!dict)
// 	{
// 		free(buf);
// 		return (NULL);
// 	}
// 	dict->entries = (t_dict *)malloc(sizeof(t_dict) * 100);
// 	dict->size = 0;
// 	i = 0;
// 	while (buf[i])
// 	{
// 		j = i;
// 		while (buf[j] && buf[j] != '\n')
// 			j++;
// 		if (j > i)
// 		{
// 			line = ft_strndup(buf + i, j - i);
// 			if (line && parse_line(line, &dict->entries[dict->size]))
// 				dict->size++;
// 			if (line)
// 				free(line);
// 		}
// 		i = (buf[j] == '\n') ? j + 1 : j;
// 	}
// 	free(buf);
// 	return (dict);
// }
//
