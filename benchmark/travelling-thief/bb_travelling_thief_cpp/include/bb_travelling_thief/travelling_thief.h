#ifndef PROJECT_GINI_H_
#define PROJECT_GINI_H_

namespace traveling_thief
{

  struct Item {
      int profit;
      int weight;
      int city;
  };

  double cal_rental(
      int max_speed,
      int min_speed,
      int knapsack_capacity, 
      const std::vector<std::vector<int>>& city_distances, 
      const std::vector<int>& orders,
      const std::vector<int>& weights
    );

  std::vector<std::vector<int>> get_distance_matrix(int n);

  std::vector<Item> get_items(int n);

  std::vector<int> calculate_weights(const std::vector<int>& orders, const std::vector<int>& chosen, const std::vector<traveling_thief::Item>& items, size_t items_per_city);
}

#endif  // PROJECT_GINI_H_
