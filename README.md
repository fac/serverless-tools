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

## Installing

`bundle exec rake install`

## Examples

### Deployer

The deployer tool is used to bundle up the code in this repo and update the corresponding lambda functions.

```zsh
  serverless-tools help # Run for all command options
```


The deployer takes 2 arguments:
  * action (which stage of the deploy process to run) - required
  * functions (which function from `functions.yml` to apply changes to) - optional, if not included will act on all the lambda functions.

The deployer uses the current git HEAD for which sha to push and update.

```zsh
  serverless deploy build # Zips the file - assumes bundle install has been run and deps are in a vendor folder
  serverless deploy push # Push the zip(s) to S3
  serverless deploy update # Update the lambda function
```

### Comment

The comment tool is intended to be used as a Github Action. It takes a json hash (assumed to be the name of a lambda function and the status of the update)
and prints a formatted string with the Github Action expression to set an output. This output can then used to comment in a Github Issue.

```zsh
  serverless comment -f '{"function_name": "Success"}'
```
### Github Actions

Example for a ruby project's Github workflow to build and push assets lambda code to S3.

```yaml
    name: Push Assets

on: [push]

jobs:
  push_assets:
    runs-on: ubuntu-latest
    env:
      BUNDLE_WITHOUT: development test
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
      - name: configure aws credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-1
          role-to-assume: arn:aws:iam::YOUR-AWS-ACCOUNT-NUMBER:role/YOUR-ROLE-HERE
          role-duration-seconds: 1200
      - name: build assets
        uses: fac/serverless-tools@v0.0.2
        with:
          command: deploy build
      - name: upload assets to pr
        uses: actions/upload-artifact@v2
        with:
          name: assets
          path: |
            *.zip
          if-no-files-found: error
      - name: push assets to s3
        uses: fac/serverless-tools@v0.0.2
        with:
          command: deploy push
```
