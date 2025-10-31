  # function fish_greeting
  #   echo -ne '\x1b[38;2;180;184;193m'
  #   echo ''
  #   echo ''
  #   echo '    ██████   █████           █████                      '
  #   echo '    ▒▒██████ ▒▒███           ▒▒███                       '
  #   echo '     ▒███▒███ ▒███   ██████  ███████    █████  █████ ████'
  #   echo '     ▒███▒▒███▒███  ███▒▒███▒▒▒███▒    ███▒▒  ▒▒███ ▒███ '
  #   echo '     ▒███ ▒▒██████ ▒███ ▒███  ▒███    ▒▒█████  ▒███ ▒███ '
  #   echo '     ▒███  ▒▒█████ ▒███ ▒███  ▒███ ███ ▒▒▒▒███ ▒███ ▒███ '
  #   echo '     █████  ▒▒█████▒▒██████   ▒▒█████  ██████  ▒▒███████ '
  #   echo '    ▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒     ▒▒▒▒▒  ▒▒▒▒▒▒    ▒▒▒▒▒███ '
  #   echo '                                                ███ ▒███ '
  #   echo '                                               ▒▒██████  '
  #   echo '                                                ▒▒▒▒▒▒   '
  #   set_color normal
  # end
    # fastfetch --key-padding-left 20
function fish_greeting
    # Set the color for the banner
    echo -ne '\x1b[38;2;180;184;193m'
    echo '' # Add a blank line above the banner

    # Store all banner lines in a list
    set banner_lines \
        '    ██████   █████           █████              ' \
        '    ▒▒██████ ▒▒███           ▒▒███                ' \
        '     ▒███▒███ ▒███   ██████  ███████     █████  █████ ████' \
        '     ▒███▒▒███▒███  ███▒▒███▒▒▒███▒     ███▒▒  ▒▒███ ▒███ ' \
        '     ▒███ ▒▒██████ ▒███ ▒███  ▒███     ▒▒█████  ▒███ ▒███ ' \
        '     ▒███  ▒▒█████ ▒███ ▒███  ▒███ ███  ▒▒▒▒███ ▒███ ▒███ ' \
        '     █████  ▒▒█████▒▒██████    ▒▒█████  ██████  ▒▒███████ ' \
        '    ▒▒▒▒▒    ▒▒▒▒▒  ▒▒▒▒▒▒      ▒▒▒▒▒  ▒▒▒▒▒▒    ▒▒▒▒▒███ ' \
        '                                                 ███ ▒███ ' \
        '                                                 ▒▒██████  ' \
        '                                                  ▒▒▒▒▒▒    '

    # 1. Find the width of the widest line in the banner
    set max_width 0
    for line in $banner_lines
        set line_width (string length -- "$line")
        if [ $line_width -gt $max_width ]
            set max_width $line_width
        end
    end

    # 2. Get the current terminal width
    set term_width (tput cols)

    # 3. Calculate the required padding
    # (We use 'max(0, ...)' to prevent errors if the terminal is too small)
    set padding_width (math -s0 "max(0, ($term_width - $max_width) / 2)")

    # 4. Create the padding string
    set padding (printf "%*s" $padding_width "")

    # 5. Print each line, prepended with the padding
    for line in $banner_lines
        echo "$padding$line"
    end

    echo '' # Add a blank line below the banner
    set_color normal
    # fastfetch --key-padding-left 20
end
