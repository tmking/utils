#!/bin/zsh

typeset -A rails_dirs
devdir=$HOME/Development

function echo_info() {
  if [[ $using_rbenv == 1 ]]; then
    echo "Using ruby $(rbenv version)"
  elif [[ $using_rvm == 1 ]]; then
    echo -e "=> Using gems from $(rvm info | grep gem: | grep -v bin | tr -d '[:blank:]' | cut -d':' -f2)\n"
  fi
}

function server_cmd() {
  if [[ -e ./config.ru ]]; then
    bundle exec rails server $@
  else
    ./script/server $@
  fi
}

function run_server() {
  if [[ -x ./script/logsanitize ]]; then
    server_cmd $@ 2>&1 | ./script/logsanitize
  else
    server_cmd $@
  fi
}

function get_rails_dirs() {
  dirs=( $devdir/*/app(N) $devdir/*/*/app(N) $devdir/*/*/*app(N) )

  for d in $dirs; do
    local parent=${d%/*}
    rails_dirs[$parent:t]=$parent
  done
}

function help() {
  cat <<EOF
  usage: ${0%*/} <project>
         ${0%*/} <command>
  commands:
    --help (this message)
    --list (list avaialble projects)
EOF
}

function check_target() {
  if [ $rails_dirs[$target] ]; then
    return 0
  else
    echo "No such project: $target"
    exit 136
  fi
}

if [ -z "$1" ]; then
  help && exit 127
fi

get_rails_dirs

case $1 in
  *help|-h)
    help
    ;;
  *list|-l)
    echo ${(k)rails_dirs}; exit 0
    ;;
  *)
    target=$1; shift
esac

check_target

if [[ -x $HOME/.rbenv/bin ]]; then
  eval "$(rbenv init -)"
  using_rbenv=1
elif [[ -x $HOME/.rvm/scripts/rvm ]]; then
  . $HOME/.rvm/scripts/rvm
  using_rvm=1
fi


( cd $rails_dirs[$target] && echo_info; run_server $@ )
