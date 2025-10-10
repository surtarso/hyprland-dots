# === ssh-agent auto-start for Fish ===
# Reuses one ssh-agent per user and ensures keys persist across terminals.

if not status is-interactive
    exit
end

if not type -q ssh-agent
    exit
end

set -l envfile ~/.cache/ssh-agent.fish

# Try to load saved environment if available
if test -f $envfile
    source $envfile
end

function __ssh_agent_start --description "Start ssh-agent and save env"
    echo "🔑 Starting new ssh-agent..."
    eval (ssh-agent -c) | tee $envfile >/dev/null
end

# --- Reuse logic ---
# 1. Check if we have a valid SSH_AUTH_SOCK file and if agent process is running.
set -l need_start 0

if not set -q SSH_AUTH_SOCK
    set need_start 1
else if not test -S "$SSH_AUTH_SOCK"
    set need_start 1
else
    # Validate that the PID from the envfile actually exists and belongs to this user
    if not set -q SSH_AGENT_PID
        set need_start 1
    else if not test -d "/proc/$SSH_AGENT_PID"
        set need_start 1
    end
end

# If no valid agent found, check if any agent exists for this user and reuse it
if test $need_start -eq 1
    set -l existing (pgrep -u (whoami) ssh-agent | head -n1)
    if test -n "$existing"
        set -l sock (find /tmp -type s -user (whoami) -path "*/agent.*" 2>/dev/null | head -n1)
        if test -n "$sock"
            set -gx SSH_AGENT_PID $existing
            set -gx SSH_AUTH_SOCK $sock
            echo "♻️ Reusing existing ssh-agent PID $existing"
            printf 'set -gx SSH_AUTH_SOCK %s\nset -gx SSH_AGENT_PID %s\n' $sock $existing > $envfile
            set need_start 0
        end
    end
end

# If still nothing valid, start a new one
if test $need_start -eq 1
    __ssh_agent_start
end

# --- Auto-add keys if none loaded ---
if type -q ssh-add
    ssh-add -l >/dev/null 2>&1
    if test $status -ne 0
        for key in id_ed25519 id_rsa id_ecdsa id_dsa id_ed25519_solid
            if test -f ~/.ssh/$key
                ssh-add ~/.ssh/$key >/dev/null 2>&1
            end
        end
    end
end
