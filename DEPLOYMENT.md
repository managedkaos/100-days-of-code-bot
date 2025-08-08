# Slack Topic Updater - Lambda Deployment Guide

This guide explains how to deploy the Slack Topic Updater application as an AWS Lambda function using SAM CLI.

## Prerequisites

1. **AWS CLI** - Install and configure with appropriate credentials

   ```bash
   pip install awscli
   aws configure
   ```

2. **SAM CLI** - Install the AWS Serverless Application Model CLI

   ```bash
   pip install aws-sam-cli
   ```

3. **Slack Bot Token** - Create a Slack app and get a bot token with the following permissions:
   - `channels:read`
   - `channels:write`
   - `groups:read`
   - `groups:write`

## Configuration Files

### `template.yaml`

The main SAM template that defines:

- Lambda function with Python 3.12 runtime
- Daily schedule (2 AM UTC) using CloudWatch Events
- Environment variables for Slack configuration
- Lambda URL for HTTP access
- IAM permissions for CloudWatch Logs

### `samconfig.toml`

SAM configuration file with deployment settings for different environments.

### `deploy.sh`

Deployment script that simplifies the build and deploy process.

## Deployment Options

### Option 1: Using the Deployment Script (Recommended)

1. **Make the script executable:**

   ```bash
   chmod +x deploy.sh
   ```

2. **Deploy to development:**

   ```bash
   ./deploy.sh deploy-development "your-slack-token" "your-slack-channel-id"
   ```

3. **Deploy to production:**

   ```bash
   ./deploy.sh deploy-production "your-slack-token" "your-slack-channel-id"
   ```

4. **Other useful commands:**

   ```bash
   ./deploy.sh build                    # Build the application
   ./deploy.sh outputs production       # Show stack outputs
   ./deploy.sh logs production          # Show function logs
   ./deploy.sh delete production        # Delete the stack
   ```

### Option 2: Using SAM CLI Directly

1. **Build the application:**

   ```bash
   sam build
   ```

2. **Deploy with parameters:**

   ```bash
   sam deploy --guided
   ```

   Or deploy with specific parameters:

   ```bash
   sam deploy \
     --parameter-overrides \
     SlackAuthToken="your-slack-token" \
     SlackChannelId="your-slack-channel-id"
   ```

## Environment Variables

The Lambda function uses the following environment variables:

- `SLACK_AUTH_TOKEN` (required): Your Slack bot token
- `SLACK_CHANNEL_ID` (required): The channel ID to update
- `SLACK_API_URL` (optional): Defaults to `https://slack.com/api/conversations.setTopic`

## Features

### 1. Daily Schedule

The function runs automatically every day at 2 AM UTC using CloudWatch Events.

### 2. Lambda URL

A public Lambda URL is created for manual invocation:

- No authentication required
- CORS enabled for web access
- Supports GET requests

### 3. Monitoring

- CloudWatch Logs for function execution logs
- CloudWatch Metrics for monitoring performance
- Error handling with appropriate HTTP status codes

## Testing

### Local Testing

1. **Update `env.json` with your test credentials**
2. **Test the function locally:**

   ```bash
   ./deploy.sh test-local
   ```

### Manual Invocation

After deployment, you can manually invoke the function via:

- **Lambda URL:** `https://your-lambda-url.lambda-url.us-east-1.on.aws/`
- **AWS Console:** Navigate to the Lambda function and use the "Test" button
- **AWS CLI:** Use `aws lambda invoke`

## Monitoring and Troubleshooting

### View Logs

```bash
# View recent logs
./deploy.sh logs production

# Follow logs in real-time
sam logs --config-env production --tail
```

### Check Function Status

```bash
# Get stack outputs (including Lambda URL)
./deploy.sh outputs production

# Check function configuration
aws lambda get-function --function-name slack-topic-updater-prod-SlackTopicUpdaterFunction
```

### Common Issues

1. **Permission Denied:**
   - Ensure your Slack bot has the required permissions
   - Check that the channel ID is correct
   - Verify the bot is added to the channel

2. **Function Timeout:**
   - The function has a 30-second timeout
   - Check Slack API response times
   - Review CloudWatch logs for errors

3. **Schedule Not Working:**
   - Verify the CloudWatch Events rule is enabled
   - Check the cron expression: `cron(0 2 * * ? *)`
   - Ensure the function has proper IAM permissions

## Security Considerations

1. **Slack Token Security:**
   - Use AWS Systems Manager Parameter Store for sensitive values
   - Never commit tokens to version control
   - Rotate tokens regularly

2. **Lambda URL Security:**
   - The URL is public (no authentication)
   - Consider adding authentication if needed
   - Monitor for abuse

3. **IAM Permissions:**
   - The function has minimal required permissions
   - Only CloudWatch Logs access is granted
   - Review and restrict as needed

## Cost Optimization

1. **Memory Allocation:**
   - Currently set to 128 MB (minimum)
   - Monitor performance and adjust if needed

2. **Timeout Settings:**
   - 30-second timeout should be sufficient
   - Reduce if function completes faster

3. **Log Retention:**
   - CloudWatch logs are retained according to AWS defaults
   - Consider setting log retention policies

## Cleanup

To remove all resources:

```bash
./deploy.sh delete production
```

This will delete:

- Lambda function
- CloudWatch Events rule
- Lambda URL
- CloudWatch Log groups
- IAM roles and policies

## Support

For issues or questions:

1. Check CloudWatch logs for error details
2. Verify Slack API credentials and permissions
3. Test locally using the provided test files
4. Review AWS Lambda documentation for troubleshooting
