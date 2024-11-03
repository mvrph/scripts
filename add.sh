#!/bin/bash

add() {
    # Check if at least two arguments are provided
    if [ $# -lt 2 ]; then
        echo "Usage: add <alias_name> <command...>"
        return 1
    fi

    # Use the first argument as the alias name
    local alias_name="$1"
    shift  # Remove alias name from the arguments
    local command="$*"
    local zshrc_path="$HOME/.zshrc"
    local alias_command="alias $alias_name='$command'"

    # Check if alias exists
    if grep -q "^alias $alias_name=" "$zshrc_path"; then
        existing_alias=$(grep "^alias $alias_name=" "$zshrc_path")
        echo "Existing alias found: $existing_alias"
        
        # Prompt the user for input
        echo "Do you want to replace it? (y/n): "
        read user_input
        if [[ "$user_input" =~ ^[Yy]$ ]]; then
            # Replace the existing alias
            sed -i '' "s|^alias $alias_name=.*|$alias_command|" "$zshrc_path"
            echo "Alias '$alias_name' replaced."
        else
            echo "Alias '$alias_name' was not replaced."
            return 1
        fi
    else
        # Append the new alias to .zshrc
        echo "$alias_command" >> "$zshrc_path"
        echo "Alias '$alias_name' added."
    fi

    # Reload .zshrc to apply the changes, but avoid rerunning `add`
    if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
        source "$zshrc_path"
    fi
}

# Run the function with all passed arguments only if directly called
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    add "$@"
fi

