proc _test_throw_1() {
    @test = closure() {
        throw(IOException, '')
    }
    _assert_execute_throw(IOException, @test)
    _assert_proc_throw(IOException, '_throw_IOException')
}

proc _test_throw_2() {
    @test = closure() {
        throw(Exception, '')
    }
    _assert_execute_throw(CastException, @test, 'SUCCESSFUL')
}

proc _test_throw_3() {
    _assert_proc_throw(CastException, '_throw_IOException', 'SUCCESSFUL')
}

proc _throw_IOException() {
    throw(IOException, '')
}
