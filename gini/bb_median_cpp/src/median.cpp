#include <iostream>
#include <vector>
#include <algorithm>

#include <bb_median/median.h>

namespace median {

  int median(const std::vector<int>& values) {
    if (values.empty()) {
      return 0;
    }
    std::vector<int> sorted_values = values;
    std::sort(sorted_values.begin(), sorted_values.end());
    size_t mid = sorted_values.size() / 2;
    if (sorted_values.size() % 2 == 0) {
      return sorted_values[mid - 1];
    }
    return sorted_values[mid];
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    std::vector<int> vec(int_in, int_in + int_in_len);
    int_out[0] = median::median(vec);
  }

}