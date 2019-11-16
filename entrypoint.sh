#!/bin/sh

cd "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -f "$(npm bin)/markdownlint" ]; then
  npm install
fi

$(npm bin)/markdownlint --version

if [ "${INPUT_REPORTER}" == 'github-pr-review' ]; then
  $(npm bin)/markdownlint -f checkstyle "${INPUT_MARKDOWNLINT_FLAGS:-'.'}" \
    | reviewdog -f=checkstyle -name="markdownlint" -diff="git diff HEAD^"  -reporter=github-pr-review -level="${INPUT_LEVEL}"
else
  $(npm bin)/markdownlint -f checkstyle "${INPUT_MARKDOWNLINT_FLAGS:-'.'}" \
    | reviewdog -f=checkstyle -name="markdownlint" -diff="git diff HEAD^" -reporter=github-pr-check -level="${INPUT_LEVEL}"
fi
