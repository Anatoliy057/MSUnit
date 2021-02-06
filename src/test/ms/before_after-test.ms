proc _before_all() {
    return('Hello')
}

proc _before_each() {
    return('World!')
}

proc _test_supportProcs_successfully(@a, @b) {
    _println(@arguments)
    _assert_equals('Hello World!', "@a @b")
    return('Goodbye world!')
}

proc _after_each(@test, @c) {
    _assert_equals('Goodbye world!', @c)
}

proc _after_all() {
    @test = 'test'
}
