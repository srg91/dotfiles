# vi:syntax=zsh
export VIRTUAL_ENV_DISABLE_PROMPT="true"

_ZERO='%([BSUbfksu]|([FB]|){*})'
_BRACKETS="%%F{8}[%%f %s %%F{8}]%%f"
 
_theme_get_current_dir()
{
    if [ -z "$COLUMNS" ]; then
        return
    fi

    local DIR="$(print -P "%~")"
    local LEN="${#DIR}"

    DIR="%F{1}%$([ "$((( 100 * $LEN / $COLUMNS )))" -ge 50 ] && echo 1)~%f"
    echo $(printf $_BRACKETS $DIR)
}

_theme_get_venv_name() 
{
    local VENV=""
    if [ -n "$VIRTUAL_ENV" ]; then
        VENV="%F{2}$(basename "$VIRTUAL_ENV")%f"
        VENV=$(printf $_BRACKETS $VENV)
        echo "$VENV"
    fi
}

_theme_add_widgets()
{
    local curlen="$COLUMNS"
    local widgets=
    widgets=("${(@)@}")

    if [ -z "$widgets" ]; then
        return
    fi

    while [ -n "$widgets" ]; do
        local widgets_str=""
        for widget in "$widgets[@]"; do
            widgets_str="$widgets_str$widget"
        done

        local len="${#${(S%%)widgets_str//$~_ZERO/}}"
        (( len = curlen - len ))
        if [ $len -ge 0 ]; then
            echo "$len"
            for widget in "$widgets[@]"; do
                echo "$widget"
            done
            return
        else
            widgets=("${(@)widgets[1,-2]}")
        fi
    done
}
 
_theme_precmd()
{
    vcs_info 2> /dev/null

    local DIR="$(_theme_get_current_dir)"
    local TIME="$(printf $_BRACKETS "%F{13}%T%f")"
    local VENV="$(_theme_get_venv_name)"
    local VCS="${vcs_info_msg_0_}"
    local LEN=

    local RESULT=
    RESULT=("${(@f)$(_theme_add_widgets "$DIR" "$TIME" "$VENV" "$VCS")}")
    LEN="$RESULT[1]"
    DIR="$RESULT[2]"
    TIME="$RESULT[3]"
    VENV="$RESULT[4]"
    VCS="$RESULT[5]"

    print
    if [ "$LEN" -gt 0 ]; then
        if [ -n "${VENV}${DIR}${VCS}${TIME}" ]; then
            local SPACES="$(printf ' '%.0s {1..$LEN})"
            print -rP "${VENV}${DIR}${SPACES}${VCS}${TIME}"
        fi
    fi
    
}

+vi-hg-add-tags()
{
    local hg_tags_cache="${hook_com[base]}/.hg/cache/tags2-visible"
    local hg_tags=""

    if [ ! -f "$hg_tags_cache" ]; then
        hg_tags=`HOME=/ hg id -t`
    else
        local hg_rev=`HOME=/ hg id -i --debug | tr -d '+'`
        hg_tags=`grep -F $hg_rev $hg_tags_cache | cut -f2 -d' '`

        if [[ "$hg_tags" == "$hg_rev" ]]; then
            if [[ "`head -n1 $hg_tags_cache | cut -f2 -d' '`" == "$hg_rev" ]]; then
                hg_tags="tip"
            else
                hg_tags=""
            fi
        fi
    fi
    
    if [ -n "$hg_tags" ]; then
        hook_com[branch]="${hook_com[branch]}%F{8}/%f%F{5}$hg_tags%f"
    fi
}

PROMPT="%(!.%F{9}%B#%b%f.)%(!.%B.)>%(!.%b.) "

autoload -U add-zsh-hook vcs_info
add-zsh-hook precmd _theme_precmd

zstyle ':vcs_info:hg*+set-message:*' hooks hg-add-tags

zstyle ':vcs_info:*' enable hg git svn
zstyle ':vcs_info:(git*|hg*):*' check-for-changes true

# Turn on changes at mercurial, 
# but, also, turn on the slooow moootioon at big repos
# zstyle ':vcs_info:hg*' get-revision true

# branch+tags+changes misc
zstyle ':vcs_info:(hg*|git*|svn*)' formats "%F{8}[ %s:%f%F{2}%b%f%u %F{8}]%f"
zstyle ':vcs_info:(hg*|git*|svn*)' actionformats "%F{8}[ %s:%f%F{2}%b%f%F{8}:%f%F{1}%a%f%u %F{8}]%f"

zstyle ':vcs_info:hg*:netbeans' use-simple true

zstyle ':vcs_info:(hg*|git*|svn*):*' stagedstr "%F{9}!%f"
zstyle ':vcs_info:(hg*|git*|svn*):*' unstagedstr "%F{9}*%f"
zstyle ':vcs_info:hg*:*' hgrevformat "%r"
zstyle ':vcs_info:hg*:*' branchformat "%b"

