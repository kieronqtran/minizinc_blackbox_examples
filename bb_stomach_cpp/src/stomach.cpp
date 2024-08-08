#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_stomach/stomach.h>

namespace stomach {

  // t1 = 10*cos^7(x)
  double cal_t1(int x) {
    return 10 * std::pow(std::cos(x), 7);
  }
  // t2 = 20*sin^5(x)
  double cal_t2(int x) {
    return 20 * std::pow(std::sin(x), 5);
  }

  // t3 = 20*sin^3(x)
  double cal_t3(int x) {
    return 20 * std::pow(std::sin(x), 3);
  }

  // t4 = 10*cos(x)
  double cal_t4(int x) {
    return 10 * std::cos(x);
  }

  double cal_obj(int t1, int t2, int t3, int t4) {
    return cal_t1(t1) + cal_t2(t2) + cal_t3(t3) + cal_t4(t4);
  }
}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(int_in_len == 4);
    assert(float_out_len == 1);
    float_out[0] = stomach::cal_obj(int_in[0], int_in[1], int_in[2], int_in[3]);
  }

}
