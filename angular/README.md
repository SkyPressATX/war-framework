# WAR NG Template

This project was generated with [Angular CLI](https://github.com/angular/angular-cli) version 1.6.0.

## First Steps

### Install additional packages

```
ng new [name]
ng set --global packageManager=yarn
yarn add @skypress/wp-client@latest
```

Optional

```
yarn add ng-packagr@latest --dev
yarn add @ng-bootstrap/ng-bootstrap
```

### Edit Config Files

Edit the value of `outDir` in your new `.angular-cli.json`:

```
"outDir": "../wordpress/wp-content/themes/war-ng-template/src",
```

Optional:   

You can change the `prefix` as well to something other than `app`.

Set these `ng-cli` defaults if you'd like:

```
"defaults": {
  "styleExt": "css",
  "component": {
	  "spec": false,
	  "inlineStyle": true,
	  "inlineTemplate": true
  },
  "directive": {
	  "spec": false
  },
  "module": {
	  "spec": false
  },
  "service": {
	  "spec": false
  },
  "class": {
	  "spec": false
  }
}
```

If you installed `ng-packagr` then add new scripts to your `package.json`:

```
"build:<package name>": "ng-packagr -p src/app/<package name>/package.json"
```

Then, in `src/app/<package name>` make sure to have a `package.json` file:

```
{
	"name": "",
	"version": "",
	"keywords": [],
	"author": "",
	"license": "",
	"$schema": "../../../node_modules/ng-packagr/ng-package.schema.json",
	"ngPackage": {
		"lib": {
			"entryFile": "index.ts"
		},
		"dest": "<path relative to>/<package.json>"
	}
}
```

See https://www.npmjs.com/package/ng-packagr for more help


## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `-prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).
