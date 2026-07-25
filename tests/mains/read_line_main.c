#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "ft_read_line.h"

/*
 * Drives ft_read_line(fd, &is_success) in a loop against argv[1] and prints
 * one record per line read, so the shell test can assert on exact framing:
 *
 *   L<n> ok=<is_success> [<line>]
 *
 * Each line is bracketed with [ ] so the test can tell "empty line" apart
 * from "no more lines", and catch a missing/extra trailing newline in the
 * last record. After the loop exits (ft_read_line returned NULL), prints the
 * terminal is_success value so the test can check clean EOF (expected 1)
 * vs. a real read error (expected 0) are actually distinguishable.
 *
 * Loop is capped at MAX_LINES so a solution stuck in an infinite loop (e.g.
 * never advancing past EOF) prints a clear "LOOP_LIMIT" marker and exits
 * instead of hanging the test suite forever.
 */
# define MAX_LINES 10000

int	main(int argc, char **argv)
{
	int		fd;
	int		is_success;
	int		n;
	char	*line;

	if (argc != 2)
		return (1);
	fd = open(argv[1], O_RDONLY);
	if (fd < 0)
		return (2);
	n = 0;
	while (n < MAX_LINES)
	{
		is_success = -1;
		line = ft_read_line(fd, &is_success);
		if (!line)
		{
			printf("END ok=%d\n", is_success);
			close(fd);
			return (0);
		}
		printf("L%d ok=%d [%s]\n", n, is_success, line);
		free(line);
		n++;
	}
	printf("LOOP_LIMIT\n");
	close(fd);
	return (3);
}
