#!/bin/bash
#Author: BMO
#Version: 0.1.0-alpha

if [[ -n ${2} ]]; then
	root=${2}
else
	root="/usr/local/bin/composer"
fi

if [[ -n ${1} ]]; then
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	echo -e "Splitting out WordPress into temporary branch"
	git subtree split --prefix=wordpress -b shipit && git checkout shipit
	echo -e "Running composer install for plugins and themes"
	find wp-content -maxdepth 3 -iname "composer.json" -type f -execdir php ${root} install --no-dev --prefer-source -o \;
	find wp-content -iname ".git" -type d -exec rm -rf "{}" \;
	echo -e "Pushing temporary branc"
	git add . --all && git commit -am "Pre-ship commit" && git push -f ${1} shipit:master
	echo -e "Cleaning up after ourselves"
	git checkout ${current_branch} && git branch -D shipit
	rm -rf ./wp-content
	exit 0
fi
