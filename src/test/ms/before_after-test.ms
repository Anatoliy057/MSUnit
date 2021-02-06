proc _before_all() {
    return('Hello')
}

proc _before_each() {
    return('World!')
}

proc _test1(@a, @b) {
    _println(@arguments)
    _assert_equals('Hello World!', "@a @b")
    return('Goodbye!')
}

proc _test2(@a, @b) {
    _println(@arguments)
    _assert_equals('Hello World!', "@a @b")
    return('Goodbye!')
}

proc _after_each(@test, @c) {
    _assert_equals('Goodbye!', @c)
}

proc _after_all() {
    @a = 1 + 40
}