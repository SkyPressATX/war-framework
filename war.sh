#!/bin/bash
#Author: BMO & Antpb
#Version: 0.4.1-alpha

### Not a command ###
assign-opts() {
	local OPTIND
	while getopts ":aA:b:B:G:D:fm:p:P:r:" opt; do
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
				force_push="-f";;
			m)
				commit_message=$OPTARG;;
			p)
				prefix_path=$OPTARG;;
			P)
				angular_prefix=$OPTARG;;
			r)
				deploy_to_remote_repo=$OPTARG;;
		esac
	done
	### Common Variables ###
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	br="++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n"
	epoch=$(date +%s)
}

#### Functions ####
## war set <config_key> <config_value>
config-set (){
	sed -Ei '' "s/^(${1}=).*/\1\"${2}\"/" ${config_file}
}

## war init
init (){
	echo -e "${br}Checking Config"
	rm ${config_file}
	check-config

	echo -e "${br}Setting custom variable in Config"
	config-set angular_prefix ${angular_prefix}
	config-set app_slug ${app_slug}
	config-set prefix_path ${prefix_path}

	echo -e "${br}Setting up Plugin and Theme"
	mv ${prefix_path}/wp-content/plugins/my-api/my-api.php ${prefix_path}/wp-content/plugins/my-api/${app_slug}-api.php
	mv ${prefix_path}/wp-content/plugins/my-api ${prefix_path}/wp-content/plugins/${app_slug}-api
	mv ${prefix_path}/wp-content/themes/my-theme ${prefix_path}/wp-content/themes/${app_slug}-theme

	echo -e "${br}Installing Composer for Plugin and Theme"
	if [[ ! -f ${global_composer_path} ]]; then
		echo "${br}No Global Composer Path found, Check wp-cli.config and set accordingly"
		exit 1;
	fi
	find wp-content -maxdepth 3 -iname "composer.json" -type f -execdir php ${global_composer_path} install --no-dev --prefer-source -o \;

	if [[ true == ${angular_build} ]]; then
		echo -e "${br}Building Angular project : ${app_slug}-theme"
		find angular -type f -iname "README.md" -execdir ng new ${app_slug} -is true -it true -p ${angular_prefix} -sg true \;
		sed -Ei '' "s/^(\"outDir\"\:\s)\"dist\"$/\1\"..\/..\/wordpress\/wp-content\/themes\/${app_slug}-theme\/src\"/" angular/${app_slug}/.angular-cli.json

		echo -e "${br}Adding WP Client"
		find angular/${app_slug} -maxdepth 1 -type f -iname "package.json" -execdir yarn add @skypress/wp-client@latest \;
		find angular/${app_slug} -maxdepth 1 -type f -iname "package.json" -execdir yarn upgrade \;
	fi
}

## war deploy -a (Build Angular) -b <temp deploy branch> -B <remote deploy branch> -c <commit message> -C <composer path> -D <deploy from branch> -f (force push) -p <prefix path> -r <remote name>
deploy (){
	if [[ -z ${commit_message} ]]; then
		commit_message="Deploy"
	fi

	echo -e "${br}Saving current work"
	git add . --all && git commit -am "${commit_message}"
	git checkout ${deploy_from_local_branch}

	if [[ ${angular_build} == true ]]; then
		echo -e "${br}Building Angular Files"
		find angular -maxdepth 2 -iname "package.json" -type f -execdir yarn build \;
		echo -e "${br}Commiting build before split"
		git add . --all && git commit -am "${commit_message}"
	fi

	echo -e "${br}Splitting out WordPress into temporary branch"
	git subtree split --prefix=${prefix_path} -b ${temp_branch}
	git checkout ${temp_branch}

	echo -e "${br}Running composer install for plugins and themes"
	find wp-content -maxdepth 3 -iname "composer.json" -type f -execdir php ${global_composer_path} install --no-dev --prefer-source -o \;
	find wp-content -iname ".git" -type d -execdir rm -rf .git \;

	echo -e "${br}Pushing ${temp_branch} to ${deploy_deploy_to_remote_repoemote}:${deploy_to_remote_branch}"
	git add . --all && git commit -am "${commit_message}"
	git pull -Xtheirs ${deploy_to_remote_repo} ${deploy_to_remote_branch}
	git push ${force_push} ${deploy_to_remote_repo} ${temp_branch}:${deploy_to_remote_branch}

	echo -e "${br}Cleaning up after ourselves"
	git checkout ${current_branch}
	git branch -D ${temp_branch}
	rm -rf ./wp-content
}

## war deploy
update (){
	if [[ -z ${commit_message} ]]; then
		commit_message="Post WAR Update"
	fi

	echo -e "${br}Fetching from WAR Framework Remote"
	git fetch ${war_framework_repo} ${war_framework_branch}

	echo -e "${br}Pulling in updated files"
	git checkout ${war_framework_repo}/${war_framework_branch} -- ${update_include}
	git add . --all && git commit -am "${commit_message}"
}

## war check-config
check-config (){
	#### CLI Config File ####
	config_file="./war-cli.config"
	config_vars=( "angular_build" "angular_prefix" "app_slug" "commit_message" "deploy_from_local_branch" "deploy_to_remote_branch" "deploy_to_remote_repo" "global_composer_path" "force_push" "prefix_path" "temp_branch" "update_include" "war_framework_repo" "war_framework_branch" )
	if [ ! -f ${config_file} ]; then
		echo "##### WAR Cli Config #####" > ${config_file}
	fi
	for v in ${config_vars[*]}; do
		if [[ -z $(grep "${v}" ${config_file}) ]]; then
			case ${v} in
				"angular_build")
					echo ${v}'=false' >> ${config_file};;
				"angular_prefix")
					echo ${v}'="app"' >> ${config_file};;
				"app_slug")
					echo ${v}'="'$(basename $(pwd))'"' >> ${config_file};;
				"commit_message")
					echo ${v}'=""' >> ${config_file};;
				"deploy_from_local_branch")
					echo ${v}'="master"' >> ${config_file};;
				"deploy_to_remote_branch")
					echo ${v}'="master"' >> ${config_file};;
				"deploy_to_remote_repo")
					echo ${v}'="prod"' >> ${config_file};;
				"global_composer_path")
					echo ${v}'="'$(find /usr/local/bin -type f -iname "composer*")'"' >> ${config_file};;
				"force_push")
					echo ${v}'=""' >> ${config_file};;
				"prefix_path")
					echo ${v}'="wordpress"' >> ${config_file};;
				"temp_branch")
					echo ${v}'="temp"' >> ${config_file};;
				"update_include")
					echo ${v}'="war.sh docker-compose.yml .gitignore wordpress/.gitignore"' >> ${config_file};;
				"war_framework_branch")
					echo ${v}'="master"' >> ${config_file};;
				"war_framework_repo")
					echo ${v}'="origin"' >> ${config_file};;
			esac
		fi
	done
}

#### Process Commands ####
if [[ -n ${1} ]]; then
	cmd=${1}
	shift 1
	check-config
	source ${config_file}
	assign-opts $*
	declare -F ${cmd} &>/dev/null && ${cmd} && exit 0 ||
		echo -e "\n\033[1;31m"Looks like you entered the wrong function."\033[1;000m\n\nUsage is: war <function> <optional argument>\n"
else
	echo -e "\nUsage is: war <function> <optional argument>\n"
fi
