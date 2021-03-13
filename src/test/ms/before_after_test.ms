proc _before_all() {
    return('Hello')
}

proc _before_each() {
    return('World!')
}

proc _test_supportProcs_successfully(@test, @before_all, @before_each) {
    _println(@arguments)
    _assert_equals('Hello World!', "@before_all @before_each")
    return('Goodbye world!')
}

proc _after_each(@test, @c) {
    _assert_equals('Goodbye world!', @c)
}

proc _after_all() {
    @test = 'test'
}
