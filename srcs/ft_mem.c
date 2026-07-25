/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_mem.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 02:56:14 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 03:26:47 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>

void	*ft_memcpy(void *dest, void *src, int n)
{
	int	i;

	i = 0;
	while (i < n)
	{
		*((unsigned char *)dest + i) = *((unsigned char *)src + i);
		i++;
	}
	return (dest);
}

void	*ft_realloc(void *ptr, int old_size, int new_size)
{
	void	*ret;

	ret = malloc(sizeof(unsigned char) * new_size);
	if (!ret)
	{
		free(ptr);
		return (NULL);
	}
	ft_memcpy(ret, ptr, old_size);
	free(ptr);
	return (ret);
}
