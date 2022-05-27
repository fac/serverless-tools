# serverless-tools
A collection of tools used to ease the use of serverless projects.

The main goal of serverless tools is to provide a CLI to help deploy lambda functions. It can be used locally to update lambda functions in a developer account for quick iteration. Or, it can be used through a GitHub action for staging and production environments.

The standardisation of this tooling allows us to be confident in what we're deploying, takes the toil out of setting up serverless projects, and brings parity across the deployment tool chain.

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
It supports both lambdas with code in an S3 bucket as well as those deployed as a Docker container.

```yaml
  # Example entry in functions.yml for an S3-based function
  repo: serverless-tools
  s3_archive_name: function.zip
  handler_file: handler_one.rb
  bucket: freeagent-lambda-example-scripts

  # Example entry in functions.yml for an function in a Docker container
  repo: serverless-tools
  dockerfile: lambda-container-context/Dockerfile
```

```zsh
  serverless-tools help # Run for all command options
```


The deployer takes 2 arguments:
  * action (which stage of the deploy process to run) - required
  * functions (which function from `functions.yml` to apply changes to) - optional, if not included will act on all the lambda functions.

The deployer uses the current git HEAD for which sha to push and update.

```zsh
  serverless-tools deploy build # Zips the file - assumes bundle install has been run and deps are in a vendor folder OR Builds a Docker image
  serverless-tools deploy push # Pushes the zip(s) to S3 OR Pushes the Docker image to Amazon Elastic Container Registry (ECR)
  serverless-tools deploy update # Updates the lambda function
```

### Comment

The comment tool is intended to be used as a Github Action. It takes a json hash (assumed to be the name of a lambda function and the status of the update)
and prints a formatted string with the Github Action expression to set an output. This output can then used to comment in a Github Issue.

```zsh
  serverless-tools comment -f '{"function_name": "Success"}'
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

## Image

Serverless-Tools is bundled as a Docker Image to be used as a [Github Action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action).

### Building

To build the image locally, run:

```docker image build -t serverless-tools:latest .```

### Running

To execute the image locally run:

```docker container run serverless-tools:latest version```

You can run the image to mimic the way it would be ran by a Github Action. For example:

```aws-vault exec your-aws-profile -- docker container run -e AWS_REGION=eu-west-1 -e AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY --workdir /github/workspace -v `pwd`:/github/workspace serverless-tools:latest deploy build ```

Breaking down this command, we can see what it does:

`aws-vault exec your-aws-profile -- `. The first part uses aws-vault to assume an IAM role, and then this assumed role will be accessible when executing the next part of the command. To run any of the `deploy` commands, we need access to AWS. AWS Vault works by populating environments for the next part of the command.

`docker container run -e AWS_REGION=eu-west-1 -e AWS_ACCESS_KEY_ID=AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=AWS_SECRET_ACCESS_KEY`. We begin the call to `docker container run` and populate the environment variables of the container from the variables AWS Vault has populated.

``--workdir /github/workspace``. We're now telling the run command that the working directory will be `github/workspace` - this can be any directory, we're just using the same namespace for parity with the Github Action. Essentially the command which is executed will be from within the working directory inside the container.


``-v `pwd`:/github/workspace`` We're then specifying a volume to be mounted, and we're mapping the current directory of the users machine to the working directory of the container. This accomplishes two things, firstly it provides the code that needs deploying to serverless-tools, and secondly it allows any assets which are generated to be local to the user and accessible to inspect.

`serverless-tools:latest deploy build` finally, we specify the image to run, and which commands to pass to it.