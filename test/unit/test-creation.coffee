suite "gulp-of-drano generator", ->
  test "generator creates expected files", (done) ->
    expected = [
      ".jshintrc"
      ".editorconfig"
      ".gitattributes"
      ".gitignore"
      ".jshintrc"
      "app.js"
      "bower.json"
      "gulpfile.js"
      "package.json"
      "README.md"
      "Procfile"
      "app/images/sprites/mlp.png"
      "app/images/logo.png"
      "app/scripts/controllers/pages/index.coffee"
      "app/scripts/controllers/pages/style-guide.coffee"
      "app/scripts/controllers/main.coffee"
      "app/scripts/directives/scroll-to.coffee"
      "app/scripts/app.coffee"
      "app/styles/globals/vars.styl"
      "app/styles/globals/mixins.styl"
      "app/styles/pages/index.lg.styl"
      "app/styles/pages/index.md.styl"
      "app/styles/pages/index.sm.styl"
      "app/styles/pages/index.xs.styl"
      "app/styles/pages/style-guide.xs.styl"
      "app/styles/degrade.styl"
      "app/styles/deps.scss"
      "app/styles/main.styl"
      "app/views/partials/style-guide/popover.jade"
      "app/views/404.jade"
      "app/views/terms.jade"
      "app/views/style-guide.jade"
      "app/.htaccess"
      "app/404.html"
      "app/index.jade"
      "app/favicon.ico"
      "app/robots.txt"
      "config/production.yml.example"
      "config/default.yml"
      "server/s3.js"
      "test/e2e/sanity.coffee"
      "test/unit/sanity.coffee"
      "test/test-helper.coffee"
    ]

    helpers.mockPrompt @app,
      ok: true

    @app.options["skip-install"] = true
    @app.run {}, ->
      helpers.assertFile expected
      done()

  suite 'subgenerators', ->
    test 'a new controller is generated', (done) ->
      subGeneratorTest({
        generatorType:   'controller'
        specType:        'controller'
        targetDirectory: 'controllers/pages'
        scriptNameFn:    _.classify
        specNameFn:      _.classify
        suffix:          'Ctrl'
      }, done)
