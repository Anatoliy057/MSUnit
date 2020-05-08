if (!file_exists(@UNIT_PATH_MSG)) {
    console("CHUnit: [FATAL] file '@{UNIT_PATH_MSG}' of msgs doesn't exist\n\t\t\t\tSure that path is correct.")
    die()
} else {
    export('__unit_msg', json_decode(read(@UNIT_PATH_MSG)))
}

export('__unit_synchron', array())
export('__unit_test_log', array())