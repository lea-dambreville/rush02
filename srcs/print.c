#include "rush02.h"

void	ft_putchar(char c)
{
	write(1, &c, 1);
}

void	ft_putstr(char *str)
{
	int	i;

	i = 0;
	if (str[i] == '\0')
	{
		return ;
	}
	while (str[i] != '\0')
	{
		ft_putchar(str[i]);
		i++;
	}
}

void	print_word(char *word, int *is_first)
{
	if (word == NULL)
	{
		return ;
	}
	if (!(*is_first))
		ft_putchar(' ');
	ft_pustr(word);
	*is_first = 0;
}