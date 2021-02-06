proc _test_assertOut_fail() {
    //_skip_test()
    sleep(100)
}

proc _test_testOut_fail() {
    //_skip_test()
    while(true) {
        sleep(1)
        _assert_true(true)
    }
}
