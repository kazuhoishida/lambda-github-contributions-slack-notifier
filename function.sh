function handler() {
  # date range for last week
  from_date=$(date -d "last Sunday - 1 week" +"%Y-%m-%dT00:00:00Z")
  to_date=$(date -d "last Saturday - 1 week" +"%Y-%m-%dT23:59:59Z")

  response=$(curl -H "Authorization: bearer $GITHUB_TOKEN" -X POST -d '{"query":"query { user(login: \"'$GITHUB_USERNAME'\") { name contributionsCollection(from: \"'$from_date'\", to: \"'$to_date'\") { commitContributionsByRepository(maxRepositories: 100) { repository { name } contributions { totalCount } } contributionCalendar { totalContributions } } } }"}' https://api.github.com/graphql)

  total_contributions=$(echo $response | jq -r '.data.user.contributionsCollection.contributionCalendar.totalContributions')
  # count total commits num
  total_commits=$(echo $response | jq -r '.data.user.contributionsCollection.commitContributionsByRepository | map(.contributions.totalCount) | add // 0')
  # count total repositories num that I contributed
  total_repositories=$(echo $response | jq -r '.data.user.contributionsCollection.commitContributionsByRepository | length')

  # slack message
  temp="*Last week's contributions:*\ntotal contributions: \`$total_contributions\`, commits: \`$total_commits\`, repositories: \`$total_repositories\`"
  # replace \\n to \n
  text=$(echo $temp | sed -e 's/\\n/\'$'\n''/g')

  curl -d "text=$text" -d channel="$SLACK_GITHUB_CHANNEL" -H "Authorization: Bearer $SLACK_TOKEN" -X POST https://slack.com/api/chat.postMessage > /dev/null
}