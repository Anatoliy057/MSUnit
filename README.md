# Command Helper Scripts: Unit

>Unit test library.

***

## Using

To connect the module, just connect main.ms.

Put your test scripts in a folder './test/'. Test scripts may contain only procedures, which are of three types:

- Before all [prefix='_unit_before_all']

  The procedure is performed before all tests. May be only one in script.

- Before each [prefix='_unit_before_each']

  The procedure is performed before each tests. May be only one in script.

- Test [prefix='_unit_test']

  The procedure is test.

Before starting the tests, you need to initialize the settings with the command:

>unit -init

After running the tests themselves with the command:

>unit

Test logs will be displayed in the console and in the file './logs/log.txt'.

Some options can be changed in the constans.ms script.

***

## API

### Commands

- unit <-command=run> \<args=all\> <-command> \<args\>...

  - run \<args\> - Runs the groups of tests indicated in \<args\>
  - init \<args=all\> - Creates configuration file of groups of tests, giving them the default group specified in the arguments
  - update \<args=all\> - Updates the configuration file of groups of tests (leaving the previous settings), giving new tests the default group specified in the arguments

### Assertions

- _assert_true(boolean @bool)
- _assert_false(boolean @bool)
- _assert_null(mixed @object)
- _assert_not_null(mixed @object)
- _assert_equals(mixed @exp, mixed @act)
- _assert_not_equals(mixed @arg1, mixed @arg2)
- _assert_size(int @size, array @arr)
- _assert_length(int @length, mixed @act)
- _assert_empty(mixed @object)
- _assert_not_empty(mixed @object)
- _assert_type(string @type, mixed @object)
- _assert_proc_throw(string @classType, string @proc_name)
- _assert_closure_throw(string @classType, closure @lymda)
- _assert_proc_does_not_throw(string @proc_name)
- _assert_closure_does_not_throw(closure @lymda)

***

## Recuired

- Extensions:
  - [CHFiles](https://letsbuild.net/jenkins/job/CHFiles/)
  - [CHThreads](https://github.com/Community-Cadabra-Project/CHThreads)

- Libraries:
  - [Util](https://github.com/Community-Cadabra-Project/CHUtil)
