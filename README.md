# WAR Framework
This repo holds the build and local development functions for new projects

*v0.4.4-alpha*

## Requires:

* Yarn
* Global @angular/cli
* Composer
* Docker
* Docker Compose

*This document places <example> snippets within it's code. These <examples> are what you will need to changed with your own custom values*

## Step 1: Clone Repo

To get you project started with the WAR Framework, clone this repo into a new directory. Once cloned, all other commands should be ran from within `<directory-to-my-app>`

```
git clone https://github.com/SkyPressATX/war-framework.git <directory-to-my-app>
cd <directory-to-my-app>
```

## Step 2: Setup local WordPress with Docker

Included in the WAR Framework is a basic `docker-compose.yml` that will setup WordPress, MySQL, and PHPMyAdmin

```
docker-compose up -d
```

We include `-d` to in order to detach this command from your terminal.

Once all containers are up, navigate to `http://localhost:8080` in your web browser. You should see the famous 5 Minute install screen. Install WordPress like normal.

*If you are running Linux, you might need to change the file/folder permissions after your docker containers are setup*

```
sudo find wordpress -type d -exec chmod 775 {} \; && sudo find wordpress -type f -exec chmod 664 {} \;
```

## Step 3: Initialize your project with the WAR-cli

The WAR Framework comes with basic CLI to help keep things uniform. This is the `war.sh` script, and it's corresponding `war-cli.config` config file.

```
./war.sh init -A <my-app-name> -P <angular_prefix> -a
```

The `init` command will:

* Set proper variables in `war-cli.config`
* Rename the starter plugin to `wordpress/wp-content/plugins/<my-app-name>-api` and it's main `.php` file to `<my-app-name>-api.php`
* Run `composer install` in `wordpress/wp-content/plugins/<my-app-name>-api`
* Rename the starter theme to `wordpress/wp-content/themes/<my-app-name>-theme`
* Run `composer install` in `wordpress/wp-content/themes/<my-app-name>-theme`
* Create a new Angular Project in `angular/<my-app-name>` if `-a` flag is used
* Run `yarn add @skypress/wp-client@latest` in `angular/<my-app-name>`
* Set proper `outDir` and `angular_prefix` values in `angular/<my-app-name>/.angular-cli.json`
* Set proper Directive call in `wordpress/wp-content/themes/<my-app-name>-theme/index.php`

_The `init` command will **not**_

* Edit comment blocks in `wordpress/wp-content/plugins/<my-app-name>-api/<my-app-name>-api.php`
* Edit comment blocks in `wordpress/wp-content/themes/<my-app-name>-theme/style.css`

## Step 4: Set up remote git repositories

In order to version control you new project, you will need to setup your own remote git repositories. We recommend having at least 2 different repo's:

* A Dev or Pre-Build repo. This is where you can push, pull, and others can contribute to your project and code. This is not your Live or Production version.
* A Prod or Live repo. This should be a highly restricted repo where few people can push to. This should also be where your built project should be served to the rest of the world (IE: Your hosting provider)

```
git remote add <dev> <git@github.com:<your-git-user>/<repo-name>.git
git remote add <prod> <git@<git.myhost.com>:production/<repo-name>.git
```

## Step 5: Build your App

You are setup! Now you can build out your application. Here are some tips to help you along the way:

* Use `ng generate` in your Angular project (`angular/<my-app-name-theme>`) to quickly build components, modules, etc ...
* Use `ng serve` to get a fresh version of your pre-build angular app in `http://localhost:4200`
* Once your template is set, and you are ready to pipe in data from the WordPress REST API, use `ng build --watch`
 * _Please note, my success with this has been decent at best. You may want to just run `ng build` after each change_

## Step 6: Deploy your App

Alright, everything is looking great and you are ready to deploy live, but you've got a main repo pushing your un-built site to your dev repo. Use the WAR CLI to properly split out the WordPress parts of your project and push them to your remote Production repo

```
./war.sh deploy -a -r <prod> -c "My commit message"
```

##### Flags

* `-a` Build your Angular app
* `-r <prod>` Is the name you gave your remote production repo. See `git remote -v` for the full list of your added repo names
* `-c "My commit message"` The message you would like to see in your commit

_Want to stop using these flags every time? Have errors about the composer command not being found? Edit the `war-cli.config` file!_

## Step 7: (Optional) Update Project

We've made some updates that you'd like to use, but you don't want to overwrite your changes to this project. A `git pull origin master` would certainly do that. Use the WAR CLI instead:

```
./war.sh upgrade
```

This will use `git` to pull in the specific files that aren't relative to your project, instead of the entire framework. Made changes to some files this command updates? Remove them from the `war-cli.config` option `upgrade_include`
