# <%= projectName %>

Web interface for databox.

## Requirements

|name | installation|
|---|---|
|[git](http://git-scm.com/)| [`brew`](http://brew.sh/) `install git` |
|[nodejs](http://nodejs.org/)| [`brew`](http://brew.sh/) `install node`
|[xquartz](http://xquartz.macosforge.org/landing/)| [`brew cask`](https://github.com/caskroom/homebrew-cask) `install xquartz` |
|[cairo](http://cairographics.org/)| [`brew`](http://brew.sh/) `install cairo`|
|[git-crypt](https://www.agwa.name/projects/git-crypt/)| [`brew`](http://brew.sh/) `install git-crypt` |

## Installation
1. `npm install` - install all server-side deps
1. `bower install` - install all client-side deps

### Encrypt secret keys
Are you the creator of this repo? If so, encrypt the `config/*.yml.example` files using [git-crypt](https://www.agwa.name/projects/git-crypt/).

1. `git-crypt keygen ~/path/to/key` - generate a key for this project
1. `git-crypt init ~/path/to/key` - initialize this repo for git-crypt
1. `cp config/*.yml.example config/*.yml` - copy encrypted secrets file to git-ignored file

### Decrypt secret keys
Have you just been added to this repo? If so, decrypt the `config/*.yml.example` files using [git-crypt](https://www.agwa.name/projects/git-crypt/).

1. Get the key from the project owner and save it to `~/path/to/key`
1. `git-crypt init ~/path/to/key`
1. `cp config/*.yml.example config/*.yml` - copy encrypted secrets file to git-ignored file

### Etc.

#### Cairo

Is $PKG_CONFIG_PATH defined? (check using `echo $PKG_CONFIG_PATH`). If not, add the value to your ENV:

~~~bash
echo "export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/opt/X11/lib/pkgconfig" > ~/.bashrc
~~~

Replace `.bashrc` with your relevant shell rc file (`.zshrc`, `.fishrc`, or whatever).

---

## Usage

### Start Dev Server
`gulp` - broadcast dev server to [localhost:<%= devPort %>](http://localhost:<%= devPort %>). use livereload for automatic refresh.

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

#### Push to heroku `production` env

`gulp release`

#### Push to heroku `staging` env

`gulp stage`

---

## Stack

This app includes the following:

#### Languages
* [jade templates](http://jade-lang.com/)
* [sass stylesheets](http://sass-lang.com/)
* [coffeescript](http://coffeescript.org/)

#### Libraries
* [bootstrap](http://getbootstrap.com/)
* [nib](http://visionmedia.github.io/nib/)
* [jquery](http://jquery.com/)
* [angularjs](http://angularjs.org/)
* [angular-ui router](https://github.com/angular-ui/ui-router)
* [angular-strap](http://mgcrea.github.io/angular-strap/)
* [lodash](http://lodash.com/docs)
* [modernizr](http://modernizr.com/)

#### Testing
* [karma](http://karma-runner.github.io/0.12/index.html)
* [protractor](https://github.com/angular/protractor)
* [mocha](http://visionmedia.github.io/mocha/)
* [chai](http://chaijs.com/guide/installation/)
* [sinon](http://sinonjs.org/)

---
