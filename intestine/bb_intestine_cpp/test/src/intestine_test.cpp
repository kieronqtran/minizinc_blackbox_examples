#include <vector>
#include <cmath>

#include <bb_intestine/intestine.h>

#include <gtest/gtest.h>

TEST(IntestineTest, CheckValues)
{
  auto result = intestine::cal_obj(-1, 0);
  EXPECT_NEAR(result, -3.20735492403948, 1e-5);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
