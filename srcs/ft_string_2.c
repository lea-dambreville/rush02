/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_string_2.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 00:45:43 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 03:34:24 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_string.h"
#include <stdlib.h>

char	*ft_strdup(char *src)
{
	int		i;
	int		len;
	char	*dest;

	i = 0;
	len = ft_strlen(src);
	dest = (char *)malloc(sizeof(char) * (len + 1));
	if (dest == NULL)
		return (NULL);
	while (i < len)
	{
		dest[i] = src[i];
		i++;
	}
	dest[i] = '\0';
	return (dest);
}

char	*ft_strndup(char *src, int n)
{
	int		i;
	char	*dest;

	i = 0;
	if (n < 0)
		return (NULL);
	dest = (char *)malloc(sizeof(char) * (n + 1));
	if (dest == NULL)
		return (NULL);
	while (src[i] && i < n)
	{
		dest[i] = src[i];
		i++;
	}
	dest[i] = '\0';
	return (dest);
}

char	*ft_strpcpy(char *dest, char *src)
{
	while (*src)
		*dest++ = *src++;
	return (dest);
}

char	*ft_strnjoin(char *s1, char *s2, int n)
{
	int		i;
	int		size;
	char	*ret;
	char	*cur;

	size = ft_strlen(s1) + n + 1;
	ret = malloc(sizeof(char) * size);
	if (!ret)
		return (NULL);
	cur = ft_strpcpy(ret, s1);
	i = 0;
	while (i < n)
	{
		cur[i] = s2[i];
		i++;
	}
	cur[i] = '\0';
	return (ret);
}

char	*trim_spaces(char *str, int start, int end)
{
	while (start < end && is_space(str[start]))
		start++;
	while (end > start && is_space(str[end - 1]))
		end--;
	if (start >= end)
		return (NULL);
	return (ft_strndup(str + start, end - start));
}
