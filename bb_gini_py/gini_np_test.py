from unittest import TestCase
from gini_np import gini

class GiniNumpyTest(TestCase):
  def test_gini_np_coeffience(self):
    incomes = [10, 20, 30, 40, 50]
    result = gini(incomes)
    self.assertAlmostEqual(result, 0.26666666666666683)
