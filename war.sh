#!/bin/bash
#Author: BMO & Antpb
#Version: 0.1.0-alpha

#### CLI Config File ####
source ./war-cli.config
#################### Formatting Vars ####################
br="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
epoch=$(date +%s)

#### Functions #####
init (){ local OPTIND

}

## war deploy -a (Build Angular) -b <local deploy branch> -B <remote deploy branch> -c <commit message> -C <composer path> -D <deploy from branch> -f (force push) -p <prefix path> -r <remote name>
deploy (){
	local OPTIND
	while getopts ":b:B:c:C:D:p:r:af" opt; do
		case $opt in
			a)
				ng_build="1";;
			b)
				temp_deploy_branch=$OPTARG;;
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
	echo -e "Splitting out WordPress into temporary branch"
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	git add . --all && git commit -am "${commit_message}" && git checkout ${deploy_from_branch}
	git subtree split --prefix=${prefix_path} -b ${temp_deploy_branch} && git checkout ${temp_deploy_branch}
	echo -e "Running composer install for plugins and themes"
	find wp-content -maxdepth 3 -iname "composer.json" -type f -execdir php ${global_composer_path} install --no-dev --prefer-source -o \;
	find wp-content -iname ".git" -type d -exec rm -rf "{}" \;
	echo -e "Pushing ${temp_deploy_branch} to ${deploy_remote}:${remote_deploy_branch}"
	git add . --all && git commit -am "${commit_message}" && git push ${force_push} ${deploy_remote} ${temp_deploy_branch}:${remote_deploy_branch}
	echo -e "Cleaning up after ourselves"
	git checkout ${current_branch} && git branch -D ${temp_deploy_branch}
	rm -rf ./wp-content
	exit 0
}

upgrade (){ local OPTIND

}

#### Process Commands ####
if [[ -n ${1} ]]; then
	cmd=${1}
	shift 1
	declare -F ${cmd} &>/dev/null && ${cmd} $* && exit 0 ||
		echo -e "\n\033[1;31m"Looks like you entered the wrong function."\033[1;000m\n\nUsage is: war <function> <optional argument>\n"
else
	echo -e "\nUsage is: war <function> <optional argument>\n"
fi
