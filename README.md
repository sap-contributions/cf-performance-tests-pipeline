# CF Performance Tests Pipeline

This repository contains all artifacts for the CF performance tests pipeline including boostrapping of the CF foundation, which tests run against and the [test results](test-results) and generated [charts](test-charts). It based on [bosh-bootloader](https://github.com/cloudfoundry/bosh-bootloader) and [cf-deployment](https://github.com/cloudfoundry/cf-deployment). The deployment pipeline runs on this public Concourse instance: https://bosh.ci.cloudfoundry.org/. You can log on with your github.com account.

The performance tests can be found [here](https://github.com/cloudfoundry-incubator/cf-performance-tests)

## Test Results / Test Charts

After finishing running the concourse pipeline, all results and charts are saved in the corresponding directories in this repo. You can visually observe the regressions/improvements of performance from the charts.

[domains-test-results](test-results/domains-test-results/v1/) / [domains-test-charts](test-charts/domains-test-results/v1/)

[security-groups-test-results](test-results/security-groups-test-results/v1) / [security-groups-test-charts](test-charts/security-groups-test-results/v1/)

[isolation-segments-test-results](test-results/isolation-segments-test-results/v1/) / [isolation-segments-test-charts](test-charts/isolation-segments-test-results/v1/)

Several types of chart data will be generated:

1. Detailed: contains the largest, shortest and average cf api execution time.
2. Detailed with most recent runs. Same as 1, but only contains the last 15 runs.
3. Simplified: Chart only contains the average cf api execution time.
4. Simplified with most rencent runs: same as 3, only contains the last 15 runs.

## General information
The AWS account and domain used to host the BBL and CF foundation is currently owned by SAP. It might move to a community owned account in the future. A discription of how this was set up can be found [here](docs/manual-setup.md).

## Automatic Setup / Destruction

There are two Concourse pipelines for the automatic deployment and destruction of a CF foundation. Log on to Concourse with the "fly" CLI and upload the pipelines. The "cf-perf-test" variables configure the pipelines for the default CF deployment. The "go-perf-test" variables are for the CF deployment with the new gontroller reimplementation.

**NOTE**: The credentials which are required below are currently only available to SAP employees.

```bash
# "cf.cfperftest.bndl.sapcloud.io" or "cf.goperftest.bndl.sapcloud.io"
SYSTEM_DOMAIN=<domain>

# find those in vault
# aws/cf-perf-test-state-bucket-user or aws/go-perf-test-state-bucket-user
read -s BBL_STATE_BUCKET_KEY_ID
read -s BBL_STATE_BUCKET_KEY_SECRET

# "cf-perf-test-state" or "go-perf-test-state"
BBL_STATE_BUCKET_NAME=<bucket name>

# find those in vault
read -s GITHUB_USER
read -s GITHUB_EMAIL
read -s GITHUB_TOKEN

# find those in vault
# aws/iaas-provider_bootstrap-cfperftest or aws/iaas-provider_bootstrap-goperftest
read -s AWS_KEY_ID
read -s AWS_KEY_SECRET

read -s SLACK_URL

# pipeline name: "deploy-cf-performance-test" or "deploy-go-performance-test"
fly -t <target> set-pipeline -p <pipeline name> \
-v system-domain=$SYSTEM_DOMAIN \
-v bbl-state-bucket-access-key-id=$BBL_STATE_BUCKET_KEY_ID \
-v bbl-state-bucket-access-key-secret=$BBL_STATE_BUCKET_KEY_SECRET \
-v bbl-state-bucket-name=$BBL_STATE_BUCKET_NAME \
-v github-serviceuser-username=$GITHUB_USER \
-v github-serviceuser-token=$GITHUB_TOKEN \
-v github-serviceuser-email=$GITHUB_EMAIL \
-v aws-access-key-id=$AWS_KEY_ID \
-v aws-access-key-secret=$AWS_KEY_SECRET \
-v slack-notification-url=$SLACK_URL \
-c ./concourse/deploy-cf-perftest.yml

# pipeline name: "destroy-cf-performance-test" or "destroy-go-performance-test"
fly -t <target> set-pipeline -p <pipeline name> \
-v bbl-state-bucket-access-key-id=$BBL_STATE_BUCKET_KEY_ID \
-v bbl-state-bucket-access-key-secret=$BBL_STATE_BUCKET_KEY_SECRET \
-v bbl-state-bucket-name=$BBL_STATE_BUCKET_NAME \
-v github-serviceuser-username=$GITHUB_USER \
-v github-serviceuser-token=$GITHUB_TOKEN \
-v github-serviceuser-email=$GITHUB_EMAIL \
-v aws-access-key-id=$AWS_KEY_ID \
-v aws-access-key-secret=$AWS_KEY_SECRET \
-c ./concourse/destroy-cf-perftest.yml
```
The deploy pipeline runs `bbl up` followed by a `bosh deploy` for the CF deployment. The destroy pipeline first deletes all BOSH deployments and then runs `bbl destroy` to delete all IaaS resources.