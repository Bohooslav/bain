import YLT, WLC, UBIO, UKRK, LXX, SYNOD, CUV, NTGT, HOM, translations from "./translations_data.imba"
import en_leng, uk_leng, ru_leng from "./langdata.imba"

var user = {
  name: '',
  id: -1,
  first_name: '',
  last_name: ''
}

var limits_of_range = {
  from: 0,
  to: 15,
  loaded: 0
}

var verses = []

var offline = false


export tag Profile
  prop langdata default: []
  prop bookmarks default: []
  prop books default: []
  prop translation default: ''


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


  def mount
    unflag("display_none")
    limits_of_range:from = 0
    limits_of_range:to = 50
    limits_of_range:loaded = 0
    @bookmarks = []
    getProfileBookmarks limits_of_range:from, limits_of_range:to

    var bible = document:getElementsByClassName("Bible")
    bible[0]:classList.add("display_none")
    unflag("display_none")

  def unmount
    var bible = document:getElementsByClassName("Bible")
    bible[0]:classList.remove("display_none")
    flag("display_none")


  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def loadData url
    if window:navigator:onLine
      offline = false
    else
      offline = true

    window.fetch(url).then do |res|
      return res.json


  def switchTranslationBooks translation
    if @translation != translation
      @translation = translation
      switch translation
        when "YLT" then @books = YLT
        when "NASB" then @books = YLT
        when "KJV" then @books = YLT
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTGT" then @books = NTGT
        when "HOM" then @books = HOM

  def nameOfBook bookid
    for book in @books
      if book:bookid == bookid
        return book:name

  def getTitleRow translation, book, chapter, verses
    switchTranslationBooks translation
    var row
    row = nameOfBook book
    row += ' ' + chapter + ':'
    for id, key in verses.sort(do |a, b| return a - b)
      if id == verses[key - 1] + 1
        if id == verses[key+1] - 1
          continue
        else
          row += '-' + id
      else
        if !key
          row += id
        else
          row += ',' + id
    return row

  def getProfileBookmarks range_from, range_to
    var url = "/get-profile-bookmarks/" + range_from + '/' + range_to + '/'
    loadData(url).then do |data|
      var loaded_data = JSON.parse(data:data)
      limits_of_range:loaded += loaded_data:length
      var newItem = {
        verse: [],
        text: []
      }
      for item, key in loaded_data
        newItem:date = Date.new(item:fields:date)
        newItem:color = item:fields:color
        newItem:note = item:fields:note
        newItem:translation = item:fields:verse[0]
        newItem:book = item:fields:verse[1]
        newItem:chapter = item:fields:verse[2]
        newItem:verse = [item:fields:verse[3]]
        newItem:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, newItem:verse
        if @bookmarks[@bookmarks:length - 1]
          if item:fields:date == @bookmarks[@bookmarks:length - 1]:date.getTime
            @bookmarks[@bookmarks:length - 1]:verse.push(item:fields:verse[3])
            @bookmarks[@bookmarks:length - 1]:text.push(item:fields:verse[4])
            @bookmarks[@bookmarks:length - 1]:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, @bookmarks[@bookmarks:length - 1]:verse
          else
            newItem:text.push(item:fields:verse[4])
            @bookmarks.push(newItem)
            newItem = {
              verse: [],
              text: []
            }
        else
          newItem:text.push(item:fields:verse[4])
          @bookmarks.push(newItem)
          newItem = {
              verse: [],
              text: []
            }
      scheduler.mark


  def getMoreBookmarks
    if limits_of_range:loaded == limits_of_range:to
      limits_of_range:from = limits_of_range:to
      limits_of_range:to += 50
      getProfileBookmarks limits_of_range:from, limits_of_range:to

  def goToBookmark bookmark
    var bible = document:getElementsByClassName("Bible")
    document:getElementsByClassName("Bible")
    bible[0]:_tag.getText(bookmark:translation, bookmark:book, bookmark:chapter)
    orphanize
    setTimeout(&,1200) do
      window:location:hash = "#{bookmark:verse[0]}"



  def render
    <self>
      <section.profile_block>
        <header>
          <h1.userName> user:first_name, ' ', user:last_name
        for bookmark in @bookmarks
          <article.bookmark_in_list css:border-color="{bookmark:color}" .right_align=(bookmark:translation=="WLC")>
            <a.bookmark_text :tap.prevent.goToBookmark(bookmark)>
              for text in bookmark:text
                <span> text, ' '
            if bookmark:note
              <p.note> bookmark:note
            <p.dataflex>
              <span.booktitle> bookmark:title, ' '
              <time.time .time_rtl=(bookmark:translation=="WLC") time:datetime="bookmark:date"> bookmark:date.toLocaleString()
          <hr.hr>
        if limits_of_range:loaded == limits_of_range:to
          <button.more_results :tap.prevent.getMoreBookmarks css:margin="16px 0px 96px"> langdata:more_results
        else
          <div.freespace>
        if !@bookmarks:length
          <p> langdata:thereisnobookmarks


      <a.back_to_Bible :tap.prevent.orphanize>
        <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
          <svg:title> langdata:next
          <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
      <div.online .offline=offline>
        langdata:offline