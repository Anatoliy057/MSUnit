include('constants.ms')

if (!file_exists(@UNIT_PATH_MSG)) {
    console("MSUnit: [FATAL] file '@{UNIT_PATH_MSG}' of msgs doesn't exist.\nSure that path is correct.", false)
    die()
} else {
    export('__UNIT_MSG', json_decode(read(@UNIT_PATH_MSG)))
}