#include <vector>
#include <cmath>

#include <bb_median/median.h>

#include <gtest/gtest.h>

TEST(medianTest, CheckValues)
{
  std::vector<int> values = {8949, 9833, 10339, 9393, 9548, 9448, 9543, 9516, 9843, 10285};
  int medianValue = median::median(values);
  EXPECT_EQ(medianValue, 9543);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
