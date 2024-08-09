#include <iostream>
#include <vector>
#include <algorithm>
#include <map>

#include <assert.h>
#include <stddef.h>

#include <bb_monkey/monkey.h>

namespace monkey {
  int cal_obj(const std::vector<int>& values) {
    int result = 0;
    std::map<std::pair<int,int>, int> coop;
    coop[std::make_pair(1,1)] = 0;
    coop[std::make_pair(1,2)] = 1;
    coop[std::make_pair(1,3)] = 3;
    coop[std::make_pair(1,4)] = 4;
    coop[std::make_pair(1,5)] = -2;
    coop[std::make_pair(1,6)] = 4;
    coop[std::make_pair(2,1)] = 1;
    coop[std::make_pair(2,2)] = 0;
    coop[std::make_pair(2,3)] = -2;
    coop[std::make_pair(2,4)] = 3;
    coop[std::make_pair(2,5)] = -1;
    coop[std::make_pair(2,6)] = 3;
    coop[std::make_pair(3,1)] = 3;
    coop[std::make_pair(3,2)] = -2;
    coop[std::make_pair(3,3)] = 0;
    coop[std::make_pair(3,4)] = -5;
    coop[std::make_pair(3,5)] = 1;
    coop[std::make_pair(3,6)] = 3;
    coop[std::make_pair(4,1)] = 4;
    coop[std::make_pair(4,2)] = 3;
    coop[std::make_pair(4,3)] = -5;
    coop[std::make_pair(4,4)] = 0;
    coop[std::make_pair(4,5)] = 2;
    coop[std::make_pair(4,6)] = -3;
    coop[std::make_pair(5,1)] = -2;
    coop[std::make_pair(5,2)] = -1;
    coop[std::make_pair(5,3)] = 1;
    coop[std::make_pair(5,4)] = 2;
    coop[std::make_pair(5,5)] = 0;
    coop[std::make_pair(5,6)] = -2;
    coop[std::make_pair(6,1)] = 4;
    coop[std::make_pair(6,2)] = 3;
    coop[std::make_pair(6,3)] = 3;
    coop[std::make_pair(6,4)] = -3;
    coop[std::make_pair(6,5)] = -2;
    coop[std::make_pair(6,6)] = 0;
    for (size_t i = 0; i < values.size() - 1; ++i) {
      result += coop[std::make_pair(values[i], values[i+1])];
    }
    return result;
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    // assert(int_in_len == 2);
    assert(int_out_len == 1);
    std::vector<int> vec(int_in, int_in + int_in_len);
    int_out[0] = monkey::cal_obj(vec);
  }

}

