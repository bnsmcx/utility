# ZSH Theme - Preview: https://cl.ly/f701d00760f8059e06dc
# Thanks to gallifrey, upon whose theme this is based

local return_code="%(?..%{$fg_bold[red]%}%? ↵%{$reset_color%})"

function my_git_prompt_info() {
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(git_current_branch) $(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# Modify PROMPT to include Git info on a new line
PROMPT='%B%{$fg_bold[green]%}╭─ %b%{$fg_bold[blue]%}%2~%{$reset_color%} $(my_git_prompt_info)
%B%{$fg_bold[green]%}╰─$ %b'


# Optionally, keep the return code on the right side of the first line if desired
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
