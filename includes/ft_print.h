/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print.h                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: mran <mran@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 18:28:05 by mran              #+#    #+#             */
/*   Updated: 2026/07/26 18:28:06 by mran             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_PRINT_H
# define FT_PRINT_H

# define STDOUT 1
# define STDERR 2
# define BUF_SIZE 4096

typedef struct s_print_buf
{
	char	buf[BUF_SIZE];
	int		size;
}	t_print_buf;

void	ft_println(t_print_buf *buf, int fd);
void	ft_flush(t_print_buf *buf, int fd);
void	ft_append_buf(t_print_buf *buf, char *str, int fd);
void	ft_putchar(char c, int fd);
void	ft_putstr(char *str, int fd);

#endif