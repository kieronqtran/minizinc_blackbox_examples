#include <vector>
#include <cmath>

#include <bb_stomach/stomach.h>

#include <gtest/gtest.h>

TEST(StomachTest, CheckValues)
{
  auto result = stomach::cal_obj(-1, -2, -1, -2);
  EXPECT_NEAR(result, -28.3760533094054, 1e-5);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
