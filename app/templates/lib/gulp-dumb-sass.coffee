gulp    = require('gulp')
through = require('through2')
util    = require('gulp-util')
shell   = require('gulp-shell')

module.exports = ->
  idx       = false
  globals   = false
  sassFiles = false

  through.obj (file, enc, cb) ->
    idx       = true if /main.sass$/.test(file.path)
    globals   = true if /(bs|_variables).sass$/.test(file.path)
    sassFiles = true if /.s(a|c)ss$/.test(file.path)

    cb(null, file)

  , (cb) ->
    mainPath  = 'app/styles/main.sass'
    bsPath    = 'app/styles/bs.sass'
    touchList = null

    if globals
      touchList = [mainPath, bsPath]

    else if (sassFiles and not idx)
      touchList = [mainPath]

    if touchList
      util.log(
        util.colors.green('Sass import modified. Reloading'),
        touchList.join(', ')
      )

      gulp.src(touchList, {base: 'app'})
        .pipe(shell([
          'touch <%= file.path %>'
        ]))
        .on('end', -> cb())

    else
      cb()
