# Commands to run in interactive sessions can go here
if status is-interactive
    # No greeting
    set fish_greeting

    # Use starship
    function starship_transient_prompt_func
        starship module character
    end
    if test "$TERM" != linux
        starship init fish | source
        enable_transience
    end

    # Colors
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # Aliases
    # kitty doesn't clear properly so we need to do this weird printing
    alias clear "printf '\033[2J\033[3J\033[1;1H'"
    alias celar "printf '\033[2J\033[3J\033[1;1H'"
    alias claer "printf '\033[2J\033[3J\033[1;1H'"
    alias pamcan pacman
    alias q 'qs -c ii'
    if test "$TERM" != linux
        alias ls 'eza --icons'
    end
    if test "$TERM" = xterm-kitty
        alias ssh 'kitten ssh'
    end

    alias qmk-flash-totem='dolphin &; qmk flash -kb geigeigeist/totem -km hamihu -bl uf2-split-left && qmk flash -kb geigeigeist/totem -km hamihu -bl uf2-split-right'
    zoxide init fish | source

    # opencode
    fish_add_path /home/hamihu/.opencode/bin

    source ~/.config/fish/conf.d/custom.fish

    # set the default editor
    set -gx EDITOR nvim
end
