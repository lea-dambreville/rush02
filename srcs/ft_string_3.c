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

int	is_printable(char *str)
{
	while (*str)
	{
		if (*str < 32 || *str == 127)
			return (0);
		str++;
	}
	return (1);
}

int	is_numeric(char *str)
{
	while (*str)
	{
		if (*str < '0' || *str > '9')
			return (0);
		str++;
	}
	return (1);
}
