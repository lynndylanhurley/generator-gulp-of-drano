gulp       = require('gulp')
sprite     = require('css-sprite').stream
es         = require('event-stream')
seq        = require('run-sequence')
lazypipe   = require('lazypipe')
bowerFiles = require('main-bower-files')
pXor       = require('protractor-ci')
del        = require('del')
path       = require('path')
pngcrush   = require('imagemin-pngcrush')

LIVERELOAD_PORT = 35729

paths =
  development: '.tmp'
  production: 'dist-production'


# Load plugins
$ = require('gulp-load-plugins')()

# TODO: break out into modules
$.injectAppFiles = require('./lib/gulp-inject-assets')
$.userefStream   = require('./lib/gulp-useref-stream')
$.dumbSass       = require('./lib/gulp-dumb-sass')


# global refs
config          = null
sassFilter      = null
jsFilter        = null
jsTmplFilter    = null
coffeeFilter    = null
spriteFilter    = null
imgFilter       = null
indexFilter     = null
indexHTMLFilter = null
cssFilter       = null
fontFilter      = null
xdFilter        = null
publisher       = null
isCompiled      = '**/*.{js,css,html,jpg,png,gif,eot,svg,ttf,woff}'
textFileFilter  = null


initEnv = (envName) ->
  # ensure that env name set
  process.env.NODE_ENV ?= envName || 'development'

  # set dist dir
  process.env.DIST_DIR = paths[process.env.NODE_ENV]

  # set tag for release
  process.env.TAG = process.env.NODE_ENV + '-' + new Date().getTime()

  # load config after env has been determined
  config = require('config')


# re-init filters for each task
initFilters = ->
  sassFilter      = $.filter('styles/**/{,_}*.{sass,scss}')
  jsFilter        = $.filter('scripts/**/*.js')
  jsTmplFilter    = $.filter('views/**/*.jade')
  coffeeFilter    = $.filter('scripts/**/*.coffee')
  spriteFilter    = $.filter('images/sprites/**/*.png')
  imgFilter       = $.filter('images/**/*')
  indexFilter     = $.filter('index.jade')
  indexHTMLFilter = $.filter('index.html')
  cssFilter       = $.filter('styles/**/*.css')
  textFileFilter  = $.filter('**/*.{js,css,html,txt,json}')
  fontFilter      = $.filter('**/*.{eot,svg,ttf,woff}')
  xdFilter        = $.filter('**/cross-domain/respond*.*')


# app-sass
processSass = lazypipe()
  .pipe(-> sassFilter)
  .pipe(-> $.sass({
    includePaths: [
      'app/bower_components/font-awesome/scss'
      'app/bower_components/bootstrap-sass-official/assets/stylesheets'
    ]
  }))
  .pipe(-> $.autoprefixer('last 1 version'))
  .pipe(-> sassFilter.restore())


# app-js
processAppJs = lazypipe()
  .pipe(-> jsFilter)
  .pipe(-> $.cached('js'))
  .pipe(-> $.jshint('.jshintrc'))
  .pipe(-> $.jshint.reporter('default'))
  .pipe(-> $.remember('js'))
  .pipe(-> jsFilter.restore())


postProcessJS = lazypipe()
  .pipe(-> $.ngAnnotate({
    add: true,
    single_quotes: true
  }))
  .pipe(-> $.uglify())


# app-coffee
processAppCoffee = lazypipe()
  .pipe(-> coffeeFilter)
  .pipe(-> $.cached('coffee'))
  .pipe(-> $.coffee({bare: true}))
  .pipe(-> $.remember('coffee'))
  .pipe(-> coffeeFilter.restore())


# sprites
processSprites = lazypipe()
  .pipe(-> spriteFilter)
  .pipe(-> $.cached('sprites'))
  .pipe(-> sprite({
    cssPath:   '/images',
    processor: 'scss',
    style:     '_sprite.scss'
    name:      'sprite'
    retina:    true
  }))
  .pipe(-> $.if('*.png', gulp.dest('app/images/'), gulp.dest('app/styles/include/')))


# js templates
processJSTemplates = lazypipe()
  .pipe(-> jsTmplFilter)
  .pipe(-> $.cached('js-tmpl'))
  .pipe(-> $.jade())
  .pipe(-> $.ngHtml2js({
    moduleName: '<%= _.camelize(projectName.toLowerCase()) %>Partials'
  }))
  .pipe(-> $.remember('js-tmpl'))
  .pipe(-> jsTmplFilter.restore())


# flatten fonts into /fonts dir
processFonts = lazypipe()
  .pipe(-> fontFilter)
  .pipe(-> $.cached('fonts'))
  .pipe(-> $.rename({
    dirname: 'fonts'
  }))
  .pipe(-> $.remember('fonts'))
  .pipe(-> fontFilter.restore())


# flatten xd files into /cross-domain dir
processXDProxy = lazypipe()
  .pipe(-> xdFilter)
  .pipe(-> $.cached('xd-proxy'))
  .pipe(-> $.rename({
    dirname: 'cross-domain'
  }))
  .pipe(-> $.remember('xd-proxy'))
  .pipe(-> xdFilter.restore())


# inject ie8 deps
injectLegacyDeps = lazypipe()
  .pipe($.inject, gulp.src(bowerFiles()).pipe($.filter((f) ->
    /legacy/.test(f.path)
  ), {read: false}), {
    ignorePath: ['app'],
    starttag: '<!bower-legacy:{{ext}}>',
    endtag: '<!endbower-legacy>'
  })


# inject >ie8 deps
injectModernDeps = lazypipe()
  .pipe($.inject, gulp.src(bowerFiles()).pipe($.filter((f) ->
    /modern/.test(f.path)
  ), {read: false}), {
    ignorePath: ['app'],
    starttag: '<!-- bower-modern:{{ext}}-->',
    endtag: '<!-- endbower-modern-->'
  })


# inject universal deps
injectOtherDeps = lazypipe()
  .pipe($.inject, gulp.src(bowerFiles()).pipe($.filter((f) ->
    /^((?!(legacy|modern|\/jquery\/|\/angular\/)).)*$/.test(f.path)
  ), {read: false}), {
    ignorePath: ['app'],
    starttag: '<!-- bower-all:{{ext}}-->',
    endtag: '<!-- endbower-all-->'
  })


# compile, inject deps into index file
processSPAIndex = lazypipe()
  .pipe(-> indexFilter)
  .pipe(-> $.cached('spa-index-ext-deps'))
  .pipe(-> $.jade({
    pretty: true
  }))
  .pipe(-> injectLegacyDeps())
  .pipe(-> injectModernDeps())
  .pipe(-> injectOtherDeps())
  .pipe(-> $.remember('spa-index-ext-deps'))
  .pipe(-> indexFilter.restore())


generateSprites = lazypipe()
  .pipe(-> processSprites())


# optimize images
optimizeImages = lazypipe()
  .pipe(-> imgFilter)
  .pipe(-> $.cached('imagemin'))
  .pipe(-> $.imagemin({
    progressive: true
    #use: [pngcrush()]
  }))
  .pipe(-> $.remember('imagemin'))
  .pipe(-> imgFilter.restore())


# build all sources into html, js, css
transpile = lazypipe()
  .pipe(-> optimizeImages())
  .pipe(-> processAppJs())
  .pipe(-> $.sourcemaps.init())
  .pipe(-> processSass())
  .pipe(-> processAppCoffee())
  .pipe(-> processJSTemplates())
  .pipe(-> $.sourcemaps.write())
  .pipe(-> processSPAIndex())
  .pipe(-> processFonts())
  .pipe(-> processXDProxy())


# minimize, cache-bust, cdnize compiled code
optimize = lazypipe()
  .pipe(-> $.userefStream())
  .pipe(-> $.if('**/*.css', $.minifyCss()))
  .pipe(-> $.if('**/*.js', postProcessJS()))
  .pipe(-> $.buffer())
  .pipe(-> $.if(['/**/!(index.html)*'], $.rev()))
  .pipe(-> $.revReplaceStream())
  .pipe(-> textFileFilter)
  .pipe(-> $.cdnizer({
    defaultCDNBase: config.STATIC_URL
    allowRev: true
    allowMin: true
    files: ['/**/!(respond.proxy)*']
  }))
  .pipe(-> textFileFilter.restore())


# sync optimized code with s3
s3 = lazypipe()
  .pipe(-> $.awspublish.gzip())
  .pipe(-> publisher.publish({
    'Cache-Control': 'max-age=315360000, no-transform, public'
  }))
  #.pipe(-> publisher.sync())
  .pipe(-> $.awspublish.reporter())


# generate spritemaps. outputs into app dir for sass deps
gulp.task 'sprites', ->
  initFilters()
  gulp.src('app/**/*', {base: 'app'})
    .pipe(generateSprites())


# clean directory, build all files
gulp.task 'init', ['sprites'], ->
  initEnv('development')

  # start fresh
  del(process.env.DIST_DIR)
  initFilters()

  gulp.src(['app/**/*'], {base: 'app'})
    .pipe(transpile())
    .pipe($.injectAppFiles())
    .pipe($.if([isCompiled], gulp.dest(process.env.DIST_DIR)))
    .pipe($.size())


# compile, start dev server, update files on change
gulp.task 'default', ['init'], ->
  tinylr = require('tiny-lr')()

  # start node server
  $.nodemon({
    script: 'app.js',
    ext: 'html js',
    ignore: ['**/*'],
    env: {
      'NODE_ENV': process.env.NODE_ENV
      'DIST_DIR': process.env.DIST_DIR
    }
    watch: []
  })
    .on('restart', -> console.log('restarted'))

  # start live reload server
  tinylr.listen(LIVERELOAD_PORT)

  # watch sprites for changes, compile into app dir
  gulp.watch('app/images/sprites/**/*.png', ['sprites'])

  # watch app dir for changes, build + pipe to browser
  gulp.watch('app/**/*').on 'change', (ev) ->
    initFilters()

    if /^(added|deleted)$/.test(ev.type)
      gulp.src(['app/**/*'], {base: 'app'})
        .pipe(transpile())
        .on('error', (e) ->
          $.util.log(e.toString())
          this.emit('end')
        )
        .pipe($.injectAppFiles())
        .pipe($.filter(isCompiled))
        .pipe($.changed(process.env.DIST_DIR))
        .pipe(gulp.dest(process.env.DIST_DIR))
        .pipe($.livereload(tinylr))
        .pipe($.size())

    else if ev.type == 'changed'
      gulp.src(ev.path, {base: 'app'})
        .pipe($.dumbSass())
        .pipe(transpile())
        .on('error', (e) ->
          $.util.log(e.toString())
          this.emit('end')
        )
        .pipe($.filter(isCompiled))
        .pipe($.changed(process.env.DIST_DIR))
        .pipe(gulp.dest(process.env.DIST_DIR))
        .pipe($.livereload(tinylr))
        .pipe($.size())


# clean, compile, optimize, sync with s3
gulp.task 'build-for-deploy', ->
  # start fresh
  del(process.env.DIST_DIR)
  initFilters()

  console.log 'config', config

  # set aws creds
  publisher = $.awspublish.create({
    key:    config.AWS_KEY
    secret: config.AWS_SECRET
    bucket: config.AWS_BUCKET
  })

  gulp.src(['app/**/*'], {base: 'app'})
    # transpile
    .pipe(transpile())

    # inject app js + css
    .pipe($.injectAppFiles())

    # optimize
    .pipe(optimize())

    # output to dist
    .pipe($.if([isCompiled], gulp.dest(process.env.DIST_DIR)))
    .pipe($.size())

    # push to s3
    .pipe($.if([isCompiled], s3()))


# Push to heroku
gulp.task 'push', ->
  $.shell.task([
    "heroku config:set NODE_ENV=#{process.env.NODE_ENV}"
    "git checkout -b #{process.env.TAG}"
    'git add -u .'
    'git add .'
    "git commit -am 'commit for #{process.env.TAG} push'"
    "git push -f #{process.env.NODE_ENV} #{process.env.TAG}:master"
    'git checkout master'
    "git branch -D #{process.env.TAG}"
    "rm -rf #{process.env.DIST_DIR}"
  ])()


gulp.task 'release', ->
  initEnv('production')
  seq('build-for-deploy', 'push')


# Mocha unit tests

gulp.task 'test:unit:once', ->
  gulp.src([
    'test/unit/common.coffee'
    'test/unit/spec/**/*.coffee'
  ])
    .pipe($.mocha({
      reporter: 'nyan'
      ui: 'tdd'
    }))


gulp.task 'test:unit:watch', ['test:unit:once'], ->
  gulp.watch('test/unit/**/*').on 'change', (ev) ->
    if /^(added|deleted|changed)$/.test(ev.type)
      gulp.src(['test/unit/common.coffee', ev.path])
        .pipe($.mocha({
          reporter: 'nyan'
          ui: 'tdd'
        }))


# E2E Protractor tests
gulp.task 'start-sauce-connect', (cb) ->
  pXor.e2e.startSauceConnect()


gulp.task 'test:e2e:once', ->
  pXor.e2e.testE2E({
    nodeHost: 'localhost'
    nodePort: 5555
    mockFile: 'mocks/nock-mocks.json'
    specs:    ['test/e2e/**/*.coffee']
  })


gulp.task 'test:e2e:watch', ['test:e2e:once'], ->
  gulp.watch('test/e2e/**/*').on 'change', (ev) ->
    if /^(added|deleted|changed)$/.test(ev.type)
      testPath = ev.path.replace(process.cwd(), '')
      console.log '@-->ev path', testPath

      pXor.e2e.testE2E({
        nodeHost: 'localhost'
        nodePort: 5555
        mockFile: 'mocks/nock-mocks.json'
        specs:    ['test/e2e/common.coffee', testPath]
      })


gulp.task 'test:e2e:record', ['init'], ->
  pXor.e2e.testE2E({
    nodeApp:  'app.js'
    nodeHost: 'localhost'
    nodePort: 4444
    record:   true
    mockFile: 'mocks/nock-mocks.json'
    specs:    ['test/e2e/**/*.coffee']
  })


gulp.task 'test:e2e:playback', ['init'], ->
  pXor.e2e.testE2E({
    nodeApp:  'app.js'
    nodeHost: 'localhost'
    nodePort: 4444
    playback: true
    mockFile: 'mocks/nock-mocks.json'
    specs:    ['test/e2e/**/*.coffee']
  })


gulp.task 'test:e2e:ci', ['init'], ->
  browsers = [
    browserName: 'chrome'
  ,
    browserName: 'firefox'
  ,
    browserName: 'safari'
  ,
    browserName: 'internet explorer'
    version:     11
  ,
    browserName: 'internet explorer'
    version:     10
  ,
    browserName: 'internet explorer'
    version:     9
  ,
    browserName: 'internet explorer'
    version:     8
  ].map (item) ->
    item['build']             = process.env.TRAVIS_BUILD_NUMBER
    item['tunnel-identifier'] = process.env.TRAVIS_JOB_NUMBER
    item

  pXor.e2e.testE2E({
    nodeApp:  'app.js'
    nodeHost: 'localhost'
    nodePort: 4444
    playback: true
    mockFile: 'mocks/nock-mocks.json'
    specs:    ['test/e2e/**/*.coffee']
    browsers: browsers
  })
