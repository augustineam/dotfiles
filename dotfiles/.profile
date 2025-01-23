# Append our default paths
appendpath() {
    case ":$PATH:" in
	    *:"$1":*)
            ;;
    *)
            PATH="${PATH+$PATH}:$1"
    esac
}

nonzero_return() {
    [ $? -ne 0 ] && echo "$?"
}

# get current branch in git repo
parse_git_branch() {
    branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    if [[ -n $branch ]]; then
        stat=$(parse_git_dirty)
        echo "[${branch}${stat}]"
    fi
}

# get current status of git repo
parse_git_dirty() {
    git_status=$(git status 2>&1 | tee)
    dirty=$(echo -n "${git_status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?")
    untracked=$(echo -n "${git_status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?")
    ahead=$(echo -n "${git_status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?")
    newfile=$(echo -n "${git_status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?")
    renamed=$(echo -n "${git_status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?")
    deleted=$(echo -n "${git_status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?")
    bits=''
    if [ "${renamed}" = "0" ]; then
        bits=">${bits}"
    fi
    if [ "${ahead}" = "0" ]; then
        bits="*${bits}"
    fi
    if [ "${newfile}" = "0" ]; then
        bits="+${bits}"
    fi
    if [ "${untracked}" = "0" ]; then
        bits="?${bits}"
    fi
    if [ "${deleted}" = "0" ]; then
        bits="x${bits}"
    fi
    if [ "${dirty}" = "0" ]; then
        bits="!${bits}"
    fi
    if [ ! "${bits}" = "" ]; then
        echo " ${bits}"
    else
        echo ""
    fi
}

alias grep='grep --color=auto'

eval "$(micromamba shell hook --shell bash)"

# pnpm
export PNPM_HOME="/home/augus/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
