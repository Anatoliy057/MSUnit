execute(closure() {
    @root = file_resolve('./src/main/ms')
    @rootResourse = file_resolve('./src/main/resourse')

    export('MSUNIT', associative_array(
        root: @root,
        rootResourse: @rootResourse
    ))
})

