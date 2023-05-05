#!/bin/sh
# Usage: pullall [DIRECTORY]
#
# Performs 'git pull' on several repositories under the given DIRECTORY.
source ~/.dotfiles/shell/colors.sh
source ~/.dotfiles/shell/functions.sh

untracked_files() {
  [[ -n $(git status -s) ]]
}

branch_exists() {
  [ $(git rev-parse --verify -q $1) ]
}

show_pulling_message() {
  printf "${Yellow}Pulling ${Cyan}$1${Yellow} at ${UYellow}${dir%?}${ColorOff} "
}

pull_at_main_branch() {
  stashed_files=false

  if untracked_files; then
    git stash save --include-untracked -q
    stashed_files=true
  fi

  if branch_exists main; then
    git switch main -q
  else
    git switch master -q
  fi

  git pull -q
  git switch - -q

  if $stashed_files; then
    git stash pop -q
  fi
}

pull_at_develop_branch() {
  stashed_files=false

  if untracked_files; then
    git stash save --include-untracked -q
    stashed_files=true
  fi

  if branch_exists develop; then
    git switch develop -q
  fi

  git pull -q
  git switch - -q

  if $stashed_files; then
    git stash pop -q
  fi
}

update_main_branch() {
  if branch_exists main; then
    show_pulling_message "main"
  else
    show_pulling_message "master"
  fi

  pushd $dir > /dev/null
  pull_at_main_branch & spinner
  popd > /dev/null
}

update_develop_branch() {
  show_pulling_message "develop"

  pushd $dir > /dev/null
  pull_at_develop_branch & spinner
  popd > /dev/null
}

for repo in $(ls -d -1 ../*/.git 2>/dev/null); do
  dir=${repo/\/.git//}

  update_main_branch

  if branch_exists develop; then
    update_develop_branch
  fi
done
