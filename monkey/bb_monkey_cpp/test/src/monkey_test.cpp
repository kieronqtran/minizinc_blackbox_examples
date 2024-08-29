#include <vector>
#include <cmath>
#include <tuple>

#include <bb_monkey/monkey.h>

#include <gtest/gtest.h>

class BeastSearchTest : public testing::TestWithParam<std::tuple<int, int, double>> 
{
};

TEST_P(BeastSearchTest, CheckValues)
{
  auto x = std::get<0>(GetParam());
  auto y = std::get<1>(GetParam());
  auto expected = std::get<2>(GetParam());
  auto result = monkey::cal_obj(x, y);
  EXPECT_NEAR(result, expected, 1e-10);
}

INSTANTIATE_TEST_SUITE_P(
    BeastSearchTestInstance,
    BeastSearchTest,
    ::testing::Values(
      std::make_tuple(-4, -4, 3.986702124977125),
      std::make_tuple(-4, -3, 0.5117395865616867),
      std::make_tuple(-4, -2, 3.747220758347121),
      std::make_tuple(-4, -1, 0.9847787409105191),
      std::make_tuple(-4, 0, 3.397289222091853),
      std::make_tuple(-4, 1, 1.546140394928798),
      std::make_tuple(-4, 2, 2.947783242787258),
      std::make_tuple(-4, 3, 2.132569589632322),
      std::make_tuple(-4, 4, 2.418154194633194),
      std::make_tuple(-3, -4, -2.202100300696472),
      std::make_tuple(-3, -3, -9.068539744126152),
      std::make_tuple(-3, -2, -0.5693818968230779),
      std::make_tuple(-3, -1, -7.619107113939965),
      std::make_tuple(-3, 0, -1.349068646294228),
      std::make_tuple(-3, 1, -6.002742599325405),
      std::make_tuple(-3, 2, -2.393758745925354),
      std::make_tuple(-3, 3, -4.423421104618612),
      std::make_tuple(-3, 4, -3.691506222013913),
      std::make_tuple(-2, -4, 3.623531549039619),
      std::make_tuple(-2, -3, 1.767048638666779),
      std::make_tuple(-2, -2, 6.275859229022471),
      std::make_tuple(-2, -1, 4.043483370418071),
      std::make_tuple(-2, 0, 5.995119969369563),
      std::make_tuple(-2, 1, 4.500140880392461),
      std::make_tuple(-2, 2, 5.633629308087887),
      std::make_tuple(-2, 3, 4.975541762243516),
      std::make_tuple(-2, 4, 5.206449465587349),
      std::make_tuple(-1, -4, -1.226697999459763),
      std::make_tuple(-1, -3, -6.957942000364049),
      std::make_tuple(-1, -2, 2.436016570394488),
      std::make_tuple(-1, -1, 0.1820257718296361),
      std::make_tuple(-1, 0, 4.037831044785493),
      std::make_tuple(-1, 1, 1.158977038392566),
      std::make_tuple(-1, 2, 3.382855734566224),
      std::make_tuple(-1, 3, 2.124844463793753),
      std::make_tuple(-1, 4, 2.576307066686001),
      std::make_tuple(0, -4, 3.078274009612526),
      std::make_tuple(0, -3, 0.910400683037766),
      std::make_tuple(0, -2, 5.847863984121835),
      std::make_tuple(0, -1, 5.299872716361968),
      std::make_tuple(0, 0, 8.692276738248587),
      std::make_tuple(0, 1, 7.582621564272189),
      std::make_tuple(0, 2, 8.425675068849038),
      std::make_tuple(0, 3, 7.937528125083786),
      std::make_tuple(0, 4, 8.109221532827581),
      std::make_tuple(1, -4, -0.1303079784404719),
      std::make_tuple(1, -3, -4.745193169916377),
      std::make_tuple(1, -2, 3.310495493946799),
      std::make_tuple(1, -1, 1.600686416963855),
      std::make_tuple(1, 0, 6.867265956951437),
      std::make_tuple(1, 1, 7.442761069721872),
      std::make_tuple(1, 2, 8.56394127952078),
      std::make_tuple(1, 3, 7.925700006311087),
      std::make_tuple(1, 4, 8.153533361962076),
      std::make_tuple(2, -4, 2.351181930495727),
      std::make_tuple(2, -3, -0.2756126123292191),
      std::make_tuple(2, -2, 5.275700887745128),
      std::make_tuple(2, -1, 4.515259863000175),
      std::make_tuple(2, 0, 8.283740659393928),
      std::make_tuple(2, 1, 9.008393954936551),
      std::make_tuple(2, 2, 11.49032832920493),
      std::make_tuple(2, 3, 11.21068819145221),
      std::make_tuple(2, 4, 11.30936609349665),
      std::make_tuple(3, -4, 0.9498721115791184),
      std::make_tuple(3, -3, -2.714055094554389),
      std::make_tuple(3, -2, 4.168320611585319),
      std::make_tuple(3, -1, 2.916961924244696),
      std::make_tuple(3, 0, 7.48811183496292),
      std::make_tuple(3, 1, 8.144739797354594),
      std::make_tuple(3, 2, 11.05346410545285),
      std::make_tuple(3, 3, 12.84816662864548),
      std::make_tuple(3, 4, 12.91158485121117),
      std::make_tuple(4, -4, 1.453485993060765),
      std::make_tuple(4, -3, -1.813406224073695),
      std::make_tuple(4, -2, 4.567008684694777),
      std::make_tuple(4, -1, 3.504986499657011),
      std::make_tuple(4, 0, 7.775314153281986),
      std::make_tuple(4, 1, 8.461034269630471),
      std::make_tuple(4, 2, 11.21170184335311),
      std::make_tuple(4, 3, 12.94191253610134),
      std::make_tuple(4, 4, 15.0)
    )
);

int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}
