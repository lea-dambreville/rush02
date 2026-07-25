#include "rush02.h"

char	*trim_spaces(char *str, int start, int end)
{
	while (start < end && (str[start] == ' ' || (str[start] >= 9
				&& str[start] <= 13)))
		start++;
	while (end > start && (str[end - 1] == ' ' || (str[end - 1] >= 9 && str[end
				- 1] <= 13)))
		end--;
	if (start >= end)
		return (NULL);
	return (ft_strndup(str + start, end - start));
}
