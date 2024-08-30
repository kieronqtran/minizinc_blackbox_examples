#ifndef PROJECT_STOMACH_H_
#define PROJECT_STOMACH_H_

namespace stomach
{
  // t1 = 10*cos^7(x)
  double cal_t1(int x);
  // t2 = 20*sin^5(x)
  double cal_t2(int x);
  // t3 = 20*sin^3(x)
  double cal_t3(int x);
  // t3 = 20*sin^3(x)
  double cal_t4(int x);

  // obj = cal_t1(t1) + cal_t2(t2) + cal_t3(t3) + cal_t4(t4)
  double cal_obj(int t1, int t2, int t3, int t4);
}

#endif  // PROJECT_STOMACH_H_
