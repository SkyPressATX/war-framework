#!/bin/bash
#Author: BMO & Antpb
#Version: 0.1.0-alpha

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
	git commit -am 'Pre WAR Update'
	git checkout -b ${temp_branch} && git pull ${framework_repo} ${framework_branch} --no-ff
	git add . --all && git commit -am 'Mid WAR Update'
	git checkout ${current_branch} && git checkout ${temp_branch} -- ${update_include}
	git branch -D ${temp_branch}
	git commit -am 'Post WAR Update'
	exit 0
}

assign_opts() {
	local OPTIND
	while getopts ":b:B:c:C:D:p:r:af" opt; do
		case $opt in
			a)
				ng_build="1";;
			b)
				temp_branch=$OPTARG;;
			B)
				remote_deploy_branch=$OPTARG;;
			c)
				commit_message=$OPTARG;;
			C)
				global_composer_path=$OPTARG;;
			D)
				deploy_from_branch=$OPTARG;;
			f)
				force_push="-f";;
			p)
				prefix_path=$OPTARG;;
			r)
				deploy_remote=$OPTARG;;
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
	assign_opts
	declare -F ${cmd} &>/dev/null && ${cmd} $* && exit 0 ||
		echo -e "\n\033[1;31m"Looks like you entered the wrong function."\033[1;000m\n\nUsage is: war <function> <optional argument>\n"
else
	echo -e "\nUsage is: war <function> <optional argument>\n"
fi
