#include <iostream>
#include <vector>
#include <algorithm>

#include <assert.h>
#include <stddef.h>

#include <bb_gini/gini.h>

namespace gini {

  double gini(const std::vector<int>& values) {
    if (values.empty()) {
      return 0.0;
    }
    std::vector<int> sorted_values;
    sorted_values.insert(sorted_values.begin(), values.begin(), values.end());
    std::sort(sorted_values.begin(), sorted_values.end());
    int n = static_cast<int>(sorted_values.size());
    double cumulative_weight = 0.0;
    double cumulative_sum = 0.0;

    for (int i = 0; i < n; i++) {
      std::vector<int>::size_type index = static_cast<std::vector<int>::size_type>(i);
      cumulative_sum += (2 * (i + 1) - n - 1) * values[index];
    }

    for (int i = 0; i < n; i++)
    {
      std::vector<int>::size_type index = static_cast<std::vector<int>::size_type>(i);
      cumulative_weight += values[index];
    }

    return cumulative_sum / (n * cumulative_weight);
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    assert(float_out_len == 1);
    std::vector<int> vec(int_in, int_in + int_in_len);
    float_out[0] = gini::gini(vec) * 100;
  }

}