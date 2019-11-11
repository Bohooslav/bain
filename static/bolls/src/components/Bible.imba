import YLT, WLC, UBIO, UKRK, LXX, SYNOD, CUV, NTGT, HOM, translations from "./translations_data.imba"
import en_leng, uk_leng, ru_leng from "./langdata.imba"
import {Profile} from './Profile'



var settings = {
  theme: 'light',
  translation: 'YLT',
  book: 1,
  chapter: 1,
  font: 24,
  language: 'eng'
}

var search = {
  search_div: false,
  search_input: '',
  search_result_header: '',
  search_result_translation: '',
  show_filters: false,
  is_filter: false,
  counter: 50,
  filter: 0
}

var parallel_text = {
  display: false,
  translation: 'KJV',
  book: 1,
  chapter: 1,
  edited_version: 'KJV',
}

var user = {
  name: '',
  id: -1
}

var mobimenu = ''
var offline = false
var inzone = false
var bible_menu_left = -280
var settings_menu_left = 280


var choosen = []
var choosenid = []
var highlight_color = 'royalblue'
var show_color_picker = false
var show_note_input = false
var choosen_parallel = false
var store = {note: ''}


tag colorpicker < canvas
  def build
    var image = Image.new(250, 250)
    image:onload = do context('2d').drawImage(image, 0, 0, image:width, image:height)
    image:src = "static/bolls/dist/color_wheel.png"

  def ontouchstart e
    var imgData = context('2d').getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
    var rgba = imgData:data
    highlight_color = "rgba(" + rgba[0] + ", " + rgba[1] + ", " + rgba[2] + ", " + rgba[3] + ")"

  def ontouchupdate e
    var imgData = context('2d').getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
    var rgba = imgData:data
    highlight_color = "rgba(" + rgba[0] + ", " + rgba[1] + ", " + rgba[2] + ", " + rgba[3] + ")"

  def render
    <self width=250 height=250>


export tag Bible
  prop verses default: []
  prop search_verses default: {}
  prop parallel_bookmarks default: []
  prop parallel_verses default: []
  prop parallel_books default: []
  prop bookmarks default: []
  prop books default: []
  prop show_chapters_of default: 0
  prop show_list_of_translations default: false
  prop show_languages default: false
  prop linked_verse default: 0
  prop langdata default: []

  def build
    if window:translation != false
      if translations.find(do |element| return element:short_name == window:translation)
        setCookie('translation', window:translation)
        setCookie('book', window:book)
        setCookie('chapter', window:chapter)
      window:history.pushState({}, null, '/')
      if window:verse
        setTimeout(&,1200) do
          window:location:hash = "#{window:verse}"

    if window:username
      user:name = window:username
      user:id = window:userid

    # try get settings cookies
    if getCookie('translation')
      settings:translation = getCookie('translation')
    if getCookie('book')
      settings:book = parseInt(getCookie('book'))
    if getCookie('chapter')
      settings:chapter = parseInt(getCookie('chapter'))
    if getCookie('language')
      settings:language = getCookie('language')
    else
      switch window:navigator:language
        when 'uk'
          settings:language = 'ukr'
          settings:translation = 'UKRK'
          setCookie('language', settings:language)
        when 'ru'
          settings:language = 'ru'
          settings:translation = 'SYNOD'
          setCookie('language', settings:language)
    setCookie('translation', settings:translation)
    switch settings:language
      when 'eng' then @langdata = en_leng
      when 'ukr' then @langdata = uk_leng
      when 'ru' then @langdata = ru_leng

    switchTranslation settings:translation, false
    @verses = getText(settings:translation, settings:book, settings:chapter)


    if getCookie('theme')
      settings:theme = getCookie('theme')
      var html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    else
      var html = document.querySelector('#html')
      html:dataset:theme = settings:theme

    if getCookie('font')
      settings:font = parseInt(getCookie('font'))
    if getCookie('parallel_display') == 'true'
      toggleParallelMode

  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def setCookie c_name, value
    return window:localStorage.setItem(c_name, value)


  def switchTranslation translation, parallel
    if parallel
      switch translation
        when "YLT" then @parallel_books = YLT
        when "NASB" then @parallel_books = YLT
        when "KJV" then @parallel_books = YLT
        when "WLC" then @parallel_books = WLC
        when "UBIO" then @parallel_books = UBIO
        when "UKRK" then @parallel_books = UKRK
        when "LXX" then @parallel_books = LXX
        when "SYNOD" then @parallel_books = SYNOD
        when "CUV" then @parallel_books = CUV
        when "NTGT" then @parallel_books = NTGT
        when "HOM" then @parallel_books = HOM
    else
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


  def loadData url
    if window:navigator:onLine
      offline = false
    else
      offline = true

    window.fetch(url).then do |res|
      return res.json


  def getText translation, book, chapter, verse
    switchTranslation translation
    var url = "get-text/" + translation + '/' + book + '/' + chapter + '/'
    @bookmarks = []
    @verses = {}
    loadData(url).then do |data|
      @verses = JSON.parse(data)
      scheduler.mark

    # if User is registred get his bookmarks
    if user:name
      url = "get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'
      loadData(url).then do |data|
        @bookmarks = data:data
        for bookmark, key in @bookmarks
          bookmarks[key] = JSON.parse(bookmark)[0]:fields
        scheduler.mark

    unflag 'show_bible_menu'
    bible_menu_left = -280
    settings_menu_left = 280
    search:search_div = false
    mobimenu = ''
    dropFilter
    closeMark
    Imba.commit

    settings:book = book
    settings:chapter = chapter
    settings:translation = translation
    setCookie('book', book)
    setCookie('chapter', chapter)
    setCookie('translation', translation)

    if verse
      setTimeout(&,1200) do
        window:location:hash = "#{verse}"

  def getParallelText translation, book, chapter
    parallel_text:translation = translation
    parallel_text:edited_version = translation
    parallel_text:book = book
    parallel_text:chapter = chapter
    var url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
    @parallel_verses = []
    loadData(url).then do |data|
      @parallel_verses = JSON.parse(data)
      scheduler.mark

    # if User is registred get his bookmarks
    if window:username
      url = "/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'

      @parallel_bookmarks = []
      loadData(url).then do |data|
        @parallel_bookmarks = data:data
        for bookmark, key in @parallel_bookmarks
          @parallel_bookmarks[key] = JSON.parse(bookmark)[0]:fields
        scheduler.mark

    parallel_text:display = true
    setCookie('parallel_display', parallel_text:display)
    switchTranslation parallel_text:translation, true

    setCookie('translation', settings:translation)
    setCookie('parallel_translation', translation)
    setCookie('parallel_book', book)
    setCookie('parallel_chapter', chapter)


  def toggleParallelMode
    if parallel_text:display
      parallel_text:display = false
    else
      if getCookie('parallel_translation')
        parallel_text:translation = getCookie('parallel_translation')
      if getCookie('parallel_book')
        parallel_text:book = parseInt(getCookie('parallel_book'))
      if getCookie('parallel_chapter')
        parallel_text:chapter = parseInt(getCookie('parallel_chapter'))
      getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter)
      parallel_text:display = true
    setCookie('parallel_display', parallel_text:display)

  def changeEditedParallel translation
    parallel_text:edited_version = translation

  def changeTranslation translation
    if parallel_text:edited_version == parallel_text:translation && parallel_text:display
      switchTranslation translation, true
      if @parallel_books.find(do |element| return element:bookid == parallel_text:book)
        getParallelText(translation, parallel_text:book, parallel_text:chapter)
      else
        getParallelText(translation, @parallel_books[0]:bookid, 1)
        parallel_text:book = @parallel_books[0]:bookid
        parallel_text:chapter = 1
      parallel_text:translation = translation
      setCookie('translation', translation)
    else
      switchTranslation translation, false
      if books.find(do |element| return element:bookid == settings:book)
        getText(translation, settings:book, settings:chapter)
      else
        getText(translation, books[0]:bookid, 1)
        settings:book = books[0]:bookid
        settings:chapter = 1
      settings:translation = translation
      setCookie('translation', translation)
    @show_list_of_translations = false


  def getSearchText
    if search:search_input != ''
      var url
      if parallel_text:edited_version == parallel_text:translation && parallel_text:display
        url = parallel_text:edited_version + '/' + search:search_input + '/'
        search:search_result_translation = parallel_text:edited_version
      else
        url = settings:translation + '/' + search:search_input + '/'
        search:search_result_translation = settings:translation
      @search_verses = {}
      loadData(url).then do |data|
        @search_verses = JSON.parse(data)
        closeSearch
        Imba.commit

  def closeSearch
    search:counter = 50
    search:search_result_header = search:search_input
    search:search_div = !search:search_div
    settings_menu_left = 280
    document.getElementById('search').blur()
    mobimenu = ''

  def addFilter book
    search:is_filter = true
    search:filter = book
    search:show_filters = false
    search:counter = 50

  def dropFilter
    search:is_filter = false
    search:show_filters = false
    search:counter = 50

  def getFilteredArray
    return search_verses.filter(do |verse| verse:fields:book == search:filter)



  def changeTheme
    var html = document.querySelector('#html')
    switch settings:theme
      when 'light'
        html:dataset:theme = 'dark'
        settings:theme = 'dark'
        setCookie('theme', 'dark')
      when 'dark'
        html:dataset:theme = 'light'
        settings:theme = 'light'
        setCookie('theme', 'light')

  def decreaceFontSize
    if settings:font > 16
      settings:font -= 2
      setCookie('font', settings:font)

  def increaceFontSize
    if settings:font < 64 && window:outerWidth > 480
      settings:font = settings:font + 2
      setCookie('font', settings:font)
    elif settings:font < 40
      settings:font = settings:font + 2
      setCookie('font', settings:font)

  def setLanguage language
    settings:language = language
    switch language
      when 'eng' then @langdata = en_leng
      when 'ukr' then @langdata = uk_leng
      when 'ru' then @langdata = ru_leng
    setCookie('language', language)
    show_languages = !@show_languages


  def showChapters bookid
    if bookid != @show_chapters_of
      @show_chapters_of = bookid
    else @show_chapters_of = 0

  def nameOfBook bookid, parallel
    if parallel && @parallel_books != undefined
      if @parallel_books:length
        for book in @parallel_books
          if book:bookid == bookid
            return book:name
    elif @books != undefined
      for book in @books
        if book:bookid == bookid
          return book:name
    else ''

  def chaptersOfCurrentBook parallel
    if parallel
      for book in @parallel_books
        if book:bookid == parallel_text:book
          return book:chapters
    else
      for book in books
        if book:bookid == settings:book
          return book:chapters

  def nextChapter parallel
    if parallel == 'true'
      if parallel_text:chapter + 1 <= chaptersOfCurrentBook parallel
        getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter + 1)
      else
        var current_index = @parallel_books.indexOf(@parallel_books.find(do |element| return element:bookid == parallel_text:book))
        if @parallel_books[current_index + 1]
          getParallelText(parallel_text:translation, @parallel_books[current_index+1]:bookid, 1)
    else
      if settings:chapter + 1 <= chaptersOfCurrentBook parallel
        getText(settings:translation, settings:book, settings:chapter + 1)
      else
        var current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index + 1]
          getText(settings:translation, books[current_index+1]:bookid, 1)

  def prewChapter parallel
    if parallel == 'true'
      if parallel_text:chapter - 1 > 0
        getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter - 1)
      else
        var current_index = @parallel_books.indexOf(@parallel_books.find(do |element| return element:bookid == parallel_text:book))
        if @parallel_books[current_index - 1]
          getParallelText(parallel_text:translation, @parallel_books[current_index - 1]:bookid, @parallel_books[current_index - 1]:chapters)
    else
      if settings:chapter - 1 > 0
        getText(settings:translation, settings:book, settings:chapter - 1)
      else
        var current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index - 1]
          getText(settings:translation, books[current_index - 1]:bookid, books[current_index - 1]:chapters)


  def onmousemove e
    if window:outerWidth > 700
      if e.x < 32
        bible_menu_left = 0
        mobimenu = 'show_bible_menu'
      elif e.x > window:outerWidth - 32
        settings_menu_left = 0
        mobimenu = 'show_settings_menu'
      elif 280 < e.x < window:outerWidth - 280
        bible_menu_left = -280
        settings_menu_left = 280
        mobimenu = ''


  def ontouchstart touch
    if touch.x < 32 || touch.x > window:outerWidth - 32
      inzone = true
    self

  def ontouchupdate touch
    if inzone && mobimenu == ''
      if (bible_menu_left < 0 || touch.dx < 280) && mobimenu != 'show_settings_menu'
        bible_menu_left = touch.dx - 280

      if (settings_menu_left > 0 || touch.dx > -280) && mobimenu != 'show_bible_menu'
        settings_menu_left = touch.dx + 280
      Imba.commit

  def ontouchend touch
    if inzone && mobimenu == ''
      inzone = false
      if touch.dx > 120 && mobimenu != 'show_settings_menu'
        bible_menu_left = 0
        mobimenu = 'show_bible_menu'
      elif touch.dx < -120 && mobimenu != 'show_bible_menu'
        settings_menu_left = 0
        mobimenu = 'show_settings_menu'
      else
        settings_menu_left = 280
        bible_menu_left = -280
        mobimenu = ''
    elif mobimenu == 'show_bible_menu' && touch.dx < -120
      bible_menu_left = -280
      mobimenu = ''
    elif mobimenu == 'show_settings_menu' && touch.dx > 120
      settings_menu_left = 280
      mobimenu = ''
    Imba.commit

  def ontouchcancel touch
        bible_menu_left = -280
        settings_menu_left = 280
        mobimenu = ''



  def getHighlight verse
    if choosenid:length && choosenid.find(do |element| return element == verse)
      return highlight_color
    else
      var highlight = @bookmarks.find(do |element| return element:verse == verse)
      if highlight
        return highlight:color
      else
        return ''

  def getParallelHighlight verse
    if choosenid:length && choosenid.find(do |element| return element == verse)
      return highlight_color
    else
      var highlight = @parallel_bookmarks.find(do |element| return element:verse == verse)
      if highlight
        return highlight:color

  def addToChoosen pk, id, parallel
    if !choosen_parallel
      choosen_parallel = parallel

      choosenid.push pk
      choosen.push id
      var obj = @bookmarks.find(do |bookmark| return bookmark:verse == pk)
      if obj
        store:note = obj:note

    elif choosen_parallel == parallel
      if choosenid.find(do |element| return element == pk)
        choosenid.splice(choosenid.indexOf(pk), 1)
        choosen.splice(choosen.indexOf(id), 1)
      else
        choosenid.push pk
        choosen.push id

        var obj = @bookmarks.find(do |bookmark| return bookmark:verse == pk)
        if obj
          store:note = obj:note
      if !choosenid:length
        closeMark



  def changeHighlightColor color
    show_color_picker = false
    highlight_color = color

  def getHighlightedRow
    if window:username
      var row
      if choosen_parallel == 'first'
        row = nameOfBook settings:book, false
        row += ' ' + settings:chapter + ':'
      else
        row = nameOfBook parallel_text:book, true
        row += ' ' + parallel_text:chapter + ':'
      for id, key in choosen.sort(do |a, b| return a - b)
        if id == choosen[key - 1] + 1
          if id == choosen[key+1] - 1
            continue
          else
            row += '-' + id
        else
          if !key
            row += id
          else
            row += ',' + id
      return row


  def closeMark
    choosen = []
    choosenid = []
    show_color_picker = false
    show_note_input = false
    choosen_parallel = false
    store:note = ''

  def get_cookie name
    var cookieValue = null
    if document:cookie && document:cookie !== ''
      var cookies = document:cookie.split(';')
      for i in cookies
        var cookie = i.trim()
        if (cookie.substring(0, name:length + 1) === (name + '='))
          cookieValue = window.decodeURIComponent(cookie.substring(name:length + 1))
          break
    return cookieValue

  def sendBookmarksToDjango
    if window:username
      window.fetch("/save-bookmarks/", {
        method: "POST",
        cache: "no-cache",
        headers: {
          'X-CSRFToken': get_cookie('csrftoken'),
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
          verses: JSON.stringify(choosenid),
          user: user:id,
          color: highlight_color,
          date: Date.now(),
          notes: store:note
        }),
      })
      .then(do |response| response.json())
      .then(do |data| console.log data)
      if choosen_parallel == true
        for verse in choosenid
          if @parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)
            @parallel_bookmarks.splice(@parallel_bookmarks.indexOf(@parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
          @parallel_bookmarks.push({
            color: highlight_color,
            verse: verse,
            user: user:id,
            date: Date.now(),
            note: store:note})
      else
        for verse in choosenid
          if @bookmarks.find(do |bookmark| return bookmark:verse == verse)
            @bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
          @bookmarks.push({
            color: highlight_color,
            verse: verse,
            user: user:id,
            date: Date.now(),
            note: store:note})
    else
      window:location:pathname = "/accounts/login";
    closeMark

  def deleteBookmarks
    window.fetch("/delete-bookmarks/", {
      method: "POST",
      cache: "no-cache",
      headers: {
        'X-CSRFToken': get_cookie('csrftoken'),
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        verses: JSON.stringify(choosenid),
        user: user:id,
      }),
    })
    .then(do |response| response.json())
    .then(do |data| console.log data)
    if choosen_parallel == true
      for verse in choosenid
        if @parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)
          @parallel_bookmarks.splice(@parallel_bookmarks.indexOf(@parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
    else
      for verse in choosenid
        if @bookmarks.find(do |bookmark| return bookmark:verse == verse)
          @bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
    closeMark

  def copyToClipboard
    var aux = document.createElement("input")
    var value = '"'
    if choosen_parallel == 'second'
      for verse in parallel_verses
        if choosenid.find(do |element| return element == verse:pk)
          value += verse:fields:text
    else
      for verse in verses
        if choosenid.find(do |element| return element == verse:pk)
          value += verse:fields:text
    if choosen_parallel == 'second'
      value += '" ' + getHighlightedRow + ' ' + parallel_text:translation + ', ' + "bolls.life" + '/' + parallel_text:translation + '/' + parallel_text:book + '/' + parallel_text:chapter
    else
      value += '" ' + getHighlightedRow + ' ' + settings:translation + ', ' + "bolls.life" + '/'+ settings:translation + '/' + settings:book + '/' + settings:chapter
    value += '/' + choosen.sort(do |a, b| return a - b)[0]
    aux.setAttribute("value", value)
    document:body.appendChild(aux)
    aux.select()
    document.execCommand("copy")
    document:body.removeChild(aux)
    closeMark



  def toProfile
    Imba.mount <Profile>



  def render
    <self .noscroll=search:search_div>
      <nav.bible-menu css:transform="translateX({ bible_menu_left }px)">
        if parallel_text:display
          <.choose_parallel>
            <a.translation_name a:role="button" .current_translation=(parallel_text:edited_version == settings:translation) :tap.prevent.changeEditedParallel(settings:translation) tabindex="0"> settings:translation
            <a.translation_name a:role="button" .current_translation=(parallel_text:edited_version == parallel_text:translation) :tap.prevent.changeEditedParallel(parallel_text:translation) tabindex="0"> parallel_text:translation
          if parallel_text:edited_version == parallel_text:translation
            <a.book_name a:role="button" :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> parallel_text:edited_version
          else <a.book_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        else <a.book_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        <ul.translations_list .show_list_of_chapters=@show_list_of_translations>
          for translation in translations
            <li.book_in_list css:font-size="18px" :tap.prevent.changeTranslation(translation:short_name) tabindex="0"> translation:full_name
        if parallel_text:edited_version == parallel_text:translation && parallel_text:display
          for book in @parallel_books
            <a.book_in_list :tap.prevent.showChapters(book:bookid) tabindex="0"> book:name
            <ul.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <li.chapter_number role="button" :tap.prevent.getParallelText(parallel_text:translation, book:bookid, i+1) tabindex="0"> i+1
        else
          for book in @books
            <a.book_in_list :tap.prevent.showChapters(book:bookid) tabindex="0"> book:name
            <ul.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <li.chapter_number role="button" :tap.prevent.getText(settings:translation, book:bookid, i+1)  tabindex="0"> i+1
        <.freespace>

      <main.text .parallel_text=parallel_text:display css:font-size="{settings:font}px">
        <section .first_parallel=parallel_text:display .right_align=(settings:translation=="WLC")>
          <header>
            <h1> nameOfBook(settings:book, false), ' ', settings:chapter
          <article>
            <.text-ident> " "
            for verse in @verses
              <span.verse id=verse:fields:verse>
                ' '
                verse:fields:verse
              <span
                :tap.prevent.addToChoosen(verse:pk, verse:fields:verse, 'first')
                .highlighted=getHighlight(verse:pk)
                .clicked=choosenid.find(do |element| return element == verse:pk)
                css:text-decoration-color=getHighlight(verse:pk)> verse:fields:text
            <.arrows>
              <a.arrow :tap.prevent.prewChapter()>
                <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:prew
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
              <a.arrow :tap.prevent.nextChapter()>
                <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:next
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            if choosen:length
              <.freespace>
        <section.second_parallel .show_parallel=parallel_text:display .right_align=(parallel_text:translation=="WLC")>
          <header>
            <h1> nameOfBook(parallel_text:book, true), ' ', parallel_text:chapter
          <article>
            <.text-ident> " "
            for verse in @parallel_verses
              <span.verse>
                ' '
                verse:fields:verse
              <span
                :tap.prevent.addToChoosen(verse:pk, verse:fields:verse, 'second')
                .highlighted=getParallelHighlight(verse:pk)
                .clicked=choosenid.find(do |element| return element == verse:pk)
                css:text-decoration-color=getParallelHighlight(verse:pk)> verse:fields:text
            <.arrows>
              <a.arrow :tap.prevent.prewChapter("true")>
                <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:prew
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
              <a.arrow :tap.prevent.nextChapter("true")>
                <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:next
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            if choosenid:length
              <.freespace>

      <aside.settings-menu css:transform="translateX({settings_menu_left}px)">
        <p.settings_header> langdata:other
        <input[search:search_input].search id='search' type='search' placeholder=langdata:search input:aria-label="Search through the Bible" :keydown.enter.getSearchText> langdata:search
        <.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          langdata:theme
          <.theme_checkbox :tap.prevent.changeTheme>
            <span>
              if settings:theme == "dark"
                <svg:svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="913.059px" height="913.059px" viewBox="0 0 913.059 913.059" style="enable-background:new 0 0 913.059 913.059;" xml:space="preserve">
                  <svg:title> @langdata:lighttheme
                  <svg:g>
                    <svg:path d="M789.581,777.485c62.73-62.73,103.652-139.002,122.785-219.406c5.479-23.031-22.826-38.58-39.524-21.799   c-0.205,0.207-0.41,0.412-0.615,0.617c-139.57,139.57-367.531,136.879-503.693-8.072   c-128.37-136.658-126.685-348.817,3.673-483.579c1.644-1.699,3.3-3.378,4.97-5.037c16.744-16.635,1.094-44.811-21.869-39.354   c-79.689,18.938-155.326,59.276-217.75,121.035c-182.518,180.576-183.546,473.345-2.245,655.14   C315.821,958.032,608.883,958.182,789.581,777.485z">
              else
                <svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                  <svg:title> @langdata:nihttheme
                  <svg:path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
        <.nighttheme>
          langdata:font
          <a.great_B :tap.prevent.decreaceFontSize> "B-"
          "{settings:font}"
          <a.little_B :tap.prevent.increaceFontSize> "B+"
        <.nighttheme .theme_checkbox_light=parallel_text:display>
          langdata:parallel
          <a.parallel_checkbox :tap.prevent.toggleParallelMode>
            <span .parallel_checkbox_turned=parallel_text:display>
        <.nighttheme>
          langdata:language
          <button.change_language :tap.prevent=(do @show_languages = !@show_languages)>
            if settings:language == 'ukr'
              "Українська"
            if settings:language == 'eng'
              "English"
            if settings:language == 'ru'
              "Русский"
          <.languages .show_languages=show_languages>
            <button :tap.prevent.setLanguage('ukr')> "Українська"
            <button :tap.prevent.setLanguage('eng')> "English"
            <button :tap.prevent.setLanguage('ru')> "Русский"
        <a.help href="mailto:bpavlisinec@gmail.com"> langdata:help
        <.profile_in_settings>
          if user:name
            <a.username :tap.prevent.toProfile> user:name
            # <a.username route-to='/profile'> user:name
            <a.prof_btn href="accounts/logout/"> langdata:logout
          else
            <a.prof_btn href="accounts/login/"> langdata:login, ' '
            <a.prof_btn.signin href="signup/"> langdata:signin
        <.freespace>

      <section.search_results .show_search_results=search:search_div>
        <article.search_hat>
          <svg:svg.close_search :tap.prevent.closeSearch xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:close_search
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" css:margin="auto">
          <h1> search:search_result_header
          <svg:svg.filter_search .filter_search_hover=search:show_filters||search:is_filter :tap.prevent=(do search:show_filters = !search:show_filters) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:addfilter
            <svg:path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">
        <article.search_body id="search_body" tabindex="0">
          if search_verses:length
            if search:show_filters
              <.filters>
                if parallel_text:edited_version == parallel_text:translation && parallel_text:display
                  <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @parallel_books
                    <a.book_in_list :tap.prevent.addFilter(book:bookid)> book:name
                else
                  <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @books
                    <a.book_in_list :tap.prevent.addFilter(book:bookid)> book:name
            if search:is_filter
              <p.search_results_total> getFilteredArray:length, ' ', langdata:totalyresultsofsearch
              for verse, key in getFilteredArray
                <a.search_item :tap.getText(verse:fields:translation, verse:fields:book, verse:fields:chapter, verse:fields:verse)>
                  <.search_res_verse_text>
                    <span> verse:fields:text
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:fields:book, choosen_parallel), ' '
                    <span> verse:fields:chapter, ':'
                    <span> verse:fields:verse
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter = key + 50) tabindex="0"> langdata:more_results
                  break
              <div css:padding='12px 0px'>
                langdata:filter_name, ' ', nameOfBook search:filter, choosen_parallel

            else
              <p.search_results_total> search_verses:length, ' ', langdata:totalyresultsofsearch
              for verse, key in search_verses
                <a.search_item :tap.getText(verse:fields:translation, verse:fields:book, verse:fields:chapter, verse:fields:verse)>
                  <.search_res_verse_text>
                    <span> verse:fields:text
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:fields:book, choosen_parallel), ' '
                    <span> verse:fields:chapter, ':'
                    <span> verse:fields:verse
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter += 50)> langdata:more_results
                  break
          else
            <p> langdata:nothing
            <p> langdata:translation, search:search_result_translation
          <.freespace>

      <.hide .choosen_verses=choosenid:length>
        <.markingcontainer>
          <.forinput .show_note_input=show_note_input>
            <label for="textarea"> langdata:add_note
            <textarea[store:note].note-input :keydown.enter.prevent=(do show_note_input = !show_note_input) id="textarea">
          <colorpicker.color-canvas canvas:alt=langdata:canvastitle .show-canvas=show_color_picker id="" tabindex="0">
            langdata:canvastitle
          <p css:padding="16px"> getHighlightedRow
          <ul.mark_grid>
            <li.color_mark css:background="indianred" :tap.prevent.changeHighlightColor("indianred")>
            <li.color_mark css:background="goldenrod" :tap.prevent.changeHighlightColor("goldenrod")>
            <li.color_mark css:background="olivedrab" :tap.prevent.changeHighlightColor("olivedrab")>
            <li.color_mark css:background="cadetblue" :tap.prevent.changeHighlightColor("cadetblue")>
            <li.color_mark css:background="royalblue" :tap.prevent.changeHighlightColor("royalblue")>
            <li.color_mark css:background="blueviolet" :tap.prevent.changeHighlightColor("blueviolet")>
            <li.color_mark
              css:background="linear-gradient(217deg, rgba(255,0,0,.8), rgba(255,0,0,0) 70.71%),
              linear-gradient(127deg, rgba(0,255,0,.8), rgba(0,255,0,0) 70.71%),
              linear-gradient(336deg, rgba(0,0,255,.8), rgba(0,0,255,0) 70.71%)"
              :tap.prevent=(do show_color_picker = !show_color_picker)>
          <.addbuttons>
            <svg:svg.close_search :tap.prevent.closeMark xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" css:margin="auto" alt=langdata:close>
              <svg:title> langdata:close
              <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt="dismiss">

            <svg:svg.close_search :tap.prevent.deleteBookmarks xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" css:margin="auto" alt=langdata:delete>
              <svg:title> langdata:delete
              <svg:path d="M6 2l2-2h4l2 2h4v2H2V2h4zM3 6h14l-1 14H4L3 6zm5 2v10h1V8H8zm3 0v10h1V8h-1z">

            <svg:svg.save_bookmark :tap.prevent.copyToClipboard xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:copy>
              <svg:title> langdata:copy
              <svg:path d="M6 6V2c0-1.1.9-2 2-2h10a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-4v4a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V8c0-1.1.9-2 2-2h4zm2 0h4a2 2 0 0 1 2 2v4h4V2H8v4zM2 8v10h10V8H2z">

            <svg:svg.save_bookmark .filled=store:note :tap.prevent=(do show_note_input = !show_note_input) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:add_note>
              <svg:title> langdata:add_note
              <svg:path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4zm5 5V5h2v2h2v2h-2v2H9V9H7V7h2z">

            <svg:svg.save_bookmark xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.sendBookmarksToDjango alt=langdata:create>
              <svg:title> langdata:create
              <svg:path d="M0 11l2-2 5 5L18 3l2 2L7 18z">


      <.online .offline=offline>
        langdata:offline