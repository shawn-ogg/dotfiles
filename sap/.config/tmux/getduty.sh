#!/usr/bin/env bash
set -euo pipefail

# Work integration is opt-in; do not call SAP endpoints when disabled.
[[ "${ENABLE_SAP_INTEGRATION:-0}" == "1" ]] || exit 0
[[ -n "${WAT:-}" ]] || exit 0

cache="${XDG_CACHE_HOME:-$HOME/.cache}/tmux-duty"
ttl=3600
mkdir -p "$(dirname "$cache")"

file_mtime() {
  if stat -f %m "$1" >/dev/null 2>&1; then
    stat -f %m "$1"
  else
    stat -c %Y "$1"
  fi
}

parse_date() {
  local month="$1" day="$2" year="$3"
  if date -j -f "%b %d %Y" "$month $day $year" +%Y%m%d 2>/dev/null; then
    return 0
  fi
  date -d "$month $day $year" +%Y%m%d
}

if [[ -f "$cache" ]]; then
  now=$(date +%s)
  mtime=$(file_mtime "$cache" || echo 0)
  if (( now - mtime < ttl )); then
    cat "$cache"
    exit 0
  fi
fi

year=$(date +%Y)
today=$(date +%Y%m%d)

curl -fsS \
  -H "Authorization: Bearer $WAT" \
  "https://wiki.one.int.sap/wiki/rest/api/content/3752196457?expand=body.storage,version" |
  jq -r '.body.storage.value' |
  xmllint --html --xpath '//tr' - 2>/dev/null |
  sed 's/<[^>]*>/ /g' |
while read -r line; do
  if [[ $line =~ ^([A-Z][a-z]{2})[[:space:]]+([0-9]{1,2})[[:space:]]*-[[:space:]]*(([A-Z][a-z]{2})[[:space:]]+)?([0-9]{1,2}) ]]; then
    sm=${BASH_REMATCH[1]}
    sd=$(printf "%02d" "${BASH_REMATCH[2]}")
    em=${BASH_REMATCH[4]:-$sm}
    ed=$(printf "%02d" "${BASH_REMATCH[5]}")
    sy=$year
    ey=$year

    if [[ $sm == Dec && $em == Jan ]]; then
      ey=$((year + 1))
    fi

    start=$(parse_date "$sm" "$sd" "$sy") || continue
    end=$(parse_date "$em" "$ed" "$ey") || continue
    rest=${line#*"${BASH_REMATCH[0]}"}
    rest=$(echo "$rest" | sed 's/^ *//')
    eu=$(echo "$rest" | awk -F'  +' '{print $1}')
    us=$(echo "$rest" | awk -F'  +' '{print $2}')

    if [[ $today -ge $start && $today -le $end ]]; then
      printf '🇪🇺 %s | 🇺🇸 %s\n' "$eu" "$us" | tee "$cache"
      break
    fi
  fi
done
