#include <vector>
#include <cmath>

#include <bb_traveling_thief/pricess.h>

#include <gtest/gtest.h>

TEST(TravelingThiefTest, CheckValues)
{
  int result = traveling_thief::cal_obj(1, 0);
  ASSERT_EQ(result, -2);
}

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
