#ifndef CVTEST_H
#define CVTEST_H

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

bool cvtest(size_t size, const unsigned char *filename, double *time, bool is_cuda, uint64_t loop);

#ifdef __cplusplus
}
#endif // __cplusplus

#endif // CVTEST_H
