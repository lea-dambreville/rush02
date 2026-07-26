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

void    ft_println(t_print_buf *buf, int fd);
void    ft_flush(t_print_buf *buf, int fd);
void    ft_append_buf(t_print_buf *buf, char *str, int fd);
void	ft_putchar(char c, int fd);
void	ft_putstr(char *str, int fd);

#endif