source   = require('vinyl-source-stream')
map      = require('map-stream')
lazypipe = require('lazypipe')
through  = require('through2')
inject   = require('gulp-inject')
es       = require('event-stream')
Q        = require('q')
debug    = require('gulp-debug')

module.exports = ->
  assets = []
  idx    = null

  through.obj (file, enc, cb) ->
    # allow deps thru without modification
    if /(bower_components|cross-domain)/.test(file.path)
      this.push(file)

    # collect app js+css for block injection
    else if /\.(js|css)$/.test(file.path)
      assets.push(file)
      this.push(file)

    # exclude index from stream, save ref for later inclusion
    else if /index\.html$/.test(file.path)
      idx = file

    # allow remaining files thru without modification
    else
      this.push(file)

    return cb()
  , (xcb) ->
    $this = this
    dfd   = Q.defer()

    # don't bother if index doesn't exist in stream
    return xcb() unless idx

    # convert asset collection to stream
    a = es.readArray(assets)

    # convert index to stream, inject asset block stream
    es.readArray([idx])
      .pipe(inject(a, {
        ignorePath: ['app', '.tmp', 'dist']
        starttag: '<!-- app:{{ext}}-->',
        endtag: '<!-- endapp-->'
      }))
      .on('end', -> dfd.resolve())

    # finish only when index stream has been processed
    dfd.promise.then(->
      $this.push(idx)
      xcb()
    )
