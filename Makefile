NAME = rush-02
CC = cc
CFLAGS = -Wall -Wextra -Werror

INC_DIR = includes
CFLAGS += -I $(INC_DIR)

SRCS_DIR = srcs
SRCS = $(SRCS_DIR)/main.c \
			 $(SRCS_DIR)parse_dict.c \
			 $(SRCS_DIR)/parse_num.c \
			 $(SRCS_DIR)/convert.c \
			 $(SRCS_DIR)/print.c \
			 $(SRCS_DIR)/ft_utils.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME) : $(OBJS)
		$(CC) $(OBJS) -o $(NAME)

%.o: %.c 
		$(CC) $(CFLAGS) -c $< -o $@ 

clean: 
		rm -f $(OBJS)

fclean: clean
		rm -f $(NAME)

re: flclean all

.PHONY: all clean fclean re