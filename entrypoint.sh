#!/bin/sh

cd "$GITHUB_WORKSPACE"

# reviewdog's github-pr-review reporter shells out to git; the checkout is owned
# by a different uid than the container user, so mark it safe.
git config --global --add safe.directory "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Use the version pinned by this action's lockfile, not whatever the caller's repo has.
MARKDOWNLINT=/action/node_modules/.bin/markdownlint

"$MARKDOWNLINT" --version

# markdownlint-cli has no checkstyle formatter and prints violations to stderr as
# "<file>:<line>[:<col>] <rule> <message>"; hand that to reviewdog via errorformat.
"$MARKDOWNLINT" ${INPUT_MARKDOWNLINT_FLAGS:-.} 2>&1 \
  | reviewdog \
      -efm="%f:%l:%c %m" \
      -efm="%f:%l %m" \
      -name="markdownlint" \
      -reporter="${INPUT_REPORTER}" \
      -level="${INPUT_LEVEL}"
