# CF Performance Tests Pipeline

This repository defines a Concourse pipeline that automatically runs the [cf-performance-tests](https://github.com/cloudfoundry/cf-performance-tests) against new versions of [cf-deployment](https://github.com/cloudfoundry/cf-deployment) and stores the [results](results) in this repo. The pipeline also generates .png charts .png charts that show how performance varies across different cf-deployment versions. These are regenerated each time a new results file is added.

The pipeline is triggered by new cf-deployment releases. It uses [bbl](https://github.com/cloudfoundry/bosh-bootloader) to stand a bosh director, and then uses that director to deploy a Cloud Foundry foundation. Each pipeline run will run the tests twice against a specific release of cf-deployment - once with a Cloud Controller that has a postgres CCDB, and once with a mysql CCDB. After completion, the test environment is torn down.

See the [docs](docs) subdirectory for instructions on one-off manual setup steps that need to be run before running any tests, along with guidance on configuring new automated tests and manual setup steps for triggering a series of tests against old versions of cf-deployment.

## Test results and charts

Results are stored automatically in the following paths in this repo, according to the Cloud Controller that was tested (the go proof-of-concept or the regular CC written in rails) and whether a postgres or mysql CCDB was used.

```bash
results
├── go #tests that swap in a proof-of-concept Cloud Controller written in go: https://github.com/cloudfoundry/go-cf-api
│   ├── mysql
│   │   ├── charts
│   │   └── results
│   └── postgres
│       ├── charts
│       └── results
└── rails #tests using the regular Cloud Controller
    ├── mysql
    │   ├── charts
    │   └── results
    └── postgres
        ├── charts
        └── results
```

Four types of chart are generated:

1. Detailed: contains the largest, shortest and average cf api execution time.
2. Detailed with most recent runs. Same as 1, but only contains the last 15 runs.
3. Simplified: Chart only contains the average cf api execution time.
4. Simplified with most recent runs: same as 3, only contains the last 15 runs.

## General information
The AWS account and domain used to host the BBL and CF foundation is controlled by SAP, but may move to a community owned account in the future. See [here](docs/manual-setup.md) for information on the manual steps that were followed to get the tests automated.

The pipeline currently runs on [bosh.ci.cloudfoundry.org](https://bosh.ci.cloudfoundry.org/), but it is planned to migrate this in the near future to a Concourse controlled by the Cloud Foundry Foundation's [App Runtime Deployments Working Group](https://github.com/cloudfoundry/community/blob/main/toc/working-groups/app-runtime-deployments.md).

Secrets referenced by the pipeline (e.g. `((aws-pipeline-user-secret))`) are stored in a CredHub server deployed alongside Concourse. Contributors who need access must contact the CFF's [Foundational Infrastructure Working Group](https://github.com/cloudfoundry/community/blob/main/toc/working-groups/foundational-infrastructure.md) in order to get approval to be added to the working group's Google Cloud account. Once access is granted, you can login to CredHub with [this script](https://github.com/cloudfoundry/bosh-community-stemcell-ci-infra/blob/main/start-credhub-cli.sh).

### Access a performance test environment
Although the test environments are torn down automatically at the end of a successful run, you might need to access one to debug a failure.

1. Follow [these instructions](https://github.com/cloudfoundry/bosh-bootloader#prerequisites) to install `bbl` locally.
1. Navigate to the s3 bucket `cf-performance-tests` and find the subfolder for the test environment you want to connect to and download the tarball `bbl-state.tgz`.
1. Extract the archive locally, and `cd` into the `state` directory.
1. Run `eval "$(bbl print-env)"`
1. Confirm you can now communicate with the bosh director by running `bosh env`

### Connect to the CCDB: MySQL
If you have deployed a test environment with MySQL as the Cloud Controller's database, you can open a tunnel to the jumpbox and then connect from there. Initialise `bbl` as explained above and then run:
```bash
ssh -4 -N -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" -o "ServerAliveInterval=30" -o "ServerAliveCountMax=10" -o "IPQoS=throughput" \
  -i "$JUMPBOX_PRIVATE_KEY" -L "3306:10.0.16.5:3306" jumpbox@<jumpbox ip from $BOSH_ALL_PROXY> &
# copy mysql client from "database" vm
bosh -d cf scp database:/usr/local/bin/mysql .
./mysql --host=127.0.0.1 --port=3306 --user=cloud_controller cloud_controller --password=<cc_database_password from credhub>
```
From the mysql command prompt, you can e.g. use `source db.sql` to read and execute statements from a file.