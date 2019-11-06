import en_leng, uk_leng, ru_leng from "./langdata.imba"


var user = {
  name: '',
  id: -1,
  first_name: '',
  last_name: ''
}

var offline = false

export tag Profile
  prop langdata
  prop bookmarks


  def build
    if window:username
      user:name = window:username
      user:id = window:userid
      user:first_name = window:first_name
      user:last_name = window:last_name

    if getCookie('language')
      switch getCookie('language')
        when 'eng' then @langdata = en_leng
        when 'ukr' then @langdata = uk_leng
        when 'ru' then @langdata = ru_leng
    else
      switch window:navigator:language
        when 'eng' then @langdata = en_leng
        when 'ukr' then @langdata = uk_leng
        when 'ru' then @langdata = ru_leng

    @bookmarks = []
    if window:username
      getProfileBookmarks 0, 5


  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def load url
    if window:navigator:onLine
      offline = false
    else
      offline = true

    var res = await window.fetch url
    return res.json


  def getProfileBookmarks range_from, range_to
    var url = "get-profile-bookmarks/" + range_from + '/' + range_to + '/'
    @bookmarks = []
    load(url).then do |data|
    @bookmarks = JSON.parse((await load url):data)
    scheduler.mark



  def mount
    unflag("display_none")


  def toBible
    var bible = document:getElementsByClassName("Bible")
    bible[0]:classList.remove("display_none")
    flag("display_none")





  def render
    <self>
      <section.profile_block>
        <div>
          <a.back_to_Bible route-to='/' :tap.prevent.toBible> "Back to Bible"
          <h1.userName> user:first_name, ' ', user:last_name
          <h2> "Notes"
        <div>
          for bookmark in @bookmarks
            <p>
              for el in bookmark:fields:verse
                <span> el, ' '


      <div.online .offline=offline>
        langdata:offline