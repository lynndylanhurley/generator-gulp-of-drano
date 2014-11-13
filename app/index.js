require('coffee-script/register');
module.exports = require("yeoman-generator")
  .generators.Base.extend(
    require('./generator.coffee')
  );
