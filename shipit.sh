#!/bin/bash
#Author: BMO
#Version: 0.1.0-alpha


if [[ -n ${1} ]]; then
	if [[ -n ${2} ]]; then root=${2} else root="/usr/local/bin/composer.phar" fi
	dir=$(pwd -P)
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	git subtree split --prefix=wordpress -b shipit
	git checkout shipit
	find wp-content -type f -iname "composer.json" -d 3 -execdir php ${root} install --no-dev --prefer-source -o \;
	git add . --all
	git commit -am "Pre-ship commit"
	git push -f ${1} :shipit
	git checkout ${current_branch}
	git branch -D shipit
	exit 0
fi
