# Usage:
#   Source this script from your Bash start-up script (eg. ~/.bashrc, ~/.bash_profile).
tab_random() {
    r=$RANDOM
    r=$((r%255))
    g=$RANDOM
    g=$((g%255))
    b=$RANDOM
    b=$((b%255))
    printf "Tab Color to %s %s %s\n" "$r" "$g" "$b"
    tab_color $r $g $b
}

tab_color() {
  echo -n -e "\033]6;1;bg;red;brightness;$1\a"
  echo -n -e "\033]6;1;bg;green;brightness;$2\a"
  echo -n -e "\033]6;1;bg;blue;brightness;$3\a"
}
