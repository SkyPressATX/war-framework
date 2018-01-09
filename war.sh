#!/bin/bash
#Author: BMO & Antpb
#Version: 0.2.0-alpha

#### CLI Config File ####
source ./war-cli.config

set (){
	sed -Ei '' "s/^(${1}=).*/\1\"${2}\"/" ${config_file}
	exit 0
}

#### Functions #####
init (){ local OPTIND

}

## war deploy -a (Build Angular) -b <temp deploy branch> -B <remote deploy branch> -c <commit message> -C <composer path> -D <deploy from branch> -f (force push) -p <prefix path> -r <remote name>
deploy (){
	echo -e "${br}Splitting out WordPress into temporary branch"
	git add . --all && git commit -am "${commit_message}" && git checkout ${deploy_from_branch}
	git subtree split --prefix=${prefix_path} -b ${temp_branch} && git checkout ${temp_branch}
	echo -e "${br}Running composer install for plugins and themes"
	find wp-content -maxdepth 3 -iname "composer.json" -type f -execdir php ${global_composer_path} install --no-dev --prefer-source -o \;
	find wp-content -iname ".git" -type d -exec rm -rf "{}" \;
	echo -e "${br}Pushing ${temp_branch} to ${deploy_remote}:${remote_deploy_branch}"
	git add . --all && git commit -am "${commit_message}" && git push ${force_push} ${deploy_remote} ${temp_branch}:${remote_deploy_branch}
	echo -e "${br}Cleaning up after ourselves"
	git checkout ${current_branch} && git branch -D ${temp_branch}
	rm -rf ./wp-content
	exit 0
}

update (){
	echo -e "${br}Pulling in updated files"
	git checkout ${war_framework_repo}/${war_framework_branch} -- ${update_include}
	git add . --all && git commit -am "Post WAR Update"
	exit 0
}

check-config (){
	config-vars=(
		"angular_build"
		"app_slug"
		"commit_message"
		"deploy_from_local_branch"
		"deploy_to_remote_branch"
		"deploy_to_remote_repo"
		"global_composer_path"
		"force_push"
		"prefix_path"
		"temp_branch"
		"update_include"
		"war_framework_repo"
		"war_framework_branch"
	)
	if [ -f ${config_file} ]; then
		touch ${config_file}
	fi
	for v in ${config-vars[*]}; do

	done

}

assign-opts() {
	local OPTIND
	while getopts ":aA:b:B:G:D:fm:p:r:" opt; do
		case $opt in
			a)
				angular_build=true;;
			A)
				app_slug=$OPTARG;;
			b)
				temp_branch=$OPTARG;;
			B)
				deploy_to_remote_branch=$OPTARG;;
			G)
				global_composer_path=$OPTARG;;
			D)
				deploy_from_local_branch=$OPTARG;;
			f)
				force_push=true;;
			m)
				commit_message=$OPTARG;;
			p)
				prefix_path=$OPTARG;;
			r)
				deploy_to_remote_repo=$OPTARG;;
		esac
	done
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	config_file="./war-cli.config"
	br="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	epoch=$(date +%s)
}

#### Process Commands ####
if [[ -n ${1} ]]; then
	cmd=${1}
	shift 1
	assign-opts
	declare -F ${cmd} &>/dev/null && ${cmd} $* && exit 0 ||
		echo -e "\n\033[1;31m"Looks like you entered the wrong function."\033[1;000m\n\nUsage is: war <function> <optional argument>\n"
else
	echo -e "\nUsage is: war <function> <optional argument>\n"
fi
