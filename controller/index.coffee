util   = require("util")
path   = require("path")
yeoman = require("yeoman-generator")
chalk  = require("chalk")

Generator = yeoman.generators.Base.extend(
  askFor: ->
    done = @async()

    # have Yeoman greet the user
    @log @yeoman

    # replace it with a short and sweet description of your generator
    @log chalk.magenta("You're using the fantastic GulpOfDrano generator.")

    prompts = [
      {
        name: "controllerName"
        message: "What would you like to name the controller?"
        default: "some name"
      }
      {
        name: "moduleName"
        message: "To which module does this controller belong?"
        default: "myApp"
      }
    ]

    @prompt prompts, ((props) ->
      @controllerName = props.controllerName
      @moduleName     = props.moduleName
      done()
    ).bind(this)

  app: ->
    ctx =
      klass:      @controllerName
      moduleName: @moduleName

    @template(
      'controller.coffee',
      "app/scripts/controllers/pages/#{_.dasherize(@controllerName)}.coffee",
      ctx
    )
)
module.exports = Generator
