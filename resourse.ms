execute(closure() {
    if (!file_exists('message.json')) {
        console("MSUnit: [FATAL] file 'message.json' of msgs doesn't exist.\nSure that path is correct.", false)
        die()
    } else {
        export('org.cadabra.msunit.message', json_decode(read('message.json')))
    }
})