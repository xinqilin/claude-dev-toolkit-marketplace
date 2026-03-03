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

remove_links_for_plugin() {
    local plugin="$1"
    local plugin_dir="$REPO_DIR/plugins/$plugin"

    echo ""
    echo "Uninstalling: $plugin"

    # Remove agent symlinks
    if [[ -d "$plugin_dir/agents" ]]; then
        for agent_file in "$plugin_dir/agents/"*.md; do
            [[ -f "$agent_file" ]] || continue
            local dst="$AGENTS_DIR/$(basename "$agent_file")"
            if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$agent_file" ]]; then
                echo "  [remove] $(basename "$dst")"
                rm "$dst"
            fi
        done
    fi

    # Remove skill symlinks
    if [[ -d "$plugin_dir/skills" ]]; then
        for skill_dir in "$plugin_dir/skills"/*/; do
            [[ -d "$skill_dir" ]] || continue
            local skill_name
            skill_name="$(basename "$skill_dir")"
            local dst="$SKILLS_DIR/$skill_name"
            if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$skill_dir" ]]; then
                echo "  [remove] $skill_name"
                rm "$dst"
            fi
        done
    fi
}

main() {
    for plugin in "${PLUGINS[@]}"; do
        remove_links_for_plugin "$plugin"
    done

    echo ""
    echo "Done. All plugin symlinks removed."
}

main "$@"
