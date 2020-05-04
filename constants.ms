@UNIT_PATH_SETTING = "tests.properties"
@UNIT_PATH_TEST = "test"
@UNIT_PATH_MSG = 'message.json'

@UNIT_COMMAND_PREFIX = "-"
@UNIT_COMMAND_INIT = 'init'
@UNIT_COMMAND_START = 'run'
@UNIT_COMMAND_UPDATE = 'update'

@UNIT_SETTING = array(
    'assert_timeout' : 15,
    'proc_timeout' : 30,
    'number_threads' : 4,
    'pref_test_proc' : "_unit_test_",
    'pref_before_proc' : "_unit_before_all",
    'pref_test_init_proc' : "_unit_before_each_"    
)

@UNIT_PATH_LOG = 'logs/log.txt'

@UNIT_CONSOLE_OUT = array(
    'enable' : true,
    'short' : true,
    'write' : closure(@text) {
        console(@text)
    }
)

@UNIT_FILE_OUT = array(
    'enable' : true,
    'short' : false,
    'write' : closure(@text) {
        write_file(@UNIT_PATH_LOG, @text, 'OWERWRITE')
    }
)

if (import('script_log')) {
    console('CHUnit: constans.ms loaded')
}
