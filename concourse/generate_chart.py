import argparse
import datetime
import glob
import json
import logging
from decimal import Decimal, ROUND_DOWN, ROUND_UP

import matplotlib.pyplot as plt
import numpy as np
import os
import re
import sys

from typing import List
from pathlib import Path

logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(logging.StreamHandler(sys.stdout))


def load_test_results(prefix: str, file_paths: List[str]) -> (list, dict):
    test_executions = []  # sorted list of (cf_deployment_version, capi_version, test_timestamp)
    test_results = {}  # dict of {test_name: {test_execution: test_results}} (not sorted)

    return get_from_files(test_executions, test_results, file_paths)


def get_from_files(test_executions: list, test_results: dict, file_paths: list) -> (list, dict):
    for file_path in file_paths:
        logger.info(f'Loading results from {os.path.basename(file_path)} ...')
        with open(file_path, 'r') as stream:
            results_from_file = json.load(stream)
            if not is_valid_result(results_from_file):
                logger.info(f'  Test results invalid/incomplete, skipping file.')
                continue
            test_execution = (results_from_file['cfDeploymentVersion'], results_from_file['timestamp'], results_from_file['capiVersion'])
            timestamp_formatted = format_timestamp(test_execution[1])
            logger.info(
                f'  Adding test results for cf-deployment {test_execution[0]} from {timestamp_formatted}')
            test_executions.append(test_execution)
            for test_name in results_from_file['measurements']:
                if test_name not in test_results:
                    test_results[test_name] = {}
                if 'request time' in results_from_file['measurements'][test_name]:
                    test_results[test_name][test_execution] = results_from_file['measurements'][test_name]['request time']
    logger.info( f'Found {len(test_executions)} test executions with a total of {len(test_results)} tests.')
    # sorts by test_result_key with cf version as first and timestamp as second key
    return sorted(test_executions), test_results


def is_valid_result(result: dict) -> bool:
    if 'cfDeploymentVersion' not in result:
        return False
    if 'capiVersion' not in result:
        return False
    if 'timestamp' not in result:
        return False
    if 'measurements' not in result:
        return False
    if len(result['measurements']) == 0:
        return False
    at_least_one_measurement = False
    for measurement in result['measurements']:
        result_times = result['measurements'][measurement]['request time']
        if 'Smallest' in result_times and 'Largest' in result_times and 'Average' in result_times:
            at_least_one_measurement = True
            break
    return at_least_one_measurement


def generate_chart(prefix, chart_destination: str, file_paths: List[str], simplified: bool=False, number_of_last_runs: int=0):
    test_executions, test_results = load_test_results(prefix, file_paths)
    logger.info('Generating chart...')
    if number_of_last_runs == 0:
        number_of_last_runs = len(test_executions)
    
    test_executions = test_executions[-number_of_last_runs:]

    # sharey=True prints the same range on all y axes -> good for global comparison of all response times
    # sharey=False adapts the scale for each test -> shows more details for each test
    fig, axs = plt.subplots(len(test_results), 1, sharex=True, sharey=False)

    if len(test_executions) > 50:
        width_per_test = 0.3
    else:
        width_per_test = 0.6
    
    width = max((width_per_test * len(test_executions)), 10)
    fig.set_size_inches(width, 1.5 * len(test_results))

    i = 0
    label_locations = np.arange(len(test_executions))

    for test_name in sorted(test_results.keys()):
        if not simplified:
            smallest_times = get_test_values(test_name, 'Smallest', test_results, test_executions)
            average_times = get_test_values(test_name, 'Average', test_results, test_executions)
            largest_times = get_test_values(test_name, 'Largest', test_results, test_executions)

            axs[i].plot(label_locations, smallest_times, label='Smallest', marker='o')
            axs[i].plot(label_locations, average_times, label='Average', marker='o')
            axs[i].plot(label_locations, largest_times, label='Largest', marker='o')
        else:       
            average_times = get_test_values(test_name, 'Average', test_results, test_executions)
            
            axs[i].plot(label_locations, average_times, label='Average', marker='o')

        y_lim = axs[i].get_ylim()
        axs[i].set_ylim(bottom=Decimal(y_lim[0] * 0.8).quantize(Decimal('1.0'), rounding=ROUND_DOWN),
                        top=Decimal(y_lim[1] * 1.2).quantize(Decimal('1.0'), rounding=ROUND_UP))

        axs[i].set_ylabel('Runtime (s)', loc='top')
        axs[i].set_xticks(label_locations)
        axs[i].set_xticklabels(format_labels(test_executions), rotation=45, ha='right')
        axs[i].set_title(test_name)
        axs[i].legend(loc="upper left", bbox_to_anchor=(1, 1))
        i = i + 1

        fig.align_ylabels()
        fig.tight_layout()

    chart_destination_path = Path(os.path.dirname(chart_destination))
    chart_destination_path.mkdir(parents=True, exist_ok=True)
    plt.savefig(chart_destination)
    logger.info(f'Saved chart as {os.path.basename(chart_destination)}')


def get_test_values(test_name: str, test_value_name: str, test_results: dict, test_executions: list) -> list:
    result = []
    test_result = test_results[test_name]
    for test_exec in test_executions:
        if test_exec in test_result:
            result.append(test_result[test_exec][test_value_name])
        else:
            # fill non-existent results with zeros
            result.append(None)
    return result


def format_labels(test_executions: list) -> list:
    return list(map(lambda x: f'{x[0]} / {format_timestamp(x[1])} / {x[2]}', test_executions))


def format_timestamp(timestamp: str) -> str:
    return datetime.datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M')


def dir_path(path):
    if os.path.isdir(path):
        return path
    else:
        raise argparse.ArgumentTypeError(f"{path} is not a valid path")


def main(test_results: str, generated_charts: str):
    for test_result_folder in glob.glob(os.path.join(test_results, '*/')):
        for test_result_version_folder in glob.glob(os.path.join(test_result_folder, '*/')):
            test_chart_destination = os.path.join(generated_charts, os.path.basename(os.path.normpath(test_result_folder)), os.path.basename(os.path.normpath(test_result_version_folder)))

            test_result_file_paths = glob.glob(os.path.join(test_result_version_folder, '*-test-results-*.json'))
            test_suite_naming_pattern = re.compile('(.+?)-test-results-.+.json')
            test_suite = re.match(test_suite_naming_pattern, os.path.basename(test_result_file_paths[0])).group(1)

            generate_chart(prefix=test_suite, chart_destination=os.path.join(test_chart_destination, f'{test_suite}-detailed-chart.png'), file_paths=test_result_file_paths)
            generate_chart(prefix=test_suite, chart_destination=os.path.join(test_chart_destination, f'{test_suite}-detailed-chart-with-most-recent-runs.png'), file_paths=test_result_file_paths, number_of_last_runs=15)
            generate_chart(prefix=test_suite, chart_destination=os.path.join(test_chart_destination, f'{test_suite}-simple-chart.png'), file_paths=test_result_file_paths, simplified=True)
            generate_chart(prefix=test_suite, chart_destination=os.path.join(test_chart_destination, f'{test_suite}-simple-chart-with-most-recent-runs.png'), file_paths=test_result_file_paths, simplified=True, number_of_last_runs=15)


if __name__ == '__main__':
    logger.info('Generating charts from performance test results...')

    parser = argparse.ArgumentParser(description='Create charts from performance test results')
    parser.add_argument('--test-results', type=dir_path, required=True,
                    help='absolute path to the test results folder')
    parser.add_argument('--generated-charts', type=dir_path, required=True,
                    help='absolute path where generated charts will be stored')
    args = parser.parse_args()
    logger.info(f'Loading test results from {args.test_results}')
    logger.info(f'Storing charts in {args.generated_charts}')

    main(test_results=args.test_results, generated_charts=args.generated_charts)
