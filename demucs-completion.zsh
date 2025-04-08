#compdef _demucs demucs

_demucs() {
    local -a options
    options=(
        '1:first argument:->input'
        '2:second argument:->output'
    )

    _arguments -C $options

    case $state in
        input)
            _files -g "*.mp3 *.wav *.flac *.m4a"
            ;;
        output)
            _files -/
            ;;
    esac
} 