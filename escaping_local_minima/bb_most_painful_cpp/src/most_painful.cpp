#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_most_painful/most_painful.h>

namespace most_painful {

  double cal_obj(int x, int y) {
    return -10 * (cos(x * y) - x * sin(x) * cos(y));
  }
}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(int_in_len == 2);
    assert(float_out_len == 1);
    float_out[0] = most_painful::cal_obj(int_in[0], int_in[1]);
  }

}
