#!/bin/bash
set -euo pipefail

# Tiap run yang lolos membuat beberapa commit untuk jam-jam yang terlewat,
# supaya slot yang dibuang scheduler tidak membuat hari itu tipis.
# 5 commit per jam terlewat, paling banyak 30 commit dalam satu run.
per_hour="${COMMITS_PER_HOUR:-5}"
max_commits="${MAX_COMMITS:-30}"

messages=(
  "bot: 👋 Hello Github!"
  "bot: 🥳 Yeayyy!"
  "bot: 😬 Working from github."
  "bot: 👨‍💻 Work, work, work!"
  "bot: 😪 Hufft..."
  "bot: 😎 I'm working for my master!"
  "bot: 🙄 Running task, again."
  "bot: 👻 Thanks master."
)

git config --local user.email "projectgabuters@gmail.com"
git config --local user.name "gabutersproject"

last="$(git log -1 --format=%ct)"
now="$(date +%s)"
if [ "$now" -le "$last" ]; then
  elapsed_hours=1
else
  elapsed_hours=$(( (now - last) / 3600 ))
fi
# Run yang tepat waktu (selisih di bawah 1 jam) tetap menulis satu gelombang commit.
if [ "$elapsed_hours" -lt 1 ]; then
  elapsed_hours=1
fi

count=$(( elapsed_hours * per_hour ))
if [ "$count" -gt "$max_commits" ]; then
  count="$max_commits"
fi
if [ "$count" -lt 1 ]; then
  count=1
fi

echo "Creating ${count} commits (${per_hour} per hour x ${elapsed_hours} elapsed hour(s), cap ${max_commits})"

for i in $(seq 1 "$count"); do
  rand=$(( RANDOM % ${#messages[@]} ))
  d="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  echo "## 🤔 LAST UPDATED AT: ${d} (${i}/${count})" > update.md
  git add update.md
  git commit -m "${messages[$rand]} (at ${d})"
  if [ "$i" -lt "$count" ]; then
    sleep 1
  fi
done
