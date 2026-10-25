FROM node:24-alpine@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53

ARG REVIEWDOG_VERSION=v0.21.2
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/${REVIEWDOG_VERSION}/install.sh | sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION}
RUN apk --update add git && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

# Unpinned on purpose: pnpm switches itself to the version in "packageManager"
# of package.json (pmOnFail: download), which keeps that field the only place
# the version is written.
RUN npm install -g pnpm

WORKDIR /action
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh"]
