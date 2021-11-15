# serverless-tools
A collection of tools used to ease the use of serverless projects

## Requirements

* Ruby (see `.ruby-version`)
* Bundle (See Gemfile.lock)

See [FreeAgent Application Setup](https://www.notion.so/freeagent/Setting-up-the-FreeAgent-application-88b0179b53e949b793c25972cf8d4a29#1a5b89b08e05449bb402ad08d02de136) and follow the Setup Steps for bundle and ruby.

## Setup

`bundle install`

## Test

`bundle exec rake test`

## Deployer

The deployer tool is used to bundle up the code in this repo and update the corresponding lambda functions.

The deployer takes 3 arguments:
  * action (which stage of the deploy process to run) - required
  * functions (which function from `functions.yml` to apply changes to) - optional, if not included will act on all the lambda functions.

### Examples:
  * run the deployer with aws-vault and bundle:

```zsh
  # Create zip archives, upload them to S3 and then updates the lambda function code
  # Note the role should have permissions to upload to S3 and update the Lambda function.
  aws-vault exec dataplatform-stage -- bundle exec ruby tools/deployer.rb deploy
```

## Comment

The comment tool is intended to be used as a Github Action. It takes a jsonified hash (assumed to be the name of a lambda function and the status of the update)
and prints a formatted string with the Github Action expression to set an output. This output is then used to comment in a Github Issue.
