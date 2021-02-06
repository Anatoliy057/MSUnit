proc _test_assertClosureThrow_successfully() {
    @test = closure() {
        throw(IOException, '')
    }
    _assert_closure_throw(IOException, @test)
}

proc _test_assertClosureThrow_fail() {
    @test = closure() {
        throw(Exception, '')
    }
    _assert_closure_throw(CastException, @test, 'SUCCESSFUL')
}

proc _test_assertProcThrow_successfully() {
    _assert_proc_throw(IOException, '_throw_IOException')
}

proc _test_assertProcThrow_fail() {
    _assert_proc_throw(CastException, '_throw_IOException', 'SUCCESSFUL')
}

proc _throw_IOException() {
    throw(IOException, '')
}
