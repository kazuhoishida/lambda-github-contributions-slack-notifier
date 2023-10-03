function handler() {
  # date range
  start_of_this_year=$(date -d "1/1" +"%Y-%m-%dT00:00:00Z")
  from_date=$(date -d "last Sunday - 1 week" +"%Y-%m-%dT00:00:00Z")
  to_date=$(date -d "last Saturday" +"%Y-%m-%dT23:59:59Z")

  # this year's data
  this_year_response=$(curl -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d '{"query":"query { user(login: \"'$GITHUB_USERNAME'\") { contributionsCollection(from: \"'$start_of_this_year'\", to: \"'$to_date'\") { contributionCalendar { totalContributions } } } }"}' https://api.github.com/graphql)

  # last week's data
  response=$(curl -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d '{"query":"query { user(login: \"'$GITHUB_USERNAME'\") { contributionsCollection(from: \"'$from_date'\", to: \"'$to_date'\") { commitContributionsByRepository(maxRepositories: 100) { contributions { totalCount } } contributionCalendar { totalContributions\n weeks { contributionDays { weekday\n color } } } } } }"}' https://api.github.com/graphql)

  # this year's contributions
  this_year_total_contributions=$(echo $this_year_response | jq -r '.data.user.contributionsCollection.contributionCalendar.totalContributions')

  # last week's contributions
  total_contributions=$(echo $response | jq -r '.data.user.contributionsCollection.contributionCalendar.totalContributions')
  total_commits=$(echo $response | jq -r '.data.user.contributionsCollection.commitContributionsByRepository | map(.contributions.totalCount) | add // 0')
  total_repositories=$(echo $response | jq -r '.data.user.contributionsCollection.commitContributionsByRepository | length')
  
  # show weekday and color, use only weekdays
  weekday=$(echo $response | jq -r '.data.user.contributionsCollection.contributionCalendar.weeks | map(.contributionDays | map(select(.weekday != 0 and .weekday != 6)) | map("\(.weekday): \(.color)") | join("\n")) | join("\n")')

  # slack message
  temp="*GitHub Contributions:*\n\n今年の合計: \`$this_year_total_contributions\`\n先週の合計: \`$total_contributions\` (commits: \`$total_commits\`, repo: \`$total_repositories\`)\n\n$weekday"
  text=$(printf "%b" "$temp")

  curl -d "text=$text" -d channel="$SLACK_GITHUB_CHANNEL" -H "Authorization: Bearer $SLACK_TOKEN" -X POST https://slack.com/api/chat.postMessage > /dev/null
}