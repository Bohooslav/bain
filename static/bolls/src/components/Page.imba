export tag Page
  def initialize
    @user = {
      name: '',
      id: -1,
      first_name: '',
      last_name: ''
    }
    @offline = false
    if window:username
      @user:name = window:username
      @user:id = window:userid
      @user:first_name = window:first_name
      @user:last_name = window:last_name

  def loadData url
    if window:navigator:onLine
      @offline = false
    else
      @offline = true

    window.fetch(url).then do |res|
      return res.json
