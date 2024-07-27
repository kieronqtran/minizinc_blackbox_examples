#include <vector>
#include <cmath>

#include <bb_gini/gini.h>

#include <gtest/gtest.h>

TEST(GiniTest, CheckValues)
{
  const std::vector<int> incomes = { 10, 20, 30, 40, 50 };
  double result = gini::gini(incomes);
  double roundedLastThree = std::round(result * 10000.0) / 10000;
  ASSERT_EQ(roundedLastThree, 0.2667);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
