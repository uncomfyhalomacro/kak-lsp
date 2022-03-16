#!/bin/sh

# REQUIRES: command -v pyright-langserver

. test/lib.sh

cat > .config/kak-lsp/kak-lsp.toml << EOF
[language.python]
filetypes = ["python"]
roots = ["pyrightconfig.json", "requirements.txt", "setup.py", ".git", ".hg"]
command = "pyright-langserver"
args = ["--stdio"]
EOF

cat > main.py << EOF
def foo() -> int:
    return 5

print(foo())
EOF

test_tmux_kak_start 'edit main.py'
test_tmux send-keys gj / foo Enter gd
test_sleep
test_tmux send-keys 'i%()' Escape

test_tmux capture-pane -p
# CHECK: def %()foo() -> int:
# CHECK:     return 5
# CHECK:
# CHECK: print(foo())
# CHECK: ~
# CHECK: ~
# CHECK: main.py 1:8 [+] 1 sel - client0@[session]
