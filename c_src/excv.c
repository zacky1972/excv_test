#include "cvtest.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

int main(int argc, const char *argv[])
{
	if(argc != 5) {
		return 1;
	}
	const unsigned char *filename1 = (const unsigned char *)argv[1];
	size_t size1 = strnlen(filename1, 256);
	const unsigned char *filename2 = (const unsigned char *)argv[2];
	size_t size2 = strnlen(filename2, 256);
	bool is_cuda;
	if(strncmp(argv[3], "true", 4) == 0) {
		is_cuda = true;
	} else {
		is_cuda = false;
	}
	uint64_t loop;
	if(!sscanf(argv[4], "%llu", &loop)) {
		return 1;
	}
	double time;
	if(!cvtest(size1, filename1, size2, filename2, &time, is_cuda, loop)) {
		return 1;
	}
	printf("%lf\n", time);
	return 0;
}
