#include <vector>
#include <cmath>

#include <bb_travelling_thief/travelling_thief.h>

#include <gtest/gtest.h>

TEST(TravelingThiefTest, TestWeight)
{
  std::vector<traveling_thief::Item> items = {
        {9665, 6534, 2},
        {5393, 3700, 2},
        {3324, 9110, 2},
        {4823, 2656, 3},
        {8968, 9789, 3},
        {7715, 1925, 3},
        {1743, 3194, 4},
        {3432, 4325, 4},
        {4604, 3877, 4},
        {2220, 3815, 5},
        {5965, 9176, 5},
        {5152, 5809, 5},
        {3181, 3473, 6},
        {6830, 658, 6},
        {1792, 3607, 6},
        {7552, 8732, 7},
        {2971, 7032, 7},
        {9780, 6878, 7},
        {5816, 8150, 8},
        {7851, 9291, 8},
        {3842, 9504, 8},
        {4843, 3579, 9},
        {8989, 9904, 9},
        {1001, 9343, 9},
        {5358, 4294, 10},
        {7725, 5857, 10},
        {277, 2654, 10}
      };
    std::vector<int> chosen = {0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0};
    std::vector<int> orders = {1, 2, 8, 10, 4, 9, 3, 7, 5, 6};
    std::vector<int> weights = traveling_thief::calculate_weights(orders, chosen, items, 3);
    std::vector<int> expected = {0, 0, 0, 0, 0, 0, 1925, 1925, 1925, 2583};
    ASSERT_EQ(weights, expected);
}

TEST(TravelingThiefTest, CheckValues)
{

  std::vector<std::vector<int>> distances =  {
      {   0,  50, 547, 256, 390, 220, 738, 273, 389, 361 },
      {  50,   0, 595, 255, 434, 266, 788, 253, 420, 337 },
      { 547, 595,   0, 552, 416, 410, 222, 651, 326, 722 },
      { 256, 255, 552,   0, 580, 410, 772, 103, 260, 172 },
      { 390, 434, 416, 580,   0, 175, 500, 640, 528, 730 },
      { 220, 266, 410, 410, 175,   0, 563, 465, 405, 556 },
      { 738, 788, 222, 772, 500, 563,   0, 870, 547, 943 },
      { 273, 253, 651, 103, 640, 465, 870,   0, 362,  91 },
      { 389, 420, 326, 260, 528, 405, 547, 362,   0, 416 },
      { 361, 337, 722, 172, 730, 556, 943,  91, 416,   0 }
  };


  std::vector<int> orders = {1, 2, 3, 5, 6, 7, 9, 4, 8, 10};
  std::vector<int> weights = {0, 0, 1925, 1925, 2583, 2583, 2583, 2583, 2583, 2583};

  double result = traveling_thief::cal_rental(
      200,
      100,
      5000,
      distances,
      orders,
      weights
  );
  ASSERT_NEAR(result, 19.7926, 1e-4);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
