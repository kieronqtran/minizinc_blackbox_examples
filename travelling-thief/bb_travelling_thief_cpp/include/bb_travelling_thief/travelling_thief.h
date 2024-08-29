#ifndef PROJECT_GINI_H_
#define PROJECT_GINI_H_

namespace traveling_thief
{
  std::vector<int> cal_velocity(int max_speed, double nu, std::vector<int>& weights);
  int cal_rental(int renting_ratio, std::map<std::pair<int,int>, int>& distances, std::vector<int>& order, std::vector<int>& velocity);
}

#endif  // PROJECT_GINI_H_
