#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_beast_search/beast_search.h>

namespace beast_search {

  double cal_obj(int x, int y) {
    double numerator = std::abs(x + y - 8) + std::abs(x - y);
    double denominator = 10 + 3 * std::sin(3 * (x - 4)) + 2 * std::sin(3 * (y - 4));
    return 15 - 10 * (numerator / denominator);
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(int_in_len == 2);
    assert(float_out_len == 1);
    float_out[0] = beast_search::cal_obj(int_in[0], int_in[1]);
  }

}
