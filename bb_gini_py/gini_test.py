from unittest import TestCase
from gini import gini

class GiniTest(TestCase):
  def test_gini(self):
     incomes = [10, 20, 30, 40, 50]
     result = gini(incomes)
     self.assertAlmostEqual(result, 0.26666666666666683)
