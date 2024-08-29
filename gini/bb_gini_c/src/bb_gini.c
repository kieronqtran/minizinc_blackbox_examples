/// gcc -shared -o ../libbb_gini.so bb_gini.c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <assert.h>
#include <stddef.h>

// double gini(const int* x, size_t x_len) {  
//     if (x_len == 0) {
//         return 0.0;
//     }
//     double sum_diff = 0.0;
//     for (size_t i = 0; i < x_len; i++)
//     {
//         for (size_t j = i + 1; j < x_len; j++)
//         {
//             sum_diff += abs(x[i] - x[j]);
//         }
//     }
//     double total = 0.0;
//     for (size_t i = 0; i < x_len; i++)
//     {
//         total += x[i];
//     }
//     return sum_diff / (x_len * total);
// }

int compare(const void* a, const void* b) {
   return (*(int*)a - *(int*)b);
}

// Faster gini implement
double gini(const int* x, size_t x_len) {
    if (x_len == 0) {
        return 0.0;
    }
    int* x_clone = malloc(x_len * sizeof(int));
    if (x_clone == NULL) {
        // Handle memory allocation failure
        fprintf(stderr, "Memory allocation failed\n");
        return -1.0;
    }

    memcpy(x_clone, x, x_len * sizeof(int));
    qsort(x_clone, x_len, sizeof(int), compare);

    int n = (int) x_len;
    double diffs = 0.0;
    for (int i = 0; i < n; i++)
    {
        int xi = x_clone[i];
        diffs += (2 * (i + 1) - n - 1) * xi;
    }

    double total = 0.0;
    for (int i = 0; i < n; i++)
    {
        total += x_clone[i];
    }

    free(x_clone);
    return diffs / (x_len * total);
}

void fzn_blackbox(const int *int_in, size_t int_in_len, const double *float_in,
                  size_t float_in_len, int *int_out, size_t int_out_len,
                  double *float_out, size_t float_out_len) {
  assert(float_out_len == 1);
  float_out[0] = gini(int_in, int_in_len) * 100;
}
