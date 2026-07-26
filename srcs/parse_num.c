/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_num.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mran <mran@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 17:17:35 by mran              #+#    #+#             */
/*   Updated: 2026/07/26 17:17:36 by mran             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_string.h"
#include <stdio.h>

int	is_valid_number(char *str)
{
	int	i;

	i = 0;
	while (is_space(str[i]))
		i++;
	if (str[i] == '+')
		i++;
	while (str[i])
	{
		if (!is_number(str[i]))
			return (0);
		i++;
	}
	return (1);
}

char	*trim_leading_zeros(char *str)
{
	int	i;

	if (str == NULL)
		return (NULL);
	i = 0;
	while (str[i] == ' ' || (str[i] >= 9 && str[i] <= 13))
		i++;
	if (str[i] == '+')
		i++;
	while (str[i] == '0' && str[i + 1] != '\0')
		i++;
	return (ft_strdup(str + i));
}
