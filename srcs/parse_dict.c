#include "rush02.h"

static char	*read_file_to_buffer(char *path)
{
	int		fd;
	int		bytes;
	char	tmp[4096];
	char	*buf;

	fd = open(path, O_RDONLY);
	if (fd < 0)
		return (NULL);
	bytes = read(fd, tmp, 4095);
	close(fd);
	if (bytes <= 0)
		return (NULL);
	tmp[bytes] = '\0';
	buf = ft_strdup(tmp);
	return (buf);
}

static char	*trim_spaces(char *str, int start, int end)
{
	while (start < end && (str[start] == ' ' || (str[start] >= 9
				&& str[start] <= 13)))
		start++;
	while (end > start && (str[end - 1] == ' ' || (str[end - 1] >= 9 && str[end
				- 1] <= 13)))
		end--;
	if (start >= end)
		return (NULL);
	return (ft_strndup(str + start, end - start));
}

static int	parse_line(char *line, t_dict *entry)
{
	int	colon_idx;
	int	len;

	colon_idx = 0;
	while (line[colon_idx] && line[colon_idx] != ':')
	{
		colon_idx++;
	}
	if (!line[colon_idx])
	{
		return (0);
	}
	len = ft_strlen(line);
	entry->key = trim_spaces(line, 0, colon_idx);
	entry->val = trim_spaces(line, colon_idx + 1, len);
	if (!entry->key || !entry->val)
	{
		if (entry->key)
			free(entry->key);
		if (entry->val)
			free(entry->val);
		return (0);
	}
	return (1);
}

void	free_dict(t_dict_list *dict)
{
	int	i;

	if (!dict)
		return ;
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
}

t_dict_list	*parse_dictionary(char *path)
{
	char		*buf;
	t_dict_list	*dict;
	int			i;
	int			j;
	char		*line;

	buf = read_file_to_buffer(path);
	if (!buf)
		return (NULL);
	dict = (t_dict_list *)malloc(sizeof(t_dict_list));
	if (!dict)
	{
		free(buf);
		return (NULL);
	}
	dict->entries = (t_dict *)malloc(sizeof(t_dict) * 100);
	dict->size = 0;
	i = 0;
	while (buf[i])
	{
		j = i;
		while (buf[j] && buf[j] != '\n')
			j++;
		if (j > i)
		{
			line = ft_strndup(buf + i, j - i);
			if (line && parse_line(line, &dict->entries[dict->size]))
				dict->size++;
			if (line)
				free(line);
		}
		i = (buf[j] == '\n') ? j + 1 : j;
	}
	free(buf);
	return (dict);
}
