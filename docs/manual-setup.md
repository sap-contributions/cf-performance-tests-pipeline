### Manual steps

## AWS setup

In order to automate the end-to-end deployment and destruction of the test environments, a number of AWS resources - shared between those test environments need to first be created first. Those resources are:

* An IAM user
* A policy for that IAM user
* Access keys for the user
* Storage of those keys in AWS Secrets Manager
* An S3 bucket (`cf-performance-tests`) to store the state of (all) the test environments

These resources are created by a CloudFormation stack defined in [scripts/bootstrap.yml](../scripts/bootstrap.yml) which is in turn called by the bash script [scripts/bootstrap.sh](../bootstrap.sh).

1. Install the [aws CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and authenticate with SAP's AWS account with a user whose permissions exceed those defined in `bootstrap.yml` for the `PipelineUser`.
1. Run `bootstrap.sh`. Upon completion the script will output the arn for the secret holding that user's AWS keys. 
1. Retrieve the access key and secret key from AWS Secrets Manager, either in your browser or with the `aws` CLI.
1. Authenticate with [Concourse's CredHub](../README.md#general-information) and store these as follows:
    ```bash
    credhub set --name /concourse/cf-controlplane/aws-pipeline-user-id --type value --value <AWS_ACCESS_KEY_ID>
    credhub set --name /concourse/cf-controlplane/aws-pipeline-user-secret --type value --value <AWS_SECRET_ACCESS_KEY>
    ```

## Configuring automatic tests
### Variables

In order to define a test configuration (e.g. with a specific ops file) that will be tested automatically against future releases of cf-deployment, define a variables file in `variables/` with the following structure:
  ```yaml
  cloud_controller_type: rails #either 'rails' or 'go'
  additional-ops-files: " operations/use-postgres.yml" #any bosh operations files required to deploy cf. The single character of whitespace at the beginning is mandatory.
  cf_router_idle_timeout_secs: "60" #adjust as desired to change the router timeout
  test_suffix: "" #optional naming suffix for the test configuration. Must be provided as an empty string if you don't want to use it.
  ```

The name of the file must follow this format: `<cloud_controller_type><test_suffix>.yml`. If no `test_suffix` is set, simply name the file `<cloud_controller_type>.yml`.

### Set the pipeline

After being set for the first time, the first job in the pipeline will set itself thereafter when there are new commits to this repo. You will still need to set it manually in some situations, such as when a new commit adds or renames a pipeline variable.

Whatever the case case, manually set the pipeline with the following command:

```bash
fly --target bosh-cf set-pipeline \
  --pipeline <PIPELINE-NAME> \
  --load-vars-from=variables/<VARS-FILE>.yml \
  --load-vars-from variables/common.yml \
  --config ci/pipeline.yml
```

Strictly speaking you're free to choose any pipeline name you like. Just use a name that's consistent with those for other test configurations.

### Manual destruction

Aside from the several dozen bosh-managed VMs created as part of a cf deployment, the pipeline creates a total of about 100 AWS resources per test in environment. Although the pipeline is written to destroy these resources upon successfully completing the tests, it also has a series of jobs that can be manually triggered to separately delete the cf bosh deployment, the bosh director, the base infrastructure (upon which the former both depend) - or all three reverse-order. These are defined in a pipeline group that you can view by clicking the `manual-teardown` button in the top-left of the Concourse UI when viewing the pipeline in question.

> Warning: If you run `manual-teardown-base-infra-only` deletes the IAM user and associated policy that `bbl` depends on to manage resources in AWS. You should not run this before `bbl` has destroyed those resources.

If these manual jobs fail to clean up an environment, you will need to locate the test environment's subfolder in the `cf-performance-tests` S3 bucket and, depending on the failure, download either `bbl-state.tgz` or `base-infra/terraform.tfstate`.
- `bbl-state.tgz`:
    1. Extract the archive and change into the state directory
    1. Run `eval "$(bbl print-env)"` and then `bosh vms` to check if any bosh-managed vms still exist. If they do, try to delete them with bosh (if this fails, you'll have to do this manually in AWS)
    1. If there are no bosh-managed VMs left but you've still got a director, try to delete it with `bbl destroy`. If this fails, you'll have to delete the director and jumpbox VMs manually in AWS.
    1. If `bbl destroy` is unable to delete the director, or succeeds but then fails while destroying terraform resources, you'll have to try to delete these yourself.
    1. Download version 0.11.x of the `terraform` CLI, and move `vars/terraform.tfstate` and `vars/bbl.tfvars` into the `terraform` subdirectory.
    1. Run `terraform init` and provide the values for any required variables, then `terraform destroy -var-file=bbl.tfvars`. You may need to remove resources from the tls provider from the state file.
- `base-infra/terraform.tfstate`
    1. Download the file, place it in [base-infra/terraform](../base-infra/terraform), and run `terraform init` with whatever version of the terraform CLI matches that used by the latest commit of the [Concourse terraform resource](https://github.com/ljfranklin/terraform-resource) when the pipeline last ran the `base-infra` job. Then `terraform destroy`.

In both cases, the last resort - and this should almost never be necessary - will be to manually delete any remaining resources from AWS