#!/bin/sh
input=$(cat)

# Helper: build a colored bar for a given integer percentage and bar width
make_bar() {
  pct="$1"
  width="$2"
  label="$3"

  filled=$(( pct * width / 100 ))
  empty=$(( width - filled ))

  if [ "$pct" -ge 90 ]; then
    color="\033[31m"   # red
  elif [ "$pct" -ge 70 ]; then
    color="\033[33m"   # yellow
  else
    color="\033[32m"   # green
  fi
  reset="\033[0m"

  bar=""
  i=0
  while [ $i -lt $filled ]; do
    bar="${bar}▰"
    i=$(( i + 1 ))
  done
  i=0
  while [ $i -lt $empty ]; do
    bar="${bar}▱"
    i=$(( i + 1 ))
  done

  printf "${color}${label}${bar} ${pct}%%${reset}"
}

BAR_WIDTH=10
WEEK_BAR_WIDTH=20
sep="  "
output=""

# --- Model name ---
model=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model" ]; then
  output="\033[36m${model}\033[0m${sep}"
fi

# --- Context window ---
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$ctx" ]; then
  ctx_int=$(printf "%.0f" "$ctx")
  output="${output}$(make_bar "$ctx_int" "$BAR_WIDTH" "Context:")"
else
  output="${output}Context:--"
fi

# --- 5-hour limit ---
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
if [ -n "$five" ]; then
  five_int=$(printf "%.0f" "$five")
  output="${output}${sep}$(make_bar "$five_int" "$BAR_WIDTH" "5H:")"
fi

# --- Weekly limit ---
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
if [ -n "$week" ]; then
  week_int=$(printf "%.0f" "$week")
  output="${output}${sep}$(make_bar "$week_int" "$WEEK_BAR_WIDTH" "Weekly:")"
else
  output="${output}${sep}Weekly:--"
fi

printf "%b" "$output"
