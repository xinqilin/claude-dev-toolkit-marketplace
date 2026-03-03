#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"
SKILLS_DIR="$CLAUDE_DIR/skills"

PLUGINS=(
    "bill-billing-unit-test-reviewer"
    "bill-code-reviewer"
    "bill-java-developer"
    "bill-java-skills"
)

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --all                Install all plugins
  --plugin <name>      Install a specific plugin
  --list               List available plugins
  -h, --help           Show this help

Available plugins:
$(for p in "${PLUGINS[@]}"; do echo "  - $p"; done)

Examples:
  $0 --all
  $0 --plugin bill-code-reviewer
  $0 --list
EOF
}

list_plugins() {
    echo "Available plugins:"
    for plugin in "${PLUGINS[@]}"; do
        local plugin_dir="$REPO_DIR/plugins/$plugin"
        local has_agents=false
        local has_skills=false

        [[ -d "$plugin_dir/agents" ]] && has_agents=true
        [[ -d "$plugin_dir/skills" ]] && has_skills=true

        echo "  $plugin"
        $has_agents && echo "    agents: $(ls "$plugin_dir/agents/"*.md 2>/dev/null | xargs -I{} basename {} | tr '\n' ' ')"
        $has_skills && echo "    skills: $(ls -d "$plugin_dir/skills"/*/ 2>/dev/null | xargs -I{} basename {} | tr '\n' ' ')"
    done
}

link_file() {
    local src="$1"
    local dst="$2"
    local name
    name="$(basename "$src")"

    if [[ -L "$dst" ]]; then
        local existing_target
        existing_target="$(readlink "$dst")"
        if [[ "$existing_target" == "$src" ]]; then
            echo "  [skip] $name (already linked)"
            return
        fi
        echo "  [update] $name"
        ln -sf "$src" "$dst"
    elif [[ -e "$dst" ]]; then
        echo "  [warn] $name exists but is not a symlink, skipping"
    else
        echo "  [link] $name"
        ln -sf "$src" "$dst"
    fi
}

install_plugin() {
    local plugin="$1"
    local plugin_dir="$REPO_DIR/plugins/$plugin"

    if [[ ! -d "$plugin_dir" ]]; then
        echo "Error: Plugin '$plugin' not found in $REPO_DIR/plugins/"
        exit 1
    fi

    echo ""
    echo "Installing: $plugin"

    # Install agents
    if [[ -d "$plugin_dir/agents" ]]; then
        for agent_file in "$plugin_dir/agents/"*.md; do
            [[ -f "$agent_file" ]] || continue
            link_file "$agent_file" "$AGENTS_DIR/$(basename "$agent_file")"
        done
    fi

    # Install skills
    if [[ -d "$plugin_dir/skills" ]]; then
        for skill_dir in "$plugin_dir/skills"/*/; do
            [[ -d "$skill_dir" ]] || continue
            local skill_name
            skill_name="$(basename "$skill_dir")"
            link_file "$skill_dir" "$SKILLS_DIR/$skill_name"
        done
    fi
}

install_all() {
    for plugin in "${PLUGINS[@]}"; do
        install_plugin "$plugin"
    done
}

main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi

    mkdir -p "$AGENTS_DIR" "$SKILLS_DIR"

    local cmd=""
    local target_plugin=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                cmd="all"
                shift
                ;;
            --plugin)
                cmd="plugin"
                target_plugin="$2"
                shift 2
                ;;
            --list)
                cmd="list"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    case "$cmd" in
        all)
            install_all
            echo ""
            echo "Done. All plugins installed."
            echo "Agents -> $AGENTS_DIR"
            echo "Skills -> $SKILLS_DIR"
            ;;
        plugin)
            if [[ -z "$target_plugin" ]]; then
                echo "Error: --plugin requires a plugin name"
                usage
                exit 1
            fi
            install_plugin "$target_plugin"
            echo ""
            echo "Done. Plugin '$target_plugin' installed."
            ;;
        list)
            list_plugins
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
