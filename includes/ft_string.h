/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_string.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: sapoolpr <sapoolpr@student.42bangkok.co    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/07/26 00:20:04 by sapoolpr          #+#    #+#             */
/*   Updated: 2026/07/26 03:42:21 by sapoolpr         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_STRING_H
# define FT_STRING_H

int		is_number(char c);
int		is_space(char c);
int		ft_strlen(char *str);
int		ft_strcmp(char *s1, char *s2);
int		ft_strchr(char *str, char c);
char	*ft_strpcpy(char *dest, char *src);
char	*ft_strdup(char *str);
char	*ft_strndup(char *str, int n);
char	*ft_strnjoin(char *s1, char *s2, int n);
char	*trim_spaces(char *str, int start, int end);

#endif
