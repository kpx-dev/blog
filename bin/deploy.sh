#!/bin/bash

set -e
set -o pipefail

HUGO_VERSION=0.59.1

echo "Downloading hugo v$HUGO_VERSION"
curl -sSL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz > /tmp/hugo.tar.gz && tar -f /tmp/hugo.tar.gz -xz -C /tmp

cp /tmp/hugo . && ./hugo
rm -rf hugo

# TODO: detect changes within /docs only
if git diff --exit-code; then
    echo "No diff, skipping deploy"
    exit 0
fi

echo 'Committing the site to git and pushing'
(
    git config --global user.email "actions@github.com"
    git config --global user.name "Github Actions"
    git remote rm origin
    git remote add origin https://kienpham2000:${GITHUB_TOKEN}@github.com/kienpham2000/blog.git
    git checkout -b master
    git add . && \
    git commit -m "Publishing site $(date)" && \
    git push --set-upstream origin master
)

echo 'Complete'
