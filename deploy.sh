#!/bin/bash
set -o errexit -o nounset
addToDrat(){
  PKG_REPO=$PWD

  cd ..
  git clone https://$GH_TOKEN@github.com/inwtlab/drat.git
  cd drat/docs
  git config user.name "Travis CI"
  git config user.email "sebastian.warnholz@inwt-statistics.de"
  git config --global push.default simple

  Rscript -e "install.packages('drat')"
  Rscript -e "drat::insertPackage('$PKG_REPO/$PKG_TARBALL', repodir = '.')"
  git add --all
  git commit -m "Travis update: build $TRAVIS_BUILD_NUMBER"
  git push 2> /tmp/err.txt

}
addToDrat
