import BOOKS from "./translations_books.json"

import translations from "./translations.json"
import en_leng, uk_leng, ru_leng from "./langdata.imba"

let user = {
  name: '',
  id: -1,
}

let limits_of_range = {
  from: 0,
  to: 15,
  loaded: 0
}

let verses = []

let offline = false
let query = ''


export tag Profile
  prop langdata default: []
  prop bookmarks default: []
  prop books default: []
  prop translation default: ''
  prop categories default: []


  def build
    for book in BOOKS
      this[Object.keys(book)[0]] = book[Object.keys(book)[0]]

    if window:username
      user:name = window:username
      user:id = window:userid

    if getCookie('language')
      switch getCookie('language')
        when 'eng' then @langdata = en_leng
        when 'ukr' then @langdata = uk_leng
        when 'ru' then @langdata = ru_leng
    else
      switch window:navigator:language
        when 'uk' then @langdata = uk_leng
        when 'ru-RU' then @langdata = ru_leng
        else @langdata = en_leng


  def mount
    unflag("display_none")
    limits_of_range:from = 0
    limits_of_range:to = 50
    limits_of_range:loaded = 0
    @bookmarks = []
    query = ''
    getProfileBookmarks limits_of_range:from, limits_of_range:to
    getCategories

    let bible = document:getElementsByClassName("Bible")
    bible[0]:classList.add("display_none")
    unflag("display_none")

  def unmount
    let bible = document:getElementsByClassName("Bible")
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
      @books = this[translation]

  def nameOfBook bookid
    for book in @books
      if book:bookid == bookid
        return book:name

  def getTitleRow translation, book, chapter, verses
    switchTranslationBooks translation
    let row
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
    let url = "/get-profile-bookmarks/" + range_from + '/' + range_to + '/'
    loadData(url).then do |data|
      let loaded_data = JSON.parse(data:data)
      limits_of_range:loaded += loaded_data:length
      let newItem = {
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

  def getCategories
    let url = "/get-categories/"
    @categories = []
    loadData(url).then do |data|
      for categories in data:data
        for piece in categories:note.split(' | ')
          if piece != ''
            @categories.push(piece)
      @categories = Array.from(Set.new(@categories))
      scheduler.mark

  def getMoreBookmarks
    if limits_of_range:loaded == limits_of_range:to
      limits_of_range:from = limits_of_range:to
      limits_of_range:to += 50
      getProfileBookmarks limits_of_range:from, limits_of_range:to

  def goToBookmark bookmark
    let bible = document:getElementsByClassName("Bible")
    bible[0]:_tag.getText(bookmark:translation, bookmark:book, bookmark:chapter)
    orphanize
    setTimeout(&,1200) do
      window:location:hash = "#{bookmark:verse[0]}"


  def ontouchstart touch
    self

  def ontouchend touch
    if touch.dx > 120 && Math.abs(touch.dy) < 24 && document.getSelection == ''
      if query
        closeSearch
      else
        unmount
        orphanize

  def getSearchedBookmarks category
    if category
      query = category
      let url = "/get-searched-bookmarks/" + category + '/'
      loadData(url).then do |data|
        @bookmarks = []
        let loaded_data = JSON.parse(data:data)
        limits_of_range:loaded += loaded_data:length
        let newItem = {
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
        if !bookmarks:length
          let meg = document.getElementById('defaultmassage')
          meg:innerHTML = langdata:nothing
        scheduler.mark
    else closeSearch

  def closeSearch
    query = ''
    limits_of_range:from = 0
    limits_of_range:to = 50
    @bookmarks = []
    getProfileBookmarks(limits_of_range:from, limits_of_range:to)

  def render
    <self>
      <section.profile_block>
        <header.profile_hat>
          if !query && @categories:length
            <.collectionsflex css:flex-wrap="wrap">
              <svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.orphanize>
                <svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
              <h1> user:name
            <.collectionsflex css:flex-wrap="wrap">
              for category in @categories
                if category
                  <p.collection :tap.prevent.getSearchedBookmarks(category)> category
              <div css:min-width="16px">
          else
            <.collectionsflex css:flex-wrap="wrap">
              <svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.closeSearch>
                <svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
              <h1> query
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
        if (limits_of_range:loaded == limits_of_range:to) && @bookmarks:length
          <button.more_results :tap.prevent.getMoreBookmarks css:margin="16px 0px 96px"> langdata:more_results
        else
          <div.freespace>
        if !@bookmarks:length
          <p id="defaultmassage"> langdata:thereisnobookmarks

      <div.online .offline=offline>
        langdata:offline