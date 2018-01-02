# NG WAR Theme
This is the pre-build structure of an Angular project. The following adjustments compliment our workflow for creating a WordPress theme based on Angular.

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
"outDir": "../../wordpress/wp-content/themes/war-ng-template/src",
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
