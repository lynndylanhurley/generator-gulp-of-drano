Q = require('q')

suite 'sanity check', ->
  test 'chai assertions', ->
    assert(1 == 1)

  test 'sinon', ->
    aye = (name, cb) ->
      cb "aye #{name}"

    cb = sinon.spy()
    aye "mang", cb
    assert cb.calledWith("aye mang")

  test 'chai-as-promised', ->
    sup = (name, dfd) ->
      setTimeout(->
        dfd.resolve("sup #{name}")
      , 100)
      dfd.promise

    later = Q.defer()
    assert.eventually.equal(sup('g', later), 'sup g')
