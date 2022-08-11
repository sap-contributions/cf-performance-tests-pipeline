from packaging.version import Version
from pathlib import Path
import random
import string

import yaml

if __name__ == '__main__':
    root_branch_cf_perf_tests_pipeline = "CFP-1806"

    # Can be obtained with `git tag` in `cf-deployment`
    cf_d_versions = ['16.12.0',
                     '16.13.0',
                     '16.14.0',
                     '16.15.0',
                     '16.16.0',
                     '16.17.0',
                     '16.18.0',
                     '16.19.0',
                     '16.20.0',
                     '16.21.0',
                     '16.22.0',
                     '16.23.0',
                     '16.24.0',
                     '16.25.0',
                     '17.0.0',
                     '17.1.0',
                     '18.0.0',
                     '19.0.0',
                     '20.0.0',
                     '20.1.0',
                     '20.2.0',
                     '20.3.0',
                     '20.4.0',
                     '21.0.0',
                     '21.1.0',
                     '21.2.0',]
    dbs = ['mysql', 'postgres']

    vars_dir_path = Path(Path.cwd(), "variables")
    cf_d_rerun_vars_path = Path(vars_dir_path, "cf-d-backfill")

    cf_d_versions.sort(key=Version)

    for idx_ver, cfd_version in enumerate(cf_d_versions):
        for idx_db, db_name in enumerate(dbs):
            cfd_version = f'{cfd_version}'
            cfd_version_with_hyphens = cfd_version.replace('.', '-')
            test_name = f'cfd-{cfd_version_with_hyphens}-{db_name}'
            additional_ops_files = ''

            last_version = idx_ver == len(cf_d_versions)-1
            last_db = idx_db == len(dbs)-1
            last_test = last_version and last_db

            if not last_db:
                more_tests = True
                next_db = dbs[idx_db+1]
                next_test = f'cfd-{cfd_version_with_hyphens}-{next_db}'
            elif not last_version:
                more_tests = True
                next_cf_d_version_with_hyphens = cf_d_versions[idx_ver+1].replace('.', '-')
                next_db = dbs[0]
                next_test = f'cfd-{next_cf_d_version_with_hyphens}-{next_db}'
            elif last_test:
                next_test = None
                more_tests = False

            first_test = idx_ver == 0 and idx_db == 0
            if first_test:
                cf_perf_tests_pipeline_source_branch = root_branch_cf_perf_tests_pipeline
            else:
                cf_perf_tests_pipeline_source_branch = test_name

            if Version(cfd_version) <= Version("16.14.0"):
                additional_ops_files += ' operations/use-bionic-stemcell-for-addons.yml'
            if Version(cfd_version) <= Version("19.0.0"):
                cf_acceptance_tests_tag_filter = 'v7.4.0'
            else:
                cf_acceptance_tests_tag_filter = 'v*'
            if Version(cfd_version) >= Version("20.0.0"):
                additional_ops_files += ' operations/speed-up-dynamic-asgs.yml'
            if "postgres" in db_name:
                additional_ops_files += ' operations/use-postgres.yml'

            random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=4))

            vars_dict = {
                "additional-ops-files": additional_ops_files,
                "cloud_controller_type": "rails",
                "cf_acceptance_tests_tag_filter": cf_acceptance_tests_tag_filter,
                "cf_deployment_tag_filter": f'v{cfd_version}',
                "cf_router_idle_timeout_secs": "60",
                "ccdb": db_name,
                "test_prefix": f"cfd-{cfd_version_with_hyphens}-",
                "test_suffix": f"-{random_string}",
                "more_tests": more_tests,
                "cf_perf_tests_pipeline_source_branch": cf_perf_tests_pipeline_source_branch,
                "next_test_name": next_test
            }

            with Path(cf_d_rerun_vars_path, f'{test_name}.yml').open("w") as out:
                yaml.dump(vars_dict, out)