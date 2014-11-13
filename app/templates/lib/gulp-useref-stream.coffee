File     = require('vinyl')
through  = require('through2')
es       = require('event-stream')
useref   = require('node-useref')
Q        = require('q')
path     = require('path')
stripBom = require('strip-bom')
source   = require('vinyl-source-stream')
util     = require('gulp-util')

module.exports = ->
  compilerManifest = null
  allCompiledFiles = {}
  bufferHash       = {}

  idx    = null
  staticFiles = []

  through.obj(((file, enc, cb) ->
    if /^\/index\.html/.test(file.path.split(file.base)[1])
      idx = file
    else if /.(jpg|png|gif|eot|svg|ttf|woff)$/.test(file.path)
      this.push(file)
    else if /cross-domain/.test(file.path)
      this.push(file)
    else
      staticFiles.push(file)

    cb()
  ), (cbx) ->
    dfd   = Q.defer()
    $this = this

    collectAssets = through.obj((file, enc, cb) ->
      key         = file.path.replace(process.cwd()+'/'+file.base, '')
      targetAsset = allCompiledFiles[key]

      if targetAsset
        targetBuffer = allCompiledFiles[key].buf
        targetIndex  = allCompiledFiles[key].idx

        try
          bufferHash[targetBuffer][targetIndex] = stripBom(file)
        catch error
          this.emit('error', new util.PluginError('gulp-useref', err))
        cb()

      else
        cb()

    , (cbx) ->
      Object.keys(bufferHash).forEach (outFile) ->
        if bufferHash[outFile].length
          joinedFile = new File({
            path: process.cwd() + outFile
            contents: new Buffer(bufferHash[outFile]
              .map((f) ->
                f.contents.toString()
              )
              .join(util.linefeed)
            )
          })

          $this.push(joinedFile)

      dfd.resolve()
    )

    indexAssets = through.obj((file, enc, cb) ->
      x                = useref(file.contents.toString())
      file.contents    = new Buffer(x[0])
      compilerManifest = x[1]

      Object.keys(compilerManifest).forEach (key) ->
        Object.keys(compilerManifest[key]).forEach (outFile) ->
          bufferHash[outFile] = []

          compilerManifest[key][outFile].assets.forEach (inFile, i) ->
            allCompiledFiles[inFile] = {
              buf: outFile
              idx: i
            }

      $this.push(file)

      cb()
    , (cby) ->
      es.readArray(staticFiles)
        .pipe(collectAssets)
    )

    es.readArray([idx])
      .pipe(indexAssets)
      .on('end', ->
        console.log '@-->finished indexing staticFiles'
      )

    dfd.promise.then(-> cbx())
  )
