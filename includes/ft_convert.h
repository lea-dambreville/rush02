/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_convert.h                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 10:21:25 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 11:10:42 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_CONVERT_H
# define FT_CONVERT_H

# define CONV_BUF_SIZE	4096

typedef struct	s_conv_ctx
{
	int		to_conv;
	int		scale;
}	t_conv_ctx;

typedef struct s_conv_buf
{
	char	buf[CONV_BUF_SIZE];
	int		size;
}	t_conv_buf;

#endif
