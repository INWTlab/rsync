#!/bin/bash
set -o errexit -o nounset
addToDrat(){
  PKG_REPO=$PWD

  cd ..; mkdir drat; cd drat

  ## Set up Repo parameters
  git init
  git config user.name "Travis CI"
  git config user.email "sebastian.warnholz@inwt-statistics.de"
  git config --global push.default simple

  ## Get drat repo
  git remote add upstream "https://$GH_TOKEN@github.com/inwtlab/drat.git"
  git fetch upstream 2>err.txt
  cd docs

  Rscript -e "drat::insertPackage('$PKG_REPO/$PKG_TARBALL', \
    repodir = '.', \
    commit='Travis update: build $TRAVIS_BUILD_NUMBER')"
  git push 2> /tmp/err.txt

}
addToDrat
