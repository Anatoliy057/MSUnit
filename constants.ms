@UNIT_PATH_MSG = 'message.json'

@UNIT_COMMAND_INIT = 'init'
@UNIT_COMMAND_RUN = 'run'
@UNIT_COMMAND_UPDATE = 'update'

@UNIT_COMMAND_START = 'start'

@UNIT_GROUP_DEL = '|'
@UNIT_DEFAULT_GROUP = 'all'

@UNIT_SETTING = array(
    'assert_timeout' : 5,
    'proc_timeout' : 10,
    'number_threads' : 4,
    'pref_test_proc' : '_unit_test',
    'pref_before_proc' : '_unit_before_each',
    'pref_test_init_proc' : '_unit_before_all'    
)