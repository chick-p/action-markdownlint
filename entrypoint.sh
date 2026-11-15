#!/bin/sh

cd "$GITHUB_WORKSPACE"

# reviewdog's github-pr-review reporter shells out to git; the checkout is owned
# by a different uid than the container user, so mark it safe.
git config --global --add safe.directory "$GITHUB_WORKSPACE"

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# Use the version pinned by this action's lockfile, not whatever the caller's repo has.
MARKDOWNLINT=/action/node_modules/.bin/markdownlint

"$MARKDOWNLINT" --version

OUT=$(mktemp)

# Reset first: the action's args arrive here as positional parameters.
set --
# The local reporter has no PR to take a diff from and exits with "diff command
# is empty" unless -diff is given. Nothing is reported to a PR in this mode, so
# an empty diff is fine.
if [ "$INPUT_REPORTER" = "local" ]; then
  set -- -diff="git diff"
fi

# markdownlint-cli has no checkstyle formatter and prints violations to stderr as
# "<file>:<line>[:<col>] <rule> <message>"; hand that to reviewdog via errorformat.
"$MARKDOWNLINT" ${INPUT_MARKDOWNLINT_FLAGS:-.} 2>&1 \
  | tee "$OUT" \
  | reviewdog "$@" \
      -efm="%f:%l:%c %m" \
      -efm="%f:%l %m" \
      -name="markdownlint" \
      -reporter="${INPUT_REPORTER}" \
      -level="${INPUT_LEVEL}"
status=$?

# Exposed so CI can assert on detection independently of the reporter. grep -c
# exits 1 on zero matches, so it must not run before $? is captured above.
echo "violations=$(grep -c -E ' MD[0-9]+' "$OUT")" >> "${GITHUB_OUTPUT:-/dev/null}"

exit "$status"
