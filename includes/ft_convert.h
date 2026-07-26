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

# include "ft_print.h"
# include "ft_dict.h"
# define HUNDREDTH_POS 2
# define TENTH_POS 1
# define ONES_POS 0
# define DEFAULT_COMMA ","
# define DEFAULT_AND "and"
# define DEFAULT_HYPHEN "-"

typedef struct s_triplet
{
	int	hundredth;
	int	tenth;
	int	ones;
}	t_triplet;

typedef struct s_conv_ctx
{
	int		to_conv;
	int		scale;
}	t_conv_ctx;

void	assign_digit_to_key(char *key, int n);
void	assign_unique_to_key(char *key, int tenth, int ones);
char	*tenth_lookup(t_dict_list *dict, int tenth);
char	*get_suffix(t_dict_list *dict, int scale_idx, int pos);
int		convert_hundredth(
			t_triplet	*triplet,
			t_print_buf *buf,
			int scale,
			t_dict_list *dict
			);
int		convert_tenth_ones(
			t_triplet *triplet,
			t_print_buf *buf,
			int scale,
			t_dict_list *dict
			);
void	append_comma(t_dict_list *dict, t_print_buf *buf);
void	append_and(t_dict_list *dict, t_print_buf *buf);
void	append_hyphen(t_dict_list *dict, t_print_buf *buf);

#endif