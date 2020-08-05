# Command Helper Scripts: Unit

>Unit test library.

***

## Using

To connect the module, just connect main.ms and call procedure: `_unit_init_module()` after all includes.

Register the module for which you want to write tests using procedures:

```ms
_unit_register_module(associative_array(
    id: string,
    root: string,
    [tests: string = @root.'\\tests']
    [localPackages: string  = @root.'\\localPackages\\main.ms']
    [resource: string = @root.'\\resource']
    [groups: string = @root.'\\tests.properties'],
    [filter: string = null],
    [outs: array<out> = _unit_get_default_outs(@root.'\\logs')]
))
```

### Keys

- **id** - unique identifier for pluggable tests
- **root** - Main path to all parts required for MSUnit to work
- **tests** - Local path to tests
- **localPackages** - Local path to script, that runs before running tests
- **resource** - Local path to resource, that are available by calling a procedure `_unit_resource('folder.file.yml')`
- **groups** - Local path to map "test - groups"
- **filter** - folders and scripts containing filter are not considered scripts
- **outs** - log output objects

Only root should contain the full path, the rest are local from it!

You can use the default log output methods:

- proc `_unit_get_default_outs(string path_to_log, [array filters = array('message', 'test_log', 'user_log')])`

For example:

```ms
_unit_register_module(associative_array(
    id: 'unit',
    root: get_absolute_path('test'),
    groups: 'tests.properties',
    outs: _unit_get_default_outs(get_absolute_path('logs'), array('test_log')),
    filter: '-ignore'
))
```

>For details see [register.ms](register.ms)

Put your test scripts in a "root". Test scripts may contain only procedures, which are of three types:

- Before all \[prefix=`_before_all`\]

  The procedure is performed before all tests. May be only one in script.

- Before each \[prefix=`_before_each`\]

  The procedure is performed before each tests. May be only one in script.

- Test \[prefix=`_test`\]

  The procedure is test.

- After all \[prefix=`_after_all`\]

  The procedure is performed after all tests. May be only one in script.

- After each \[prefix=`_after_each`\]

  The procedure is performed after each tests. May be only one in script.

The names of the procedures can only match if they are in different scripts.

Before starting the tests, you need to initialize the settings with the command:

>unit \<module\> -init

After running the tests themselves with the command:

>unit \<module\>

Test logs will be displayed in the console and in the file "path_to_log" if you used `_unit_get_default_outs()`.

Some options can be changed in the setting.yml script.

***

## API

### Commands

- unit \<module\> <-command> \<args=all\> <-command> \<args\>...

  - test \<args\> - Runs the groups of tests indicated in \<args\>
  - init \<args=all\> - Creates configuration file of groups of tests, giving them the default group specified in the arguments.
  - update \<args=all\> - Updates the configuration file of groups of tests (leaving the previous settings), giving new tests the default group specified in the arguments.
  - run \<args\> - Recompiles and runs the groups of tests indicated in \<args\>.

> Default command: unit \<module\> -> unit \<module\> -update all -run all

### Assertions

- `_assert_true_obj(Booleanish o, [mixed msg])`
- `_assert_false_obj(Booleanish o, [mixed msg])`
- `_assert_true(boolean bool, [mixed msg])`
- `_assert_false(boolean bool, [mixed msg])`
- `_assert_null(mixed object, [mixed msg])`
- `_assert_not_null(mixed object, [mixed msg])`
- `_assert_equals(mixed exp, mixed act, [mixed msg])`
- `_assert_not_equals(mixed arg1, mixed arg2, [mixed msg])`
- `_assert_size(int size, Sizeable arr, [mixed msg])`
- `_assert_length(int length, mixed act, [mixed msg])`
- `_assert_empty(mixed object, [mixed msg])`
- `_assert_not_empty(mixed object, [mixed msg])`
- `_assert_type(ClassType type, mixed object, [mixed msg])`
- `_assert_proc_throw(ClassType type, string proc_name, [mixed msg])`
- `_assert_execute_throw(ClassType type, closure lymda, [mixed msg])`
- `_assert_proc_array_throw(ClassType type, string proc_name, array args, [mixed msg])`
- `_assert_execute_array_throw(ClassType type, closure lymda, array args, [mixed msg])`
- `_assert_key_exist(string key, array array, [mixed msg])`
- `_assert_key_not_exist(string key, array array, [mixed msg])`

### Supporting Procedures

- `_print(mixed msg)`
- `_println([mixed msg])`
- `_sleep(int seconds)`
- `_skip_test()`
- `_assert_time_assert(int seconds)`
- `_assert_time_proc(int seconds)`
- `_assert_restart_time()`
- `_assert_restart_time_all()`
- `_assert_time(int seconds)`
- `_assert_time_limit(number successful_time, number attention_time)`
- `_x_safe(closure lymda)`

***

## Recuired

- Extensions:
  - [CHCadabra](https://github.com/Community-Cadabra-Project/CHCadabra)

- Libraries:
  - [MSUtil](https://github.com/Community-Cadabra-Project/MSUtil)
