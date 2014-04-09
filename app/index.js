'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var chalk = require('chalk');


var GulpOfDranoGenerator = yeoman.generators.Base.extend({
  init: function () {
    this.pkg = require('../package.json');

    this.on('end', function () {
      if (!this.options['skip-install']) {
        this.installDependencies({
          bower: true,
          npm: true,
          callback: function() {
            console.log('Everything is ready!');
          }
        });
      }

    });
  },

  askFor: function () {
    var done = this.async();

    // have Yeoman greet the user
    this.log(this.yeoman);

    // replace it with a short and sweet description of your generator
    this.log(chalk.magenta('You\'re using the fantastic GulpOfDrano generator.'));

    var prompts = [{
      name: 'projectName',
      message: 'What would you like to name this website?',
    }, {
      name: 'siteUrl',
      message: 'What will be the domain of this site at launch?',
      default: 'example.com'
    }];


    this.prompt(prompts, function (props) {
      this.projectName = props.projectName;
      this.siteUrl = props.siteUrl;

      done();
    }.bind(this));
  },

  app: function () {
    this._processDirectory('./', './')
  },

  _processDirectory: function (source, destination) {
    var root = this.isPathAbsolute(source)
      ? source
      : path.join(this.sourceRoot(), source);
    var files = this.expandFiles('**', {dot: true, cwd: root});

    for (var i=0; i < files.length; i++) {
      var f = files[i];
      var src = path.join(root, f);

      if (path.basename(f).indexOf('_') === 0) {
        var dest = path.join(destination, path.dirname(f), path.basename(f).replace(/^_/, ''));
        this.template(src, dest);
      } else {
        var dest = path.join(destination, f);
        this.copy(src, dest);
      }
    }
  }
});

module.exports = GulpOfDranoGenerator;

// [ ] capture project name
// [ ] interpolate project name into template
