# chai
# http://chaijs.com/
global.chai = require("chai")

# chai-as-promised
# https://github.com/domenic/chai-as-promised
chai.use(require('chai-as-promised'))

# sinon-chai
# https://github.com/domenic/sinon-chai
chai.use(require('sinon-chai'))

# use assert style
# http://chaijs.com/api/assert/
global.assert = require('chai').assert

# sinon
# http://sinonjs.org/
global.sinon = require('sinon')

# force into test mode
process.env.NODE_ENV = 'test'
