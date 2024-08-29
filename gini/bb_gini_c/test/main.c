#include <math.h>

#include <stdlib.h>
#include <stdio.h>

#include <stddef.h>
#include <setjmp.h>
#include <cmocka.h>

#include <bb_gini.h>

static void gini_test_success(void **state) {
    int incomes[5] = { 10, 20, 30, 40, 50 };
    float result = gini(incomes, 5);
    assert_double_equal(round(result * 10000) / 10000, 0.2667, 0.0001f);
}


/**
 * Test runner function
 */
int main(void) {

    /**
     * Insert here your test functions
     */
    const struct CMUnitTest tests[] = {
        cmocka_unit_test(gini_test_success),
    };

    /* Run the tests */
    return cmocka_run_group_tests(tests, NULL, NULL);
}
