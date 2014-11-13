util   = require("util")
path   = require("path")
yosay  = require('yosay')
chalk  = require("chalk")

module.exports =
  initializing: ->
    @pkg = require("../package.json")
    @on "end", ->
      unless @options["skip-install"]
        @installDependencies
          bower: true
          npm: true
          callback: ->
            console.log "Everything is ready!"

  prompting: ->
    done = @async()

    # have Yeoman greet the user
    @log yosay(
      "scoop a grave from the sky where it's roomy to lie."
    )

    prompts = [
      name: "projectName"
      message: "What is the title of this website?"
      default: "Krystal Enterprises Ltd"
    ,
      name: "siteUrl"
      message: "What will be the domain of this site at launch?"
      default: "krystal-enterprises.biz"
    ,
      name: "devPort"
      message: "What port would you like to use for development?"
      default: "9000"
    ]

    @prompt prompts, ((props) ->
      @projectName = props.projectName || ""
      @projectName = @projectName.replace(/[\.,-\/#!$%\^&\*;:{}=\-_`~()]/g, "")
      @siteUrl = props.siteUrl
      @devPort = props.devPort
      done()

    ).bind(this)


  writing: ->
    source = './'
    destination = './'

    root  = (if @isPathAbsolute(source) then source else path.join(@sourceRoot(), source))
    files = @expandFiles("**",
      dot: true
      cwd: root
    )
    i = 0

    while i < files.length
      f = files[i]
      src = path.join(root, f)
      if path.basename(f).indexOf("_") is 0
        dest = path.join(destination, path.dirname(f), path.basename(f).replace(/^_/, ""))
        @template src, dest
      else
        dest = path.join(destination, f)
        @src.copy src, dest

      i++

  end: ->
    @installDependencies
      bower: true
      npm: true
      callback: ->
        console.log "your black eyes the blackest of eyes"
