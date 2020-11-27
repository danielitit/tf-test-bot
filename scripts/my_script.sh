#/bin/bash

set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "GITHUB_TOKEN environment variable is not set!"
	exit 1
fi
if [[ -z "$GITHUB_REPOSITORY" ]]; then
	echo "GITHUB_REPOSITORY environment variable is not set!"
	exit 1
fi
if [[ -z "$GITHUB_API_URL" ]]; then
	echo "GITHUB_API_URL environment variable is not set!"
	exit 1
fi

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token $GITHUB_TOKEN"
HEAD_BRANCH=development
BASE_BRANCH=staging

# Call last commit from base branch (staging)
API_RESPONSE=$(curl -X GET -s -H "${AUTH_HEADER}" -H "${API_HEADER}" \
          "${GITHUB_API_URL}/repos/$GITHUB_REPOSITORY/commits/${BASE_BRANCH}")

MERGE_COMMIT=$(echo "$API_RESPONSE" | jq -r .sha)

REPO_URL=https://x-access-token:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY.git
git config --global user.email "danielitit@gmail.com"
git config --global user.name "danielitit"

set -o xtrace

REVERT_BRANCH_NAME=revert-last-commit

git remote set-url origin $REPO_URL
git fetch origin $BASE_BRANCH
git checkout -b $REVERT_BRANCH_NAME origin/$BASE_BRANCH

git cat-file -t $MERGE_COMMIT
git revert $MERGE_COMMIT --no-edit
git push origin $REVERT_BRANCH_NAME
hub pull-request --no-edit
