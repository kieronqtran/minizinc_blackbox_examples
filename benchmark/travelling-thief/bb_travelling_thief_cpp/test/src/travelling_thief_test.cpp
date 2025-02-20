#include <vector>
#include <cmath>

#include <bb_travelling_thief/travelling_thief.h>

#include <gtest/gtest.h>

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
  ASSERT_EQ(result, 14.0);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
