/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_math.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 10:35:05 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 11:10:14 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_string.h"

int	ft_min(int a, int b)
{
	if (a < b)
		return (a);
	return (b);
}

int	ft_antoi(char *str, int n)
{
	int	i;
	int	ret;

	i = 0;
	ret = 0;
	while (is_number(*str) && i < n)
	{
		ret = (ret * 10) - (*str - '0');
		str++;
		i++;
	}
	return (ret * -1);
}
