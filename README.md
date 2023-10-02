# AWS LAMBDA Github Contributions Slack Notifier

1. Lambda Function for Retrieving GitHub Contributions and Posting to Slack Channel
2. Custom Amazon Linux2 Runtime for Running the Function
3. Automatic Execution Using Amazon EventBridge

## Prerequisites

To use this script, you will need the following:

- A GitHub personal access token with the `repo` and `user` scope. You can create a new token [here](https://github.com/settings/tokens).
- A Slack bot token. You can create a new bot and token [here](https://api.slack.com/apps). Then, you need to add the bot to a channel.

## Getting Started

1. Grant the permission to the following files:

```bash
chmod +x function.sh bootstrap
```

2. Create a AWS Lambda function. Then create a zip file and upload it to the lambda function (or you can upload it to S3 and set the S3 URL in the lambda function)

```bash
zip function.zip function.sh bootstrap
```

3. Set these env variables in Lambda Function Configuration:

```
GITHUB_TOKEN=your_github_token
GITHUB_USERNAME=your_github_username
SLACK_TOKEN=your_slack_token
SLACK_GITHUB_CHANNEL=your_slack_channel_name
```

4. Install `jq` and create a zip file for the lambda layer, or you can use bin file in this repository.

```bash
mkdir bin
cd bin
curl -L https://github.com/stedolan/jq/releases/download/jq-1.7/jq-linux64 -o jq
chmod +x jq
cd ..
zip -r jq_layer.zip bin
```

5. Create a lambda layer and upload the zip file. Choose `Custom runtime on Amazon Linux 2` for the runtime.<br>
   Then add the layer to the lambda function.

6. Create a rule in EventBridge to run automatically.<br>
   For example, you can set the rule to run every Monday at 9:00 AM as follows:

```
# Cron expression
0 9 ? * 2 *
```
