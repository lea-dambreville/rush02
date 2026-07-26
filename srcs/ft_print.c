/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mran <mran@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 17:11:05 by mran              #+#    #+#             */
/*   Updated: 2026/07/26 17:14:19 by mran             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_print.h"
#include "ft_string.h"
#include "rush02.h"
#include <unistd.h>

void	ft_println(t_print_buf *buf, int fd)
{
	ft_append_buf(buf, "\n", fd);
	ft_flush(buf, fd);
}

void	ft_flush(t_print_buf *buf, int fd)
{
	write(fd, buf->buf, buf->size);
	buf->size = 0;
}

void	ft_append_buf(t_print_buf *buf, char *str, int fd)
{
	int	len;

	len = ft_strlen(str);
	if (buf->size + len > BUF_SIZE)
		ft_flush(buf, fd);
	if (len > BUF_SIZE)
		write(fd, str, len);
	else
	{
		ft_strpcpy((buf->buf + buf->size), str);
		buf->size = buf->size + len;
	}
}

void	ft_putchar(char c, int fd)
{
	write(fd, &c, 1);
}

void	ft_putstr(char *str, int fd)
{
	int	i;

	i = 0;
	while (str[i] != '\0')
	{
		ft_putchar(str[i], fd);
		i++;
	}
}

// void	print_word(char *word, int *is_first)
// {
// 	if (word == NULL)
// 	{
// 		return ;
// 	}
// 	if (!(*is_first))
// 		ft_putchar(' ');
// 	ft_putstr(word);
// 	*is_first = 0;
// }
