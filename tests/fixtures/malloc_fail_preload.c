/* Test fixture: LD_PRELOAD shim that makes the Nth call to malloc() (1-based,
   counted across the whole process) return NULL instead of allocating, so a
   test can verify a solution's malloc-failure path (checks the return value,
   frees what it already held, doesn't crash/leak) without needing to
   actually exhaust memory. Controlled by env vars:

     MALLOC_FAIL_AT=<n>   fail the n-th malloc call (1-based); unset/0 = never fail
     MALLOC_FAIL_LOG=path  optional: log one line per malloc call ("<n>\n")

   Logging deliberately avoids libc buffered I/O (fopen/fprintf): those
   allocate internally, which would recurse back into this same intercepted
   malloc() before real_malloc is resolved and cause a stack-overflow
   segfault. write(2) on a plain fd is allocation-free and safe here.

   Not part of any turn-in; test scaffolding only. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>

static void	*(*real_malloc)(size_t);
static long	call_n;
static long	fail_at = -1;
static int	fail_at_read;
static int	log_fd = -1;
static int	log_fd_tried;

static long	get_fail_at(void)
{
	char	*s;

	if (!fail_at_read)
	{
		fail_at_read = 1;
		s = getenv("MALLOC_FAIL_AT");
		if (s && *s)
			fail_at = atol(s);
	}
	return (fail_at);
}

static int	get_log_fd(void)
{
	char	*path;

	if (!log_fd_tried)
	{
		log_fd_tried = 1;
		path = getenv("MALLOC_FAIL_LOG");
		if (path)
			log_fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
	}
	return (log_fd);
}

/* Minimal itoa into a fixed buffer; no malloc, no libc string funcs that
   might allocate. Returns bytes written. */
static int	fmt_line(char *buf, long n)
{
	char	tmp[24];
	int		i;
	int		len;

	i = 0;
	if (n == 0)
		tmp[i++] = '0';
	while (n > 0)
	{
		tmp[i++] = (char)('0' + (n % 10));
		n /= 10;
	}
	len = 0;
	while (i > 0)
		buf[len++] = tmp[--i];
	buf[len++] = '\n';
	return (len);
}

void	*malloc(size_t size)
{
	long	n;
	long	target;
	int		fd;
	char	buf[24];
	int		len;

	if (!real_malloc)
		real_malloc = dlsym(RTLD_NEXT, "malloc");
	n = __sync_add_and_fetch(&call_n, 1);
	fd = get_log_fd();
	if (fd >= 0)
	{
		len = fmt_line(buf, n);
		write(fd, buf, (size_t)len);
	}
	target = get_fail_at();
	if (target > 0 && n == target)
		return (NULL);
	return (real_malloc(size));
}
