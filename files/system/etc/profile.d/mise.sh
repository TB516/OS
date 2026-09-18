# Include these before installation finishes so new commands can find mise.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
case ":$PATH:" in
    *":${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims:"*) ;;
    *) PATH="${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims:$PATH" ;;
esac
export PATH

if [ -n "${BASH_VERSION:-}" ] && [ -x "$HOME/.local/bin/mise" ]; then
    case $- in
        *i*) eval "$("$HOME/.local/bin/mise" activate bash)" ;;
    esac
fi
