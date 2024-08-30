#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_intestine/intestine.h>

namespace intestine {

  // 5 * sin(x) * cos(y) + abs(x) + abs(y)
  double cal_obj(int x, int y) {
    return 5 * std::sin(x) * std::cos(y) + std::abs(x) + std::abs(y);
  }
}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(int_in_len == 2);
    assert(float_out_len == 1);
    float_out[0] = intestine::cal_obj(int_in[0], int_in[1]);
  }

}
