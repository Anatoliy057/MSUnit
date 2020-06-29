include('constants.ms')

if (!file_exists(@UNIT_PATH_MSG)) {
    console("MSUnit: [FATAL] file '@{UNIT_PATH_MSG}' of msgs doesn't exist.\nSure that path is correct.", false)
    die()
} else {
    export('org.cadabra.msunit.message', json_decode(read(@UNIT_PATH_MSG)))
}