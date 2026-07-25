

#include <rush02.h>

int	ft_strlen(char *str)
{
	int	i;

	i = 0;
	if (str[i] != '\0')
		return (0);
	while (str[i])
	{
		i++;
	}
	return (i);
}

int	ft_strcmp(char *s1, char *s2)
{
	int	i;

	i = 0;
	if (s1 == 0 || s2 == 0)
	{
		return (-1);
	}
	while (s1[i] && s2[i] && s1[i] == s2[i])
		i++;
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

char	*ft_strdup(char *src)
{
	int		i;
	int		len;
	char	*dest;

	i = 0;
	if (src[i] == '\0')
	{
		return (NULL);
	}
	len = ft_strlen(src);
	dest = (char *)malloc(sizeof(char) * (len + 1));
	if (dest == 0)
	{
		return (NULL);
	}
	while (i < len)
	{
		dest[i] = src[i];
		i++;
	}
	dest[i] = '\0';
	return (dest);
}

char	*ft_strndup(char *src, int n)
{
	int		i;
	char	*dest;

	i = 0;
	if (src[i] == '\0' || n < 0)
	{
		return (NULL);
	}
	dest = (char *)malloc(sizeof(char) * (n + 1));
	if (dest == 0)
	{
		return (NULL);
	}
	while (src[i] && i < n)
	{
		dest[i] = src[i];
		i++;
	}
	dest[i] = '\0';
	return (dest);
}

int	ft_atoi(char *str)
{
	int i;
	int res;

	i = 0;
	res = 0;
	if (str[i] == '\0')
	{
		return (0);
	}
	while (str[i] == ' ' || (str[i] >= 9 && str[i] <= 13))
	{
		i++;
	}
	if (str[i] == '+')
	{
		i++;
	}
	while (str[i] >= '0' && str[i] <= '9')
	{
		res = res * 10 + (str[i] - '0');
		i++;
	}
	return (res);
}