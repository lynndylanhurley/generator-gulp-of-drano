describe 'testing sanity', ->
  it 'should be sane', ->
    expect(1).toBe(1)
    expect(true).toEqual(true)

  describe 'protractor library', ->
    it 'should expose the correct global variables', ->
      expect(protractor).toBeDefined()
      expect(browser).toBeDefined()
      expect(element).toBeDefined()
      expect($).toBeDefined()

    it 'should wrap webdriver', ->
      browser.get('/')
      expect(browser.getTitle()).toEqual('<%= projectName %>')
