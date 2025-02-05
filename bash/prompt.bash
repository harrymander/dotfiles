# shellcheck shell=bash

# Customises the bash prompt

# Source this file in your .bashrc

function _is_in_git_tree() {
    [[ "$(2>/dev/null git rev-parse --is-inside-work-tree)" = "true" ]]
}

function _git_has_modified_tracked_files() {
    ! git diff-files --quiet
}

function _git_has_untracked_files() {
    [[ $(git -C "$1" ls-files --others --exclude-standard) ]]
}

function _git_has_unmerged_files() {
    [[ $(git -C "$1" ls-files --unmerged) ]]
}

function _git_get_tracked_branch() {
    2>/dev/null git rev-parse --abbrev-ref --symbolic-full-name "@{u}"
}

function _git_has_staged_files() {
    ! git diff --cached --quiet
}

function _git_is_rebasing() {
    [[ -d "$(git rev-parse --git-path rebase-apply)" || -d "$(git rev-parse --git-path rebase-merge)" ]]
}

export VIRTUAL_ENV_DISABLE_PROMPT=1

function _update_ps1() {
    local retcode=$?

    if [[ -z "$BASH_PROMPT_DISABLE_COLOR" ]]; then
        local NOCOL="\[\033[00m\]"
        local BGREEN="\[\033[01;32m\]"
        local BBLUE="\[\033[01;34m\]"
        local RED="\[\033[0;31m\]"
        local YELLOW="\[\033[0;33m\]"
    fi

    PS1="$BASH_PROMPT_PREFIX"

    # Set terminal title = "[username]@[hostname]:[path]"
    PS1+="\[\e]0;\u@\h:\w\a\]"

    # Number of jobs
    local jobs
    jobs="$(jobs | grep --count --invert-match '\\command zoxide add -- "\${__zoxide_oldpwd}"$')"
    if [[ "${jobs}" -ne 0 ]]; then
        PS1+="[${jobs}] "
    fi

    # virtualenv
    if [[ "$VIRTUAL_ENV" ]]; then
        if [[ "$VIRTUAL_ENV_PROMPT" ]]; then
            if [[ "$VIRTUAL_ENV_PROMPT" =~ ^\(.+?\)\ $ ]]; then
                PS1+=$VIRTUAL_ENV_PROMPT
            else
                PS1+="($VIRTUAL_ENV_PROMPT) "
            fi
        else
            PS1+="($(basename -- "$VIRTUAL_ENV")) "
        fi
    fi

    # conda env
    PS1+="${CONDA_DEFAULT_ENV:+(🐍 $CONDA_DEFAULT_ENV) }"

    # chroot info
    PS1+="${debian_chroot:+($debian_chroot)}"

    # "[username]@[hostname]:[path]"
    PS1+="${BASH_PROMPT_USER_HOST_PREFIX}${BGREEN}\u@\h${NOCOL}:${BBLUE}\w${NOCOL}"

    # Show git info
    if [[ -n "${BASH_PROMPT_SHOW_GIT}" ]] && _is_in_git_tree; then
        ! _git_is_rebasing
        local not_rebasing=$?

        local current_color
        local git_topdir
        git_topdir=$(git rev-parse --show-toplevel)
        if _git_has_unmerged_files "$git_topdir" || [[ "$not_rebasing" -ne 0 ]]; then
            PS1+="${YELLOW}"
            current_color="${YELLOW}"
        else
            current_color="${NOCOL}"
        fi

        local branch
        branch=$(git branch --show-current)
        PS1+=" ("
        if [[ "$not_rebasing" -ne 0 ]]; then
            PS1+="rebasing "
        fi
        PS1+="${branch:-detached@$(git rev-parse --short HEAD)}"

        if _git_has_modified_tracked_files; then
            PS1+="*"
        fi
        if _git_has_untracked_files "$git_topdir"; then
            PS1+="?"
        fi
        if _git_has_staged_files; then
            PS1+="+"
        fi

        # Show commits ahead/behind of remote
        local tracked_branch
        if [[ "$branch" ]] && tracked_branch=$(_git_get_tracked_branch); then
            local ahead
            local behind
            ahead=$(2>/dev/null git rev-list --count "@{upstream}"..)
            behind=$(2>/dev/null git rev-list --count .."@{upstream}")
            if [[ "${ahead:-0}" -ne 0 && "${behind:-0}" -ne 0 ]]; then
                PS1+=" ${YELLOW}+${ahead}/-${behind}:${tracked_branch}${current_color}"
            elif [[ "${ahead:-0}" -ne 0 ]]; then
                PS1+=" +${ahead}:${tracked_branch}"
            elif [[ "${behind:-0}" -ne 0 ]]; then
                PS1+=" -${behind}:${tracked_branch}"
            fi
        elif [[ "$branch" ]]; then
            PS1+=" [not tracked]"
        fi

        # Show number of stashes
        local stash
        stash=$(git stash list | wc -l)
        if [[ "${stash}" -ne 0 ]]; then
            PS1+=" stash=${stash}"
        fi

        PS1+=")${NOCOL} "
    fi

    # Show previous returncode if non-zero
    if [[ "$retcode" -ne 0 ]]; then
        PS1+="${RED}[$retcode]"
    fi
    PS1+="\\$"
    PS1+="$NOCOL "
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
