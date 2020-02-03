import "./translations_books.json" as BOOKS
import "./translations.json" as translations
import {Load} from "./loading.imba"

import en_leng, uk_leng, ru_leng from "./langdata.imba"

let user = {
  name: '',
  id: -1,
}
let limits_of_range = {
  from: 0,
  to: 32,
  loaded: 0
}
let verses = []
let offline = false
let query = ''
let loading = no
let show_options_of = ''

export tag Profile
  prop langdata default: []
  prop bookmarks default: []
  prop books default: []
  prop translation default: ''
  prop categories default: []


  def build
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
    limits_of_range:from = 0
    limits_of_range:to = 32
    limits_of_range:loaded = 0
    @bookmarks = []
    query = ''
    show_options_of = ''
    getProfileBookmarks limits_of_range:from, limits_of_range:to
    getCategories

    let bible = document:getElementsByClassName("Bible")
    if bible[0]
      bible[0]:classList.add("display_none")
    window:addEventListener('scroll', do render)

  def unmount
    let bible = document:getElementsByClassName("Bible")
    bible[0]:classList.remove("display_none")
    flag("display_none")
    window:removeEventListener('scroll', do render)

  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def isOnline
    if window:navigator:onLine
      offline = no
    else
      offline = yes

  def loadData url
    isOnline
    window.fetch(url).then do |res|
      return res.json

  def switchTranslationBooks translation
    if @translation != translation
      @translation = translation
      @books = BOOKS[translation]

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
      limits_of_range:loaded += data:length
      let newItem = {
        verse: [],
        text: []
      }
      for item, key in data
        newItem:date = Date.new(item:date)
        newItem:color = item:color
        newItem:note = item:note
        newItem:translation = item:verse:translation
        newItem:book = item:verse:book
        newItem:chapter = item:verse:chapter
        newItem:verse = [item:verse:verse]
        newItem:pks = [item:verse:verse_id]
        newItem:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, newItem:verse
        if @bookmarks[@bookmarks:length - 1]
          if item:date == @bookmarks[@bookmarks:length - 1]:date.getTime
            @bookmarks[@bookmarks:length - 1]:verse.push(item:verse:verse)
            @bookmarks[@bookmarks:length - 1]:pks.push(item:verse:verse_id)
            @bookmarks[@bookmarks:length - 1]:text.push(item:verse:text)
            @bookmarks[@bookmarks:length - 1]:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, @bookmarks[@bookmarks:length - 1]:verse
          else
            newItem:text.push(item:verse:text)
            @bookmarks.push(newItem)
            newItem = {
              verse: [],
              text: []
            }
        else
          newItem:text.push(item:verse:text)
          @bookmarks.push(newItem)
          newItem = {
              verse: [],
              text: []
            }
      loading = no
      limits_of_range:from = range_from
      limits_of_range:to = range_to
      Imba.commit

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

  def toBible
    window:history.back()
    orphanize

  def getMoreBookmarks
    if limits_of_range:loaded == limits_of_range:to
      getProfileBookmarks limits_of_range:to, limits_of_range:to + 32

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
        toBible

  def getSearchedBookmarks category
    if category
      query = category
      @bookmarks = []
      let url = "/get-searched-bookmarks/" + category + '/'
      loadData(url).then do |data|
        @bookmarks = []
        limits_of_range:loaded += data:length
        let newItem = {
          verse: [],
          text: []
        }
        for item, key in data
          newItem:date = Date.new(item:date)
          newItem:color = item:color
          newItem:note = item:note
          newItem:translation = item:verse:translation
          newItem:book = item:verse:book
          newItem:chapter = item:verse:chapter
          newItem:verse = [item:verse:verse]
          newItem:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, newItem:verse
          if @bookmarks[@bookmarks:length - 1]
            if item:date == @bookmarks[@bookmarks:length - 1]:date.getTime
              @bookmarks[@bookmarks:length - 1]:verse.push(item:verse:verse)
              @bookmarks[@bookmarks:length - 1]:text.push(item:verse:text)
              @bookmarks[@bookmarks:length - 1]:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, @bookmarks[@bookmarks:length - 1]:verse
            else
              newItem:text.push(item:verse:text)
              @bookmarks.push(newItem)
              newItem = {
                verse: [],
                text: []
              }
          else
            newItem:text.push(item:verse:text)
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

  def scroll
    if (dom:clientHeight - 512 < window:scrollY + window:innerHeight) && !loading
      loading = yes
      getMoreBookmarks

  def showOptions title
    if show_options_of == title
      show_options_of = ''
    else
      show_options_of = title

  def deleteBookmark bookmark
    isOnline
    window.fetch("/delete-bookmarks/", {
      method: "POST",
      cache: "no-cache",
      headers: {
        'X-CSRFToken': get_cookie('csrftoken'),
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        verses: JSON.stringify(bookmark:pks),
        user: user:id,
      }),
    })
    .then(do |response| response.json())
    .then(do |data| console.log data)
    for verse in bookmark:verse
      if @bookmarks.find(do |bm| return bm:pks == bookmark:pks)
        @bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bm| return bm:pks == bookmark:pks)), 1)
        Imba.commit
    Imba.commit

  def get_cookie name
    let cookieValue = null
    if document:cookie && document:cookie !== ''
      let cookies = document:cookie.split(';')
      for i in cookies
        let cookie = i.trim()
        if (cookie.substring(0, name:length + 1) === (name + '='))
          cookieValue = window.decodeURIComponent(cookie.substring(name:length + 1))
          break
    return cookieValue

  def copyToClipboard bookmark
    let aux = document.createElement("textarea")
    let value = '"'
    value += bookmark:text + '"\n\n' + bookmark:title
    if getCookie('clear_copy') != 'true'
      value += ' ' + bookmark:translation + ' ' + "https://bolls.life" + '/'+ bookmark:translation + '/' + bookmark:book + '/' + bookmark:chapter + '/' + bookmark:verse.sort(do |a, b| return a - b)[0]
    aux:textContent = value
    document:body.appendChild(aux)
    aux.select()
    document.execCommand("copy")
    document:body.removeChild(aux)
    show_options_of = ''

  def render
    <self :onscroll=scroll>
      <section.profile_block>
        <header.profile_hat>
          if !query
            <.collectionsflex css:flex-wrap="wrap">
              <svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.toBible>
                <svg:title>  @langdata:back
                <svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
              <h1> user:name.charAt(0).toUpperCase() + user:name.slice(1)
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
          <article.bookmark_in_list css:border-color="{bookmark:color}">
            <text-as-html[{text: bookmark:text.join(" ")}].bookmark_text :tap.prevent.goToBookmark(bookmark) dir="auto">
            if bookmark:note
              <p.note> bookmark:note
            <p.dataflex>
              <span.booktitle dir="auto"> bookmark:title, ' ', bookmark:translation
              <time.time time:datetime="bookmark:date"> bookmark:date.toLocaleString()
              <svg:svg._options :tap.prevent.showOptions(bookmark:title) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <svg:path d="M10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0-6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4z">
              <.languages css:right="{window:innerWidth > 1200 ? (window:innerWidth - 1140) / 2 : 32}px" .show_languages=(bookmark:title==show_options_of)>
                <button :tap.prevent.goToBookmark(bookmark)> @langdata:open
                <button :tap.prevent.copyToClipboard(bookmark)> @langdata:copy
                <button :tap.prevent.deleteBookmark(bookmark)> @langdata:delete
          <hr.hr>
        if loading && (limits_of_range:loaded == limits_of_range:to) && @bookmarks:length
          <Load css:padding="128px 0">
        else
          <div.freespace>
        if !@bookmarks:length
          <p css:text-align="center"> langdata:thereisnobookmarks

      <div.online .offline=offline>
        langdata:offline