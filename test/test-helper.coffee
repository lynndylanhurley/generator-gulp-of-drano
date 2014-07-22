global.chai      = require('chai')
global.sinonChai = require('sinon-chai')
global.path      = require("path")
global.helpers   = require("yeoman-generator").test
global.assert    = require('assert')
global._         = require('underscore')
global._.str     = require('underscore.string')

# merge underscore string into underscore ns
_.mixin(_.str.exports())

# show stacktrace (off by default)
#chai.config.includeStack = true

global.expect         = chai.expect
global.AssertionError = chai.AssertionError
global.Assertion      = chai.Assertion
global.assert         = chai.assert

# TODO: test different opts
global.genOptions = {}

global.testDir = path.join(__dirname, "temp")

setup (done) ->
  helpers.testDirectory testDir, ((err) ->
    return done(err) if err
    opts =
      projectName: "Krystal Enterprises, Ltd."
      siteUrl:     "krystal-enterprises.biz"
      devPort:     9000

    @app = helpers.createGenerator("gulp-of-drano:app", ["../../app"], false, opts)
    done()
  ).bind(this)


### helper methods ###
global.subGeneratorTest = (opts, done) ->
  name = opts.name || "chong"
  deps = ['../../app']
  genTester = helpers.createGenerator("gulp-of-drano:" + opts.generatorType, deps, [name], genOptions)
  genTester.run [], ->
    helpers.assertFileContent [
      [
        path.join("app/scripts", opts.targetDirectory, name + ".js")
        new RegExp(opts.generatorType + "\\('" + 
          opts.scriptNameFn(name) + suffix + "'", "g")
      ]
      [
        path.join("test/spec", opts.targetDirectory, name + ".js")
        new RegExp("describe\\('" + _.classify(opts.specType) +
          ": " + opts.specNameFn(name) + opts.suffix + "'", "g")
      ]
    ]
    done()
