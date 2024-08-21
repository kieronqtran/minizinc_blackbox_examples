#include <iostream>
#include <vector>
#include <algorithm>
#include <map>
#include <utility>

#include <assert.h>
#include <stddef.h>

#include <bb_travelling_thief/travelling_thief.h>

namespace travelling_thief {

  std::vector<int> cal_velocity(int max_speed, int nu, std::vector<int>& weights) {
    std::vector<int> velocity;
    for (int i = 0; i < weights.size(); ++i) {
      velocity.push_back(max_speed - nu * weights[i]);
    }
    return velocity;
  }

  int cal_rental(int renting_ratio, std::map<std::pair<int, int>, int>& city_distances, std::vector<int>& orders, std::vector<int>& velocity) {
    int rental = 0;
    int current_city = 0;
    for (int i = 0; i < orders.size(); ++i) {
      int next_city = (i == orders.size() - 1) ? 1 : orders[i + 1];
      rental +=  city_distances[std::make_pair(current_city, next_city)] / velocity[current_city];
      current_city = next_city;
    }
    return renting_ratio * rental;
  }

}

extern "C" {

  void fzn_blackbox(const int* int_in, size_t int_in_len, const double *float_in,
                    size_t float_in_len, int *int_out, size_t int_out_len,
                    double *float_out, size_t float_out_len) {
    int renting_ratio = int_in[0];
    int max_speed = int_in[1];
    int nu = int_in[2];
    int order_len = int_in[3];
    int distances_n_rows = int_in[4];
    int distances_n_cols = int_in[5];
    int weights_len = int_in[6];
    std::vector<int> orders(int_in + 7, int_in + 7 + order_len);
    std::map<std::pair<int,int>, int> city_distances;
    for (int i = 0; i < distances_n_rows; ++i) {
      for (int j = 0; j < distances_n_cols; ++j) {
        city_distances[std::make_pair(i, j)] = int_in[7 + order_len + i * distances_n_cols + j];
      }
    }
    std::vector<int> weights(int_in + 7 + order_len + distances_n_rows * distances_n_cols,
                             int_in + 7 + order_len + distances_n_rows * distances_n_cols + weights_len);

    std::vector<int> velocity = travelling_thief::cal_velocity(max_speed, nu, weights);
    int rental = travelling_thief::cal_rental(renting_ratio, city_distances, orders, velocity);

    int_out[0] = rental;
    for (size_t i = 0; i < velocity.size(); i++)
    {
      int_out[i+1] = velocity[i];
    }
  }

}
