'use strict';
// Generated on 2014-03-18 using generator-gulp-webapp 0.0.4

var gulp     = require('gulp');
var wiredep  = require('wiredep').stream;
var sprite   = require('css-sprite').stream;
var config   = require('config');
var cached   = require('gulp-cached');
var es       = require('event-stream');
var seq      = require('run-sequence');
var lazypipe = require('lazypipe');
var nib      = require('nib')

// for deployment
var env             = (process.env.NODE_ENV || 'development').toLowerCase();
var tag             = env + '-' + new Date().getTime();
var DIST_DIR        = 'dist';
var LIVERELOAD_PORT = 35729;

if (process.env.NODE_ENV) {
  DIST_DIR += '-'+process.env.NODE_ENV.toLowerCase();
}

// Load plugins
var $ = require('gulp-load-plugins')();

// Sass
gulp.task('sass', function () {
  return gulp.src('app/styles/deps.scss')
    .pipe(cached('sass'))
    .pipe($.rubySass({
      style: 'expanded',
      loadPath: ['app/bower_components']
    }))
    .pipe($.autoprefixer('last 1 version'))
    .pipe(wiredep({
      directory: 'app/bower_components',
      ignorePath: 'app/bower_components/'
    }))
    .pipe(gulp.dest('.tmp/styles'))
    .pipe($.size());
});


// JS
gulp.task('js', function () {
  return gulp.src('app/scripts/**/*.js')
    .pipe(cached('js'))
    .pipe($.jshint('.jshintrc'))
    .pipe($.jshint.reporter('default'))
    .pipe(gulp.dest('.tmp/scripts'))
    .pipe($.size());
});

// Bower
gulp.task('bowerjs', function() {
  return gulp.src('app/bower_components/**/*.js')
    .pipe(gulp.dest('.tmp/bower_components'))
    .pipe($.size());
});

gulp.task('bowercss', function() {
  return gulp.src('app/bower_components/**/*.css')
    .pipe(gulp.dest('.tmp/bower_components'))
    .pipe($.size());
});

// TODO: what a mess. maybe move all fonts into one dir?
gulp.task('bower-fonts', function() {
  return gulp.src([
    'app/bower_components/bootstrap-sass/vendor/assets/fonts/bootstrap/*.*',
    'app/bower_components/font-awesome/fonts/*.*'
  ])
    .pipe(gulp.dest('.tmp/fonts'))
    .pipe($.size());
})

// CoffeeScript
gulp.task('coffee', function() {
  return gulp.src('app/scripts/**/*.coffee')
    .pipe(cached('coffee'))
    .pipe($.coffee({bare: true}))
    .on('error', function(e) {
      $.util.log(e.toString());
      this.emit('end');
    })
    .pipe(gulp.dest('.tmp/scripts'))
    .pipe($.size());
});

// Images
gulp.task('images', function () {
  return gulp.src('app/images/**/*')
    .pipe($.cache($.imagemin({
      optimizationLevel: 3,
      progressive: true,
      interlaced: true
    })))
    .pipe(gulp.dest('.tmp/images'))
    .pipe($.size());
});


// Sprites
gulp.task('sprites', function() {
  return gulp.src('app/images/sprites/**/*.png')
    .pipe(sprite({
      name:      'sprite.png',
      style:     'sprite.styl',
      cssPath:   '/images',
      processor: 'stylus',
      retina:    true
    }))
    .pipe($.if('*.png', gulp.dest('.tmp/images')))
    .pipe($.if('*.styl', gulp.dest('.tmp/styles')))
    .pipe($.size());
});

// Stylus
gulp.task('stylus', function() {
  return gulp.src('app/styles/main.styl')
    .pipe($.stylus({
      paths: ['app/styles', '.tmp/styles'],
      //set: ['compress'],
      use: [nib()],
      import: [
        'sprite',
        'globals/*.styl',
        'pages/**/*.xs.styl',
        'pages/**/*.sm.styl',
        'pages/**/*.md.styl',
        'pages/**/*.lg.styl',
        'degrade.styl'
      ]
    }))
    .on('error', function(e) {
      $.util.log(e.toString());
      this.emit('end');
    })
    .pipe(gulp.dest('.tmp/styles'))
    .pipe($.size());
});

// Clean
gulp.task('clean', function () {
  return gulp.src(['dist/*', '.tmp/*'], {read: false}).pipe($.clean());
});

// Transpile
gulp.task('transpile', ['stylus', 'coffee', 'js', 'bowerjs', 'bowercss', 'bower-fonts']);

// jade -> html
var jadeify = lazypipe()
  .pipe($.jade, {
    pretty: true
  });

// Jade to HTML
gulp.task('base-tmpl', function() {
  return gulp.src('app/index.jade')
    .pipe($.changed('.tmp'))
    .pipe(jadeify())
    .pipe($.inject($.bowerFiles({read: false}), {
      ignorePath: ['app'],
      starttag: '<!-- bower:{{ext}}-->',
      endtag: '<!-- endbower-->'
    }))
    .pipe($.inject(gulp.src(
      [
        '.tmp/views/**/*.js',
        '.tmp/scripts/**/*.js',
        '.tmp/styles/**/*.css'
      ],
      {read: false}
    ), {
      ignorePath: ['.tmp'],
      starttag: '<!-- inject:{{ext}}-->',
      endtag: '<!-- endinject-->'
    }))
    .pipe(gulp.dest('.tmp'))
    .pipe($.size());
});

// Jade to JS
gulp.task('js-tmpl', function() {
  return gulp.src('app/views/**/*.jade')
    .pipe(cached('js-tmpl'))
    .pipe(jadeify())
    .pipe($.ngHtml2js({
      moduleName: '<%= _.camelize(projectName.toLowerCase()) %>Partials'
    }))
    .pipe(gulp.dest('.tmp/views'));
});

// useref
gulp.task('useref', function () {
  $.util.log('running useref');
  var jsFilter = $.filter('.tmp/**/*.js');
  var cssFilter = $.filter('.tmp/**/*.css');

  return es.merge(
    gulp.src('.tmp/images/**/*.*', {base: '.tmp'}),
    gulp.src('.tmp/fonts/**/*.*', {base: '.tmp'}),
    gulp.src('.tmp/index.html', {base: '.tmp'})
      .pipe($.useref.assets())
      .pipe(jsFilter)
      .pipe($.uglify())
      .pipe(jsFilter.restore())
      .pipe(cssFilter)
      .pipe($.minifyCss())
      .pipe(cssFilter.restore())
      .pipe($.useref.restore())
      .pipe($.useref())
    )
    .pipe(gulp.dest('.tmp'))
    .pipe($.if(/^((?!(index\.html)).)*$/, $.rev()))
    .pipe(gulp.dest('dist'))
    .pipe($.rev.manifest())
    .pipe(gulp.dest('.tmp'))
    .pipe($.size());
});

// Update file version refs
gulp.task('replace', function() {
  var manifest = require('./.tmp/rev-manifest');

  var patterns = []
  for (var k in manifest) {
    patterns.push({
      pattern: k,
      replacement: manifest[k]
    });
  };

  return gulp.src([
    'dist/*.html',
    'dist/styles/**/*.css',
    'dist/scripts/main*.js'
  ], {base: 'dist'})
    .pipe($.frep(patterns))
    .pipe(gulp.dest('dist'))
    .pipe($.size());
});

// CDNize
gulp.task('cdnize', function() {
  return gulp.src([
    'dist/*.html',
    'dist/styles/**/*.css'
  ], {base: 'dist'})
    .pipe($.cdnizer({
      defaultCDNBase: config.STATIC_URL,
      allowRev: true,
      allowMin: true,
      files: ['**/*.*']
    }))
    .pipe(gulp.dest('dist'))
    .pipe($.size());
});


// Deployment
gulp.task('s3', function() {
  var envName = (process.env.NODE_ENV || 'development').toLowerCase();
  var headers = {
    'Cache-Control': 'max-age=315360000, no-transform, public'
  };
  var publisher = $.awspublish.create({
    key:    config.AWS_KEY,
    secret: config.AWS_SECRET,
    bucket: config.AWS_STATIC_BUCKET_NAME
  });

  return gulp.src('dist/**/*')
    .pipe($.awspublish.gzip())
    .pipe(publisher.publish(headers))
    .pipe(publisher.sync())
    //.pipe(publisher.cache())
    .pipe($.awspublish.reporter());
});

// Push to heroku
gulp.task('push', $.shell.task([
  'git checkout -b '+tag,
  'cp -R dist '+DIST_DIR,
  'git add -u .',
  'git add .',
  'git commit -am "commit for '+tag+' push"',
  'git push -f '+env+' '+tag+':master',
  'git checkout master',
  'git branch -D '+tag,
  'rm -rf '+DIST_DIR
]));


// E2E Protractor tests
gulp.task('protractor', function() {
  require('coffee-script/register');
  return gulp.src('test/e2e/**/*.coffee')
    .pipe($.protractor.protractor({
      configFile: 'protractor.conf.js'
    }))
    .on('error', function(e) {
      $.util.log(e.toString());
      this.emit('end');
    });
});

gulp.task('test:e2e', ['protractor'], function() {
  gulp.watch('test/e2e/**/*.coffee', ['protractor']);
});

// Watch
gulp.task('watch', function () {
  var lr      = require('tiny-lr')();
  var nodemon = require('gulp-nodemon');

  // start node server
  $.nodemon({
    script: 'app.js',
    ext: 'html js',
    ignore: [],
    watch: []
  })
    .on('restart', function() {
      console.log('restarted');
    });

  // start livereload server
  lr.listen(LIVERELOAD_PORT);

  // Watch for changes in .tmp folder
  gulp.watch([
    '.tmp/*.html',
    '.tmp/styles/**/*.css',
    '.tmp/scripts/**/*.js',
    '.tmp/images/**/*.*'
  ], function(event) {
    gulp.src(event.path, {read: false})
      .pipe($.livereload(lr));
  });

  // Watch .scss files
  gulp.watch('app/styles/**/*.scss', ['sass']);

  // Watch .styl files
  gulp.watch('app/styles/**/*.styl', ['stylus']);

  // Watch sprites
  gulp.watch('app/images/sprites/**/*.png', ['sprites']);

  // Watch .js files
  gulp.watch('app/scripts/**/*.js', ['js']);

  // Watch .coffee files
  gulp.watch('app/scripts/**/*.coffee', ['coffee']);

  // Watch .jade files
  gulp.watch('app/index.jade', ['base-tmpl'])
  gulp.watch('app/views/**/*.jade', ['reload-js-tmpl'])

  // Watch image files
  gulp.watch('app/images/**/*', ['images']);

  // Watch bower files
  gulp.watch('app/bower_components/*', ['bowerjs', 'bowercss']);
});

// Composite tasks
// TODO: refactor when gulp adds support for synchronous tasks.
// https://github.com/gulpjs/gulp/issues/347
gulp.task('build-dev', function(cb) {
  seq(
    'clean',
    'sprites',
    'images',
    'sass',
    'transpile',
    'js-tmpl',
    'base-tmpl',
    cb
  );
});

gulp.task('dev', function(cb) {
  seq('build-dev', 'watch', cb);
});

gulp.task('reload-js-tmpl', function(cb) {
  seq('js-tmpl', 'base-tmpl', cb);
});

gulp.task('build-prod', function(cb) {
  seq(
    'build-dev',
    'useref',
    'replace',
    'cdnize',
    's3',
    cb
  );
});

gulp.task('deploy', function(cb) {
  if (!process.env.NODE_ENV) {
    throw 'Error: you forgot to set NODE_ENV'
  }
  seq('build-prod', 'push', cb);
});
