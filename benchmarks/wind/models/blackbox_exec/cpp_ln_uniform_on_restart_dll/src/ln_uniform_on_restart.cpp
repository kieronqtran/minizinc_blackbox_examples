#include <cassert>
#include <cmath>
#include <cstddef>
#include <limits>
#include <random>

namespace {

std::mt19937_64& rng() {
  static std::mt19937_64 gen{std::random_device{}()};
  return gen;
}

double sample_ln_uniform(double lb, double ub) {
  const double min_pos = std::nextafter(0.0, 1.0);

  if (!(ub > lb) || ub <= min_pos) {
    return 0.0;
  }

  if (lb < min_pos) lb = min_pos;

  std::uniform_real_distribution<double> dist(lb, ub);
  double u = dist(rng());
  if (u < min_pos) u = min_pos;
  return std::log(u);
}

}  // namespace

extern "C" {

void fzn_blackbox(const int* int_in, size_t int_in_len, const double* float_in,
                  size_t float_in_len, int* int_out, size_t int_out_len,
                  double* float_out, size_t float_out_len) {
  (void)int_out;

  // Optional per-call reseed if caller provides a seed.
  if (int_in != nullptr && int_in_len >= 1) {
    rng().seed(static_cast<std::mt19937_64::result_type>(int_in[0]));
  }

  // This blackbox is designed for: floats=[lb, ub] -> float_out=[ln(u)].
  assert(float_in != nullptr);
  assert(float_in_len == 2);
  assert(int_out_len == 0);
  assert(float_out != nullptr);
  assert(float_out_len == 1);

  float_out[0] = sample_ln_uniform(float_in[0], float_in[1]);
}

}  // extern "C"
