#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_pricess/pricess.h>

namespace pricess {

  int cal_obj(int X, int Y) {
    return X*X + X*Y + Y*Y - 3*X - 2*Y;
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(int_in_len == 2);
    assert(int_out_len == 1);
    int_out[0] = pricess::cal_obj(int_in[0], int_in[1]);
  }

}
