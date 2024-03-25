#!/bin/bash
#
 
# This script deletes all GitHub Actions runs for the current repository.
# It is useful for cleaning up the Actions tab after a large number of runs
# have been created, such as when testing a workflow.
 
# check for help flag (-h or --help)
if [[ $1 == "-h" || $1 == "--help" ]]; then
	echo "Usage: $0 [count]"
	echo "Deletes all GitHub Actions runs for the current repository."
	echo "The count argument is optional and defaults to 10."
	exit 0
fi
 
# default limit value: 10
limit=${1:-10}
 
# parse limit value
if ! [[ $limit =~ ^[0-9]+$ ]]; then
	echo "Invalid limit value: $limit"
	exit 2
fi
 
# transform $limit as number
limit=$(echo "$limit" | tr -d '[:space:]')
 
# check if gh is installed
if ! command -v gh &>/dev/null; then
	echo "gh could not be found. Please install it from https://cli.github.com/"
	exit 1
fi
 
# check if gh is authenticated
if ! gh auth status &>/dev/null; then
	echo "gh is not authenticated. Please run 'gh auth login' to authenticate."
	exit 1
fi
 
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner)
 
if [[ -z $repo ]]; then
	echo "No repository found."
	exit 1
fi
 
runs=$(gh run list --limit "$limit" --json databaseId -q '.[].databaseId')
 
if [[ -z $runs ]]; then
	echo "No runs found."
	exit 0
fi
 
total_runs=$(echo "$runs" | wc -l)
completed_runs=0
 
for run_id in $runs; do
	((completed_runs++))
	printf "\rDeleting run %d/%d with ID %s..." "$completed_runs" "$total_runs" "$run_id"
	gh api -X DELETE "repos/$repo/actions/runs/$run_id" --silent
done
 
printf "\nAll runs have been deleted"
