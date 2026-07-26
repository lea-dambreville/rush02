NAME      = rush-02
CC        = cc
CFLAGS    = -Wall -Wextra -Werror -I includes

SRCS_DIR  = srcs/
SRCS      = $(SRCS_DIR)convert_1.c \
            $(SRCS_DIR)convert_2.c \
            $(SRCS_DIR)convert_3.c \
            $(SRCS_DIR)convert_4.c \
            $(SRCS_DIR)ft_dict.c \
            $(SRCS_DIR)ft_math.c \
            $(SRCS_DIR)ft_mem.c \
            $(SRCS_DIR)ft_print.c \
            $(SRCS_DIR)ft_read_line.c \
            $(SRCS_DIR)ft_string_1.c \
            $(SRCS_DIR)ft_string_2.c \
            $(SRCS_DIR)ft_string_3.c \
            $(SRCS_DIR)main.c \
            $(SRCS_DIR)parse_dict.c \
            $(SRCS_DIR)parse_num.c \

OBJS      = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
