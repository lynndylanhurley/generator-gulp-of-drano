# generator-gulp-of-drano [![Build Status](https://secure.travis-ci.org/lynndylanhurley/generator-gulp-of-drano.png?branch=master)](https://travis-ci.org/lynndylanhurley/generator-gulp-of-drano)

> [Yeoman](http://yeoman.io) generator

## Install this generator

Make sure [Yeoman](http://yeoman.io) is installed.

```
$ npm install -g yo
```

To install generator-gulp-of-drano from npm, run:

```
$ npm install -g generator-gulp-of-drano
```

Finally, initiate the generator:

```
$ yo gulp-of-drano
```

## Generator stack

The generated app will include the following:

#### Languages
* [jade templates](http://jade-lang.com/)
* [sass stylesheets](http://sass-lang.com/)
* [coffeescript](http://coffeescript.org/)

#### Libraries
* [bootstrap](http://getbootstrap.com/)
* [jquery](http://jquery.com/)
* [angularjs](http://angularjs.org/)
* [angular-ui router](https://github.com/angular-ui/ui-router)
* [angular-strap](http://mgcrea.github.io/angular-strap/)
* [lodash](http://lodash.com/docs)
* [modernizr](http://modernizr.com/)

#### Testing
* [karma](http://karma-runner.github.io/0.12/index.html)
* [protractor](https://github.com/angular/protractor)
* [mocha](http://mochajs.org/)
* [chai](http://chaijs.com/guide/installation/)
* [sinon](http://sinonjs.org/)

---

## Using the generated app

### Start Live-reloading Dev Server

`gulp` - broadcast dev server to [localhost:xxxx](http://localhost:xxxx). use livereload for automatic refresh.

### Testing

#### Unit Tests

Unit tests use mocha + chai + sinon.

* `gulp test:e2e:once` - run all tests in `test/unit/**/*.coffee`.
* `gulp test:e2e:watch` - same as above, re-runs tests as they change.

#### E2E Tests

This project uses [protractor-ci](https://github.com/lynndylanhurley/protractor-ci) for E2E tests.

* `gulp test:e2e:once` - run all tests in `test/e2e/**/*.coffee`. bypasses proxy record/playback.
* `gulp test:e2e:watch` - same as above, re-runs tests as they change.
* `gulp test:e2e:record` - records all requests to external APIs for later playback.
* `gulp test:e2e:playback` - use mocked API requests for test suite. Useful for when API is unavailable.
* `gulp test:e2e:ci` - using the mocked API, run tests against Sauce Labs. This is used by the CI test runner.

---

### Deployment

This assumes the following, where `ENV_NAME` is the name of the target `NODE_ENV` (`production`, `staging`, etc.)

1. An heroku app exists, and its git remote is named `ENV_NAME`
1. The heroku app has its `NODE_ENV` set to `ENV_NAME` (using `heroku config:set`)
1. You have decrypted the `config/ENV_NAME.yml.example` file and copied its contents to `config/ENV_NAME.yml`.
1. There is an s3 bucket config defined in `config/ENV_NAME.yml`. see `config/production.yml.example` for an example configuration.

#### Minify, Compile, S3-Sync, Push to Heroku `production`

`gulp release`

#### Minify, Compile, S3-Sync, Push to Heroku `staging`

`gulp stage`

---
