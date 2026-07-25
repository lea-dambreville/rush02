#include "rush02.h"

char	*trim_spaces(char *str, int start, int end)
{
	if (str == NULL)
		return (NULL);
	while (start < end && (str[start] == ' ' || (str[start] >= 9
				&& str[start] <= 13)))
		start++;
	while (end > start && (str[end - 1] == ' ' || (str[end - 1] >= 9
				&& str[end - 1] <= 13)))
		end--;
	if (start >= end)
		return (NULL);
	return (ft_strndup(str + start, end - start));
}

int	is_valid_number(char *str)
{
	int	i;

	if (str == NULL || !*str)
		return (0);
	i = 0;
	while (str[i] == ' ' || (str[i] >= 9 && str[i] <= 13))
		i++;
	if (str[i] == '+')
		i++;
	if (!str[i])
		return (0);
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
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