#!/bin/bash

log_verbose "File: helloworld.sh"

function helloworld() {
	local text="Hello World!"
	log_success "$text"
	log_info "$text"
	log_error "$text"
	log_debug "$text"

	text_success "$text" 
	text_info "$text"
	text_error "$text"
	text_debug "$text"

	echo "Hello $(text_success 'World')! Hello $(text_info 'World')! Hello $(text_error 'World')! Hello $(text_debug 'World')! $text" >&2
}
