suite "gulp-of-drano generator", ->
  test "can be imported without blowing up", ->
    app = require("../../app")
    assert app isnt `undefined`
