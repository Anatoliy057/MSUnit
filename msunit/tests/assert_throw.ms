proc _unit_before_all_some_text1() {
    //code...
    return('hello')
}

proc _unit_before_each_some_text1() {
    //code...
    return('test')
}

proc _unit_test_throw_1() {
    @test = closure() {
        throw(IOException, '')
    }
    _assert_closure_throw('ms.lang.IOException', @test)
    _assert_proc_throw('ms.lang.IOException', '_throw_IOException')
}

proc _unit_test_throw_2() {
    @test = closure() {
        throw(Exception, '')
    }
    _assert_closure_throw('ms.lang.CastException', @test, 'SUCCESSFUL')
}

proc _unit_test_throw_3() {
    _assert_proc_throw('ms.lang.CastException', '_throw_IOException', 'SUCCESSFUL')
}

proc _unit_test_not_throw_1() {
    @test = closure() {
        _print('SUCCESSFUL')
    }
    _assert_closure_does_not_throw(@test)
    _assert_proc_does_not_throw('_not_throw')
}

proc _unit_test_not_throw_2() {
    @test = closure() {
        throw(IOException, '')
    }
    _assert_closure_does_not_throw(@test, 'SUCCESSFUL')
}

proc _unit_test_not_throw_3() {
    _assert_proc_does_not_throw('_throw_IOException', 'SUCCESSFUL')
}

proc _throw_IOException() {
    throw(IOException, '')
}

proc _not_throw() {
    _print('SUCCESSFUL')
}