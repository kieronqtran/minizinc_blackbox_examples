#ifndef PROJECT_GINI_H_
#define PROJECT_GINI_H_

namespace traveling_thief
{
  double cal_rental(
      int max_speed,
      int min_speed,
      int knapsack_capacity, 
      const std::vector<std::vector<int>>& city_distances, 
      const std::vector<int>& orders,
      const std::vector<int>& weights
    );

  std::vector<std::vector<int>> get_distance_matrix(int n);
}

#endif  // PROJECT_GINI_H_
