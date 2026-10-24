#!/usr/bin/env bash
set -euo pipefail

cache=/tmp/tmux-duty
ttl=3600

if [[ -f $cache ]]; then
    now=$(date +%s)
    mtime=$(stat -f %m "$cache")   # macOS

    if (( now - mtime < ttl )); then
        cat "$cache"
        exit 0
    fi
fi

year=$(date +%Y)
today=$(date +%Y%m%d)

curl -s \
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

        # Handle Dec -> Jan
        if [[ $sm == Dec && $em == Jan ]]; then
            ey=$((year + 1))
        fi

        start=$(date -j -f "%b %d %Y" "$sm $sd $sy" +%Y%m%d)
        end=$(date -j -f "%b %d %Y" "$em $ed $ey" +%Y%m%d)

        rest=${line#*"${BASH_REMATCH[0]}"}
        rest=$(echo "$rest" | sed 's/^ *//')

        eu=$(echo "$rest" | awk -F'  +' '{print $1}')
        us=$(echo "$rest" | awk -F'  +' '{print $2}')

        #echo "$line"
        if [[ $today -ge $start && $today -le $end ]]; then
          echo "🇪🇺 $eu | 🇺🇸 $us" > "$cache"
          cat "$cache"
          break
        fi
    fi
done

