proc _test_assert_out() {
    //_skip_test()
    sleep(100)
}

proc _test_proc_out() {
    //_skip_test()
    while(true) {
        sleep(1)
        _assert_true(true)
    }
}