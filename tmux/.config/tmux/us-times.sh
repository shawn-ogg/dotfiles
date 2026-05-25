#!/usr/bin/env bash

fmt_time() {
    local label="$1"
    local tz="$2"

    local time
    time=$(TZ="$tz" date +'%H:%M')

    if [[ "$time" < "07:00" ]]; then
        printf "#[fg=red]%s %s#[default]" "$label" "$time"
    elif [[ "$time" < "08:00" ]]; then
        printf "#[fg=yellow]%s %s#[default]" "$label" "$time"
    else
        printf "#[fg=green]%s %s#[default]" "$label" "$time"
    fi
}

printf "%s | " "$(fmt_time "ME" "America/New_York")"
printf "%s | " "$(fmt_time "DA" "America/Chicago")"
printf "%s | " "$(fmt_time "CA" "America/Edmonton")"
printf "%s" "$(fmt_time "SE" "America/Los_Angeles")"
