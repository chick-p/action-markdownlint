#!/bin/sh

cd "$GITHUB_WORKSPACE"

# reviewdog's github-pr-review reporter shells out to git; the checkout is owned
# by a different uid than the container user, so mark it safe.
git config --global --add safe.directory "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

if [ ! -x "./node_modules/.bin/markdownlint" ]; then
  npm install
fi

./node_modules/.bin/markdownlint --version

# markdownlint-cli has no checkstyle formatter and prints violations to stderr as
# "<file>:<line>[:<col>] <rule> <message>"; hand that to reviewdog via errorformat.
./node_modules/.bin/markdownlint ${INPUT_MARKDOWNLINT_FLAGS:-.} 2>&1 \
  | reviewdog \
      -efm="%f:%l:%c %m" \
      -efm="%f:%l %m" \
      -name="markdownlint" \
      -reporter="${INPUT_REPORTER}" \
      -level="${INPUT_LEVEL}"
