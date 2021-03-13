# MethodScript Unit

## Getting started

Four things need to be done to run tests

1. Init MSUnit
2. Register the folder (hereinafter referred to as the module), which will contain the tests
3. Write the tests
4. Enter command to run

### **Initializtion MSUnit**

First include the main.ms script, then call the _init_msunit procedure

Like this:
```ms
// your includes
include('unit/main.ms')
// your includes

_init_msunit()
```

> **Attention**: the tests will contain the environment that was at the time of the procedure call *_init_msunit*

### **Registration**

Registration is done in one procedure:

```ms
_msunit_register_module(array(
  id: test,
  root: file_resolve('root')
))
```

- **id** - unique module name
- **root** - existing path to module

After recompile the following file structure is obtained:

```
/root
  /extension
    /main.ms
  /ms
  /resources
  /setting.yml
```

### **Tests**

Test scripts must be in the ms folder and their names must end with '-test.ms'. The names of the tests themselves (procedures) must begin with _test.

Example
```ms
# ms/test-test.ms

proc _test_mytest() {
    _assert_equals(1, 1)
}
```

In addition to the tests themselves, there are auxiliary procedures such as: *_before_each*, *_after_all*, e.t.c.

See in section [auxiliary procedures](#Auxiliary-procedures)

### **Command to run**

To run the tests, just enter the `msunit test` command, where 'msunit' is name command and test is id module of tests.

Also, after the ID of the module, you can choose the group of tests you want to test, it can be either several scripts or one test! Groups can be selected and excluded by the "!" at the beginning of the group name, like `!group`. For a specific test, you need to specify the script group in which it is located and the script itself, separated by a colon: `group:_test_mytest`, they can also be excluded. For the most part, enabling exclusion of groups works like set mathematics where the element of set is the test.

After running the tests for the first time, something like this appeared in setting.yml:
```yml
test-test: [
  ]
```
Keys are the formatted names of scripts (replace / to . and remove .ms extension) and values is groups that indicate in command. Keys are also groups, only they include one test - themselves.

Examples:
```yml
test-test:
  - all
  - test
util-test:
  - all
  - util
logger-test:
  - util
  - all
  - log
```

- `unit test` - all tests
- `unit test all` - all tests
- `unit test util` - logger-test.ms, util-test.ms
- `unit test util test` - all tests
- `unit test !test` - logger-test.ms, util-test.ms
- `unit test util !log` - util-test.ms
- `unit test util !all` - no tests
- `unit test !all test` - test-test.ms
- `unit test test:_test_mytest` - test-test.ms : {_test_mytest}
- `unit test test:_test_mytest, test:_test_secondtest` - test-test.ms : {_test_mytest, _test_secondtest}
- `unit test !test-test:_test_mytest` - all tests except test-test.ms : {_test_mytest}
- `unit test !all:_test_mytest` - all tests except _test_mytest

### Data files

In each test, you can create files that are deleted after the module test expires.They are located by default `"root/data/{name_current_thread}/"`.

You can save files by specifying the `"--save-data"` flag when running tests


### Globals constants

For each test, global constants are unique and do not overlap. But at the same time, constants from the main logic are not transferred to tests, that is, they are empty.

It is recommended to initialize them in `_before_each_`

***

## Syntax command

> `unit <module> [--reinit] [--nobar] [--save-data] [groups...]`

- **module** - id of module

- **--reinit** - module reinitialization (recompile tests, update settings)

- **--nobar** - disable loading status bar

- **--save-data** - enable save data files

- **groups** - groups of tests

***

## Auxiliary procedures

### **_before_all(testName)**

Default pattern: *\_before\_all.\**

Runs one time before all tests

The return value is passed to the all tests as the first argument

### **_before_each(testName)**

Default pattern: *\_before\_each.\**

Runs every time before tests

Accepts test name and the return value is passed to the test as the second argument

### **_after_all()**

Default pattern: *\_after\_all.\**

Runs one time after all tests

### **_after_each(testName, returnTest)**

Default pattern: *\_before\_each.\**

Runs every time after tests

Accepts test name and the value returned by the test

***

## API

### Registration

```ms
_msunit_register_module(array(
  id: test,
  root: file_resolve('root')
  [tests: string],
  [extension: string],
  [resources: string],
  [data: string],
  [setting_groups: string],
  [outs: array]
  [tests_setting: array]
))
```

- **id** - Unique identifier for pluggable tests
- **root** - Main path to all parts required for MSUnit to work
- **tests** - Local path to tests, by default *"root/ms"*
- **extension** - Local path to scripts, that runs before running tests, by default *"root/extension"*
- **resources** - Local path to resources, by default *"root/resources"*
- **data** - Local path to root data files for each test, by default *"root/data"*
- **setting_groups** - Local path to yml file map "test: [groups...]", by default *"root/setting.yml"*
- **outs** - array of loggers, taken from `_msunit_get_outs` by default
- **tests_setting** - see [default value](src/main/resources/tests_setting.yml)

### Set options

To customize the framework for your machine, use the setup procedure:

>`void _msunit_set_options(array @options)`.

See the [default value](src/main/resources/options.yml)

### Assertions

- `void _assert_true_obj(Booleanish o, [mixed msg])`
- `void _assert_false_obj(Booleanish o, [mixed msg])`
- `void _assert_true(boolean bool, [mixed msg])`
- `void _assert_false(boolean bool, [mixed msg])`
- `void _assert_null(mixed object, [mixed msg])`
- `void _assert_not_null(mixed object, [mixed msg])`
- `void _assert_equals(mixed exp, mixed act, [mixed msg])`
- `void _assert_ref_eq(mixed val1, mixed val2, [mixed msg])`
- `void _assert_not_equals(mixed arg1, mixed arg2, [mixed msg])`
- `void _assert_size(int size, array arr, [mixed msg])`
- `void _assert_length(int length, mixed act, [mixed msg])`
- `void _assert_empty(mixed object, [mixed msg])`
- `void _assert_not_empty(mixed object, [mixed msg])`
- `void _assert_type(ClassType type, mixed object, [mixed msg])`
- `void _assert_proc_throw(ClassType type, string proc_name, [mixed msg])`
- `void _assert_closure_throw(ClassType type, closure lymda, [mixed msg])`
- `void _assert_proc_array_throw(ClassType type, string proc_name, array args, [mixed msg])`
- `void _assert_closure_array_throw(ClassType type, closure lymda, array args, [mixed msg])`
- `void _assert_key_exist(array array, string key, [mixed msg])`
- `void _assert_key_not_exist(string key, array array, [mixed msg])`

### Supporting Procedures

- `void _print(mixed msg)`
    
    Displays a message in the body of the test log

- `void _println([mixed msg])`
    
    Displays a message with break line in the body of the test log

- `void _sleep(number seconds)`
    
    Sleeps the test for the specified number of seconds (Assert and procedure timout is sleep too)

- `void _skip_test()`
    
    Stops the test and marks it as skipped

- `void _assert_time(int seconds)`
    
    Sets the value of "assert timeout" to the specified number of seconds

- `void _test_time(int seconds)`
    
    Sets the value of "test timeout" to the specified number of seconds

- `void _attension_time(int seconds)`
    
    Sets the value of "attension time" to the specified number of seconds

- `void _restart_assert_time()`
    
    Restarts assertion timeout to default

- `void _x_safe(closure lymda)`
    
    Executes closure, will not end even when the test or assertion timeout

- `string _unit_get_data(string @filename = '')`
    
    Returns the file path to the data file of test

- `string proc _unit_get_resource(string @filename)`
    
    Returns the file path to the resource file of module


# Environment 

- [**Procedures**](__procedures__.ms)
- Exports reg match **'org\\.cadabra\\.msunit.*'**

***

## Recuired

- Extensions:
  - [CHUnit](https://github.com/Anatoliy057/CHUnit)
