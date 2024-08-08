#include <vector>
#include <cmath>

#include <bb_most_painful/most_painful.h>

#include <gtest/gtest.h>

TEST(most_painfulTest, CheckValues)
{
  auto result = most_painful::cal_obj(5, 0);
  EXPECT_NEAR(result, -57.946213733156, 1e-3);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
