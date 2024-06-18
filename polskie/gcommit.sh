#!/bin/bash

function gcommit() {
    local msg
    local all_params="$*"
    local current_ticket_no
    local current_ticket_no2
    local current_branch
    local regex="[[:alnum:]]{2,}-[0-9]{1,6}"

    current_branch=$(git branch --show-current)
    log_info "Current Branch: \"$current_branch\""

    current_ticket_no=$(echo "$current_branch" | grep -oE "/$regex" | sed 's/^\/\(\w\+\)/\1/')
    current_ticket_no2=$(echo "$current_branch" | grep -oE "$regex" | sed 's/^\/\(\w\+\)/\1/')

    if [ -z "$current_ticket_no" ] && [ -n "$current_ticket_no2" ]; then
        current_ticket_no="$current_ticket_no2"
    fi

    log_info "Current Ticket No: \"$current_ticket_no\""
    if [ -n "$current_ticket_no" ]; then
        msg="$current_ticket_no: $(capitalize_first_letter "$all_params")"
    else
        read -p "Enter the ticket number: " ticket_number

        if [[ "$ticket_number" =~ ^[[:alnum:]]{2,}-[0-9]{1,6}$ ]]; then
            msg="$ticket_number: $(capitalize_first_letter "$all_params")"
            current_ticket_no="$ticket_number"
        elif [[ "$ticket_number" =~ ^[0-9]{1,6}$ ]]; then
            ticket_number="$(trim_whitespace "$POLSKIE_BRANCH_PREFIX")-$ticket_number"
            msg="$ticket_number: $(capitalize_first_letter "$all_params")"
            current_ticket_no="$ticket_number"
        else
            msg="$(capitalize_first_letter "$all_params")"
        fi
    fi

    while true; do
        local last_question
        read -p "Are you okay with this commit message \"$msg\"? (y/n) " last_question
        case "$last_question" in
            [Yy]|[Yy][Ee][Ss])
                log_info "git commit -m \"$msg\""
                git commit -m "$msg"
					while true; do
						local last_question
						read -p "Do you want to push changes you've made? (y/n) " confirm_commit
						case "$confirm_commit" in
							[Yy]|[Yy][Ee][Ss])
								gpush
								break
								;;
							[Nn]|[Nn][Oo])
								log_info "No problem!"
								break
								;;
							*)
								log_info "Please enter yes or no."
								;;
						esac
					done
                break
                ;;
            [Nn]|[Nn][Oo])
                log_info "No problem!"
                break
                ;;
            *)
                log_info "Please enter yes or no."
                ;;
        esac
    done
}

