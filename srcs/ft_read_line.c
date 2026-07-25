/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_read_line.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/25 22:35:50 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 01:23:46 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>
#include <stdlib.h>
#include "ft_string.h"
#include "ft_read_line.h"

static char	*init_lines_str(void)
{
	char	*lines_str;

	lines_str = malloc(sizeof(char) * 1);
	if (!lines_str)
		return (NULL);
	lines_str[0] = '\0';
	return (lines_str);
}

static char	*error_read_line(char **lines_str, int *is_success)
{
	*is_success = 0;
	if (lines_str)
	{
		free(*lines_str);
		*lines_str = NULL;
	}
	return (NULL);
}

static char	*read_file(int fd, char *lines_str, int *nl_pos)
{
	int		byte_read;
	char	*tmp;
	char	read_buf[BUF_SIZE];

	byte_read = 1;
	while (byte_read > 0)
	{
		byte_read = read(fd, read_buf, BUF_SIZE);
		if (byte_read < 0)
		{
			free(lines_str);
			return (NULL);
		}
		tmp = lines_str;
		lines_str = ft_strnjoin(lines_str, read_buf, byte_read);
		free(tmp);
		if (!lines_str)
			return (NULL);
		*nl_pos = ft_strchr(lines_str, '\n');
		if (*nl_pos >= 0)
			return (lines_str);
	}
	*nl_pos = ft_strlen(lines_str);
	return (lines_str);
}

static char	*get_line(char **lines_str, int pos)
{
	char	*tmp;
	char	*line;

	tmp = *lines_str;
	if ((*lines_str)[pos] == '\n')
	{
		line = ft_strndup(*lines_str, pos);
		*lines_str = ft_strdup(*lines_str + pos + 1);
	}
	else
	{
		line = ft_strdup(*lines_str);
		*lines_str = NULL;
	}
	free(tmp);
	return (line);
}

// Readline from given fd.
// Return freeable line that read from fd (char *)
// Return NULL in error cases
// static variables -> persist over the program lifetime.
char	*ft_read_line(int fd, int *is_success)
{
	int			nl_pos;
	char		*line;
	static char	*lines_str;

	*is_success = 1;
	if (lines_str == NULL)
	{
		lines_str = init_lines_str();
		if (!lines_str)
			return (error_read_line(&lines_str, is_success));
	}
	lines_str = read_file(fd, lines_str, &nl_pos);
	if (!lines_str)
		return (error_read_line(NULL, is_success));
	if (nl_pos == 0 && lines_str[0] == '\0')
	{
		free(lines_str);
		lines_str = NULL;
		return (NULL);
	}
	line = get_line(&lines_str, nl_pos);
	if (!line)
		return (error_read_line(&lines_str, is_success));
	return (line);
}
