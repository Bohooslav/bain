import "./translations_books.json" as BOOKS
import "./translations.json" as translations
import en_leng, uk_leng, ru_leng from "./langdata.imba"
import {Profile} from './Profile'
import {Load} from "./loading.imba"

let settings = {
  theme: 'light',
  translation: 'YLT',
  book: 1,
  chapter: 1,
  font: 24,
  language: 'eng'
  clear_copy: no,
  verse_break: no
}
let parallel_text = {
  display: no,
  translation: 'WLC',
  book: 1,
  chapter: 1,
  edited_version: settings:translatoin,
}
let user = {
  name: '',
  id: -1
}
let mobimenu = ''
let offline = no
let inzone = no
let bible_menu_left = -280
let settings_menu_left = 280
let choosen = []
let choosenid = []
let highlight_color = 'royalblue'
let highlights = []
let show_color_picker = no
let show_collections = no
let show_history = no
let choosen_parallel = no
let store = {newcollection: ''}
let addcollection = no
let choosen_categories = []
let onpopstate = no


document:onkeyup = do |e|
  var e = e || window:event
  if e:code == "ArrowRight" && e:ctrlKey
    if document.getElementById("search") != document:activeElement
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.nextChapter
  elif e:code == "ArrowLeft" && e:ctrlKey
    if document.getElementById("search") != document:activeElement
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.prewChapter
  elif e:code == "Escape"
    let bible = document:getElementsByClassName("Bible")
    bible[0]:_tag.clearSpace


window:onpopstate = do |event|
  let state = event:state
  if state
    if state:profile
      let profile = document:getElementsByClassName("Profile")
      if !profile[0]
        Imba.mount <Profile>
    else
      onpopstate = yes
      let profile = document:getElementsByClassName("Profile")
      if profile[0]
        profile[0]:_tag.orphanize

      let bible = document:getElementsByClassName("Bible")
      if state:parallel-translation && state:parallel-book && state:parallel-chapter
        bible[0]:_tag.getParallelText(state:parallel-translation, state:parallel-book, state:parallel-chapter, state:parallel-verse)
      bible[0]:_tag.getText(state:translation, state:book, state:chapter, state:verse)

      parallel_text:display = state:parallel_display
      window:localStorage.setItem('parallel_display', state:parallel_display)

tag colorpicker
  prop canvasElement default: <canvas width="320" height="207">

  def build
    let canvasContext = @canvasElement:context('2d')

    let image = Image.new(320, 207)
    image:onload = do canvasContext.drawImage(image, 0, 0, image:width, image:height)
    image:src = "/static/bolls/dist/8.jpg"

    let imgData
    let rgba

    @canvasElement:ontouchstart = do |e|
      imgData = canvasContext.getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
      rgba = imgData:data
      highlight_color = "rgba(" + rgba[0] + "," + rgba[1] + "," + rgba[2] + "," + rgba[3] + ")"

    @canvasElement:ontouchupdate = do |e|
      imgData = canvasContext.getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
      rgba = imgData:data
      highlight_color = "rgba(" + rgba[0] + "," + rgba[1] + "," + rgba[2] + "," + rgba[3] + ")"

    @canvasElement:onclick = do |e|
      imgData = canvasContext.getImageData(e:_event:offsetX, e:_event:offsetY, 1, 1)
      rgba = imgData:data
      highlight_color = "rgba(" + rgba[0] + "," + rgba[1] + "," + rgba[2] + "," + rgba[3] + ")"


  def render
    <self .show-canvas=show_color_picker>
      canvasElement


export tag Bible
  prop verses default: []
  prop search_verses default: Object.create(null)
  prop parallel_bookmarks default: []
  prop parallel_verses default: []
  prop parallel_books default: []
  prop bookmarks default: []
  prop books default: []
  prop show_chapters_of default: 0
  prop show_list_of_translations default: no
  prop show_languages default: no
  prop linked_verse default: 0
  prop langdata default: []
  prop history default: []
  prop categories default: []
  prop chronorder default: no
  prop search default: Object.create(null)



  def build
    if window:translation
      if translations.find(do |element| return element:short_name == window:translation)
        setCookie('translation', window:translation)
        setCookie('book', window:book)
        setCookie('chapter', window:chapter)
      document:title += " | " + getNameOfBookFromHistory(window:translation, window:book) + ' ' + window:chapter
      if window:verse
        document:title += ':' + window:verse
      document:title += ' ' + window:translation

    if window:username
      user:name = window:username
      user:id = window:userid

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
          if !window:translation
            settings:translation = 'UKRK'
          setCookie('language', settings:language)
          document:lastChild:lang = "uk"
        when 'ru-RU'
          settings:language = 'ru'
          if !window:translation
            settings:translation = 'SYNOD'
          setCookie('language', settings:language)
          document:lastChild:lang = "ru-RU"
        else document:lastChild:lang = "en"
    setCookie('translation', settings:translation)
    switch settings:language
      when 'ukr'
        @langdata = uk_leng
        document:lastChild:lang = "uk"
      when 'ru'
        @langdata = ru_leng
        document:lastChild:lang = "ru-RU"
      else
        settings:language = 'eng'
        @langdata = en_leng
        document:lastChild:lang = "en"
    switchTranslation settings:translation, no

    if window:location:pathname == '/profile/'
      @verses = getText(settings:translation, settings:book, settings:chapter, window:verse)
      toProfile yes
    else
      @verses = getText(settings:translation, settings:book, settings:chapter, window:verse)

    if getCookie('theme')
      settings:theme = getCookie('theme')
      let html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    else
      let html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    if getCookie('font')
      settings:font = parseInt(getCookie('font'))
    if getCookie('clear_copy') == 'true'
      settings:clear_copy = getCookie('clear_copy')
    if getCookie('verse_break') == 'true'
      settings:verse_break = getCookie('verse_break')
    if getCookie('parallel_display') == 'true'
      toggleParallelMode "build"
    if getCookie('chronorder') == 'true'
      toggleChronorder
    if getCookie("highlights")
      highlights = JSON.parse(getCookie("highlights"))

    @search = {
        search_div: no,
        search_input: '',
        search_result_header: '',
        search_result_translation: '',
        show_filters: no,
        is_filter: no,
        counter: 50,
        filter: 0,
        loading: no,
        change_translation: no,
        bookd_of_results: [],
        translation: settings:translation
      }



  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def setCookie c_name, value
    return window:localStorage.setItem(c_name, value)

  def isOnline
    if window:navigator:onLine
      offline = no
    else
      offline = yes

  def switchTranslation translation, parallel
    if parallel
      if parallel_text:translation != translation || !@parallel_books:length
        @parallel_books = BOOKS[translation]
    else
      if settings:translation != translation || !@books:length
        @books = BOOKS[translation]


  def saveToHistory translation, book, chapter, verse, parallel
    if getCookie("history")
      @history = JSON.parse(getCookie("history"))
    if @history.find(do |element| return element:chapter == chapter && element:book == book && element:translation == translation)
      @history.splice(@history.indexOf(@history.find(do |element| return element:chapter == chapter && element:book == book && element:translation == translation)), 1)
    @history.push({"translation": translation, "book": book, "chapter": chapter, "verse": verse, "parallel": parallel})
    window:localStorage.setItem("history", JSON.stringify(@history))

  def loadData url
    isOnline
    window.fetch(url).then do |res|
      return res.json

  def getText translation, book, chapter, verse
    if !(translation == settings:translation && book == settings:book && chapter == settings:chapter) || !@verses:length
      switchTranslation translation
      if !onpopstate && @verses:length
        window:history.pushState(
            {
              translation: translation,
              book: book,
              chapter: chapter,
              verse: verse,
              parallel: no,
              parallel_display: parallel_text:display
              parallel-translation: parallel_text:translation,
              parallel-book: parallel_text:book,
              parallel-chapter: parallel_text:chapter,
              parallel-verse: 0,
            },
            nameOfBook(settings:book, false) + ' ' + settings:chapter,
            window:location:origin + '//' + translation + '/' + book + '/' + chapter + '/'
          )
        onpopstate = no
      let url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
      @bookmarks = []
      @verses = []
      loadData(url).then do |data|
        @verses = data
        scheduler.mark

      if user:name
        url = "/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'
        loadData(url).then do |data|
          @bookmarks = data

      clearSpace
      document:title = "Bolls " + " | " + nameOfBook(book) + ' ' + chapter + ' ' + translations.find(do |element| return element:short_name == translation):full_name
      if @chronorder
        @chronorder = !@chronorder
        toggleChronorder
      Imba.commit

      settings:book = book
      settings:chapter = chapter
      settings:translation = translation
      setCookie('book', book)
      setCookie('chapter', chapter)
      setCookie('translation', translation)

      saveToHistory translation, book, chapter, verse, no

      if verse
        setTimeout(&,1200) do
          window:location:hash = "#{verse}"
    else clearSpace

  def mount
    let search = document.getElementById('search_body')
    search:onscroll = do
      if this:scrollTop > this:scrollHeight - this:clientHeight - 512
        self:_search:counter += 20
        Imba.commit
        scheduler.mark

  def getParallelText translation, book, chapter, verse
    if !(translation == parallel_text:translation && book == parallel_text:book && chapter == parallel_text:chapter) || !@parallel_verses:length || !parallel_text:display
      parallel_text:translation = translation
      parallel_text:edited_version = translation
      parallel_text:book = book
      parallel_text:chapter = chapter
      let url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
      @parallel_verses = []
      loadData(url).then do |data|
        @parallel_verses = data
        scheduler.mark

      if @chronorder
        @chronorder = !@chronorder
        toggleChronorder

      if window:username
        url = "/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'
        @parallel_bookmarks = []
        loadData(url).then do |data|
          @parallel_bookmarks = data
          scheduler.mark

      if !onpopstate && @verses
        window:history.pushState({
            translation: settings:translation,
            book: settings:book,
            chapter: settings:chapter,
            verse: settings:verse,
            parallel: yes,
            parallel_display: parallel_text:display
            parallel-translation: translation,
            parallel-book: book,
            parallel-chapter: chapter,
            parallel-verse: verse,
          },
          nameOfBook(settings:book, no) + ' ' + settings:chapter,
          null
        )
        onpopstate = no

      clearSpace
      parallel_text:display = yes
      Imba.commit
      setCookie('parallel_display', parallel_text:display)
      switchTranslation parallel_text:translation, yes
      saveToHistory translation, book, chapter, 0, yes
      setCookie('parallel_translation', translation)
      setCookie('parallel_book', book)
      setCookie('parallel_chapter', chapter)

      if verse
        setTimeout(&,1200) do
          window:location:hash = "#p{verse}"

  def clearSpace
    unflag 'show_bible_menu'
    unflag 'show_settings_menu'
    bible_menu_left = -280
    settings_menu_left = 280
    search:search_div = no
    show_history = no
    mobimenu = ''
    dropFilter
    choosen = []
    choosenid = []
    show_color_picker = no
    show_collections = no
    choosen_parallel = no
    choosen_categories = []
    if document.getElementById('main')
      document.getElementById('main').focus()
    Imba.commit


  def toggleParallelMode
    if parallel_text:display
      parallel_text:display = no
    else
      if getCookie('parallel_translation')
        parallel_text:translation = getCookie('parallel_translation')
      if getCookie('parallel_book')
        parallel_text:book = parseInt(getCookie('parallel_book'))
      if getCookie('parallel_chapter')
        parallel_text:chapter = parseInt(getCookie('parallel_chapter'))
      getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter)
    setCookie('parallel_display', parallel_text:display)

  def changeEditedParallel translation
    parallel_text:edited_version = translation
    if @search:change_translation
      getSearchText
      @search:change_translation = no
    @show_list_of_translations = no

  def changeTranslation translation
    if parallel_text:edited_version == parallel_text:translation && parallel_text:display
      switchTranslation translation, yes
      if @parallel_books.find(do |element| return element:bookid == parallel_text:book)
        getParallelText(translation, parallel_text:book, parallel_text:chapter)
      else
        getParallelText(translation, @parallel_books[0]:bookid, 1)
        parallel_text:book = @parallel_books[0]:bookid
        parallel_text:chapter = 1
      parallel_text:translation = translation
      setCookie('translation', translation)
    else
      switchTranslation translation, no
      if @books.find(do |element| return element:bookid == settings:book)
        getText(translation, settings:book, settings:chapter)
      else
        getText(translation, books[0]:bookid, 1)
        settings:book = books[0]:bookid
        settings:chapter = 1
      settings:translation = translation
      setCookie('translation', translation)
    if @search:change_translation
      getSearchText
      @search:change_translation = no
    @show_list_of_translations = no


  def getSearchText
    clearSpace
    search:search_input = search:search_input.replace(/\\/g, '')
    search:search_input = search:search_input.replace(/\//g, '')
    if search:search_input != ''
      let url
      if parallel_text:edited_version == parallel_text:translation && parallel_text:display
        @search:translation = parallel_text:edited_version
        url = '/' + parallel_text:edited_version + '/' + search:search_input + '/'
        search:search_result_translation = parallel_text:edited_version
      else
        @search:translation = settings:translation
        url = '/' + settings:translation + '/' + search:search_input + '/'
        search:search_result_translation = settings:translation
      @search_verses = Object.create(null)
      loadData(url).then do |data|
        @search_verses = data
        for verse in @search_verses
          if !@search:bookd_of_results.find(do |element| return element == verse:book)
            @search:bookd_of_results.push verse:book
        closeSearch
        if !@search_verses:length
          setTimeout(&, 3000) do
            toggleSettingsMenu
            Imba.commit
        Imba.commit

  def closeSearch close
    @search:counter = 50
    @search:search_div = true
    if close
      @search:search_div = !@search:search_div
      @search:change_translation = no
    @search:search_result_header = @search:search_input
    settings_menu_left = 280
    if document.getElementById('search')
      document.getElementById('search').blur()
    mobimenu = ''

  def addFilter book
    search:is_filter = yes
    search:filter = book
    search:show_filters = no
    search:counter = 50

  def dropFilter
    search:is_filter = no
    search:show_filters = no
    search:counter = 50

  def getFilteredArray
    return @search_verses.filter(do |verse| verse:book == search:filter)



  def changeTheme
    let html = document.querySelector('#html')
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
    if settings:font < 64 && window:innerWidth > 480
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
        let current_index = @parallel_books.indexOf(@parallel_books.find(do |element| return element:bookid == parallel_text:book))
        if @parallel_books[current_index + 1]
          getParallelText(parallel_text:translation, @parallel_books[current_index+1]:bookid, 1)
    else
      if settings:chapter + 1 <= chaptersOfCurrentBook parallel
        getText(settings:translation, settings:book, settings:chapter + 1)
      else
        let current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index + 1]
          getText(settings:translation, books[current_index+1]:bookid, 1)

  def prewChapter parallel
    if parallel == 'true'
      if parallel_text:chapter - 1 > 0
        getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter - 1)
      else
        let current_index = @parallel_books.indexOf(@parallel_books.find(do |element| return element:bookid == parallel_text:book))
        if @parallel_books[current_index - 1]
          getParallelText(parallel_text:translation, @parallel_books[current_index - 1]:bookid, @parallel_books[current_index - 1]:chapters)
    else
      if settings:chapter - 1 > 0
        getText(settings:translation, settings:book, settings:chapter - 1)
      else
        let current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index - 1]
          getText(settings:translation, books[current_index - 1]:bookid, books[current_index - 1]:chapters)


  def onmousemove e
    if window:innerWidth > 700
      if e.x < 32
        bible_menu_left = 0
        mobimenu = 'show_bible_menu'
      elif e.x > window:innerWidth - 32
        settings_menu_left = 0
        mobimenu = 'show_settings_menu'
      elif 280 < e.x < window:innerWidth - 280
        bible_menu_left = -280
        settings_menu_left = 280
        mobimenu = ''


  def ontouchstart touch
    if touch.x < 32 || touch.x > window:innerWidth - 32
      inzone = true
    self

  def ontouchupdate touch
    if inzone
      if (bible_menu_left < 0 && touch.dx < 280) && mobimenu != 'show_settings_menu'
        bible_menu_left = touch.dx - 280
      if (settings_menu_left > 0 && touch.dx > -280) && mobimenu != 'show_bible_menu'
        settings_menu_left = touch.dx + 280
    else
      if mobimenu == 'show_bible_menu' && touch.dx < 0
        bible_menu_left = touch.dx
      if mobimenu == 'show_settings_menu' && touch.dx > 0
        settings_menu_left = touch.dx
    Imba.commit


  def ontouchend touch
    if inzone && mobimenu == ''
      if touch.dx > 64 && mobimenu != 'show_settings_menu'
        bible_menu_left = 0
        mobimenu = 'show_bible_menu'
      elif touch.dx < -64 && mobimenu != 'show_bible_menu'
        settings_menu_left = 0
        mobimenu = 'show_settings_menu'
      else
        settings_menu_left = 280
        bible_menu_left = -280
        mobimenu = ''
    elif mobimenu == 'show_bible_menu'
      if touch.dx < -64
        bible_menu_left = -280
        mobimenu = ''
      else bible_menu_left = 0
    elif mobimenu == 'show_settings_menu'
      if touch.dx > 64
        settings_menu_left = 280
        mobimenu = ''
      else settings_menu_left = 0
    elif document.getSelection == '' && Math.abs(touch.dy) < 32 && !mobimenu && !search:search_div && !show_history && !choosenid:length
      if touch.dx < -64
        if parallel_text:display && touch.y > window:innerHeight / 2
          nextChapter("true")
        else nextChapter
      elif touch.dx > 64
        if parallel_text:display && touch.y > window:innerHeight / 2
          prewChapter("true")
        else prewChapter
    inzone = no
    Imba.commit

  def ontouchcancel touch
    bible_menu_left = -280
    settings_menu_left = 280
    mobimenu = ''



  def getHighlight verse
    if choosenid:length && choosenid.find(do |element| return element == verse)
      return highlight_color
    else
      let highlight = @bookmarks.find(do |element| return element:verse == verse)
      if highlight
        return highlight:color
      else
        return ''

  def getParallelHighlight verse
    if choosenid:length && choosenid.find(do |element| return element == verse)
      return highlight_color
    else
      let highlight = @parallel_bookmarks.find(do |element| return element:verse == verse)
      if highlight
        return highlight:color

  def getNoteOfChoosen verse
    let highlight = @bookmarks.find(do |element| return element:verse == verse)
    if highlight
      return highlight:note
    else
      return ''

  def pushNoteIfExist pk
    let note = getNoteOfChoosen(pk)
    if note
      for piece in note.split(' | ')
        if piece != ''
          choosen_categories.push(piece)

  def addToChoosen pk, id, parallel
    if document.getSelection == ''
      if !choosen_parallel
        choosen_parallel = parallel
        choosenid.push pk
        choosen.push id
        pushNoteIfExist pk
        if parallel == "first" && window:innerHeight < 600
          window:location:hash = "#{id}"
        elif window:innerHeight < 600
          window:location:hash = "#p{id}"
      elif choosen_parallel == parallel
        if choosenid.find(do |element| return element == pk)
          choosenid.splice(choosenid.indexOf(pk), 1)
          choosen.splice(choosen.indexOf(id), 1)

          let note = getNoteOfChoosen(pk)
          if note
            for piece in note.split(' | ')
              if piece != ''
                choosen_categories.splice(choosen_categories.indexOf(choosen_categories.find(do |element| return element == piece)), 1)
        else
          choosenid.push pk
          choosen.push id
          pushNoteIfExist pk
        if !choosenid:length
          clearSpace
        show_collections = no



  def changeHighlightColor color
    show_color_picker = no
    highlight_color = color

  def getHighlightedRow
    let row
    if choosen_parallel == 'first'
      row = nameOfBook settings:book
      row += ' ' + settings:chapter + ':'
    else
      row = nameOfBook parallel_text:book, yes
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

  def sendBookmarksToDjango
    isOnline
    if highlight_color:length > 9
      if highlights.find(do |element| return element == highlight_color)
        highlights.splice(highlights.indexOf(highlights.find(do |element| return element == highlight_color)), 1)
      highlights.push(highlight_color)
      window:localStorage.setItem("highlights", JSON.stringify(highlights))


    let notes = ''
    for category, key in choosen_categories
      notes += category
      if key + 1 < choosen_categories:length
        notes += " | "
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
          notes: notes
        }),
      })
      .then(do |response| response.json())
      .then(do |data| console.log data)
      if choosen_parallel == 'second'
        for verse in choosenid
          if @parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)
            @parallel_bookmarks.splice(@parallel_bookmarks.indexOf(@parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
          @parallel_bookmarks.push({
            verse: verse,
            date: Date.now(),
            color: highlight_color,
            note: notes})
      else
        for verse in choosenid
          if @bookmarks.find(do |bookmark| return bookmark:verse == verse)
            @bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
          @bookmarks.push({
            verse: verse,
            date: Date.now(),
            color: highlight_color,
            note: notes})
    else
      window:location:pathname = "/signup/";
    clearSpace

  def deleteColor color_to_delete
    highlights.splice(highlights.indexOf(highlights.find(do |element| return element == color_to_delete)), 1)
    window:localStorage.setItem("highlights", JSON.stringify(highlights))


  def deleteBookmarks
    isOnline
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
    if choosen_parallel == 'second'
      for verse in choosenid
        if @parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)
          @parallel_bookmarks.splice(@parallel_bookmarks.indexOf(@parallel_bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
    else
      for verse in choosenid
        if @bookmarks.find(do |bookmark| return bookmark:verse == verse)
          @bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bookmark| return bookmark:verse == verse)), 1)
    clearSpace

  def copyToClipboard
    let aux = document.createElement("textarea")
    let value = '"'
    if choosen_parallel == 'second'
      for verse in parallel_verses
        if choosenid.find(do |element| return element == verse:pk)
          value += verse:text
    else
      for verse in verses
        if choosenid.find(do |element| return element == verse:pk)
          value += verse:text + ' '
    if choosen_parallel == 'second'
      value += '" ' + getHighlightedRow
      if !settings:clear_copy
        value += ' ' + parallel_text:translation + ', ' + "bolls.life" + '/' + parallel_text:translation + '/' + parallel_text:book + '/' + parallel_text:chapter
    else
      value += '" \n' + getHighlightedRow
      if !settings:clear_copy
        value += ' ' + settings:translation + ' ' + "bolls.life" + '/'+ settings:translation + '/' + settings:book + '/' + settings:chapter + '/' + choosen.sort(do |a, b| return a - b)[0]
    aux:textContent = value
    document:body.appendChild(aux)
    aux.select()
    document.execCommand("copy")
    document:body.removeChild(aux)
    clearSpace


  def toProfile from_build = no
    closeSearch true
    clearSpace
    flag("display_none")

    if !from_build
      window:history.pushState(
          {
            parallel: no,
            profile: yes
          },
          "profile",
          "/profile/"
        )

    Imba.mount <Profile>

  def getNameOfBookFromHistory translation, bookid
    let books = []
    books = BOOKS[translation]
    for book in books
      if book:bookid == bookid
        return book:name

  def turnHistory
    show_history = !show_history
    settings_menu_left = 280
    mobimenu = ''

  def clearHistory
    turnHistory
    @history = []
    window:localStorage.setItem("history", "[]")


  def turnCollections
    if addcollection
      addcollection = no
    else
      show_collections = !show_collections
      show_color_picker = no
      if show_collections
        getCategories

  def getCategories
    let url = "/get-categories/"
    @categories = []
    loadData(url).then do |data|
      for categories in data:data
        for piece in categories:note.split(' | ')
          if piece != ''
            @categories.push(piece)
      for category in choosen_categories
        if !@categories.find(do |element| return element == category)
          @categories.unshift category
      @categories = Array.from(Set.new(@categories))
      scheduler.mark

  def addCollection
    addcollection = yes
    setTimeout(&,400) do
      document.getElementById('newcollectioninput').focus

  def addNewCollection collection
    if choosen_categories.find(do |element| return element == collection)
      choosen_categories.splice(choosen_categories.indexOf(choosen_categories.find(do |element| return element == collection)), 1)
    elif collection
      choosen_categories.push collection
      if !@categories.find(do |element| return element == collection)
        @categories.unshift collection
      if collection == store:newcollection
        document.getElementById('newcollectioninput'):value = ''
        store:newcollection = ""
        addcollection = no
    else
      show_collections = no

  def currentTranslation translation
    if parallel_text:display
      if parallel_text:edited_version == parallel_text:translation
        return translation == parallel_text:translation
      else
        return translation == settings:translation
    else
      return translation == settings:translation

  def toggleBibleMenu parallel
    if bible_menu_left
      bible_menu_left = 0
      settings_menu_left = 280
      mobimenu = 'show_bible_menu'
      if parallel
        parallel_text:edited_version = parallel_text:translation
      else
        parallel_text:edited_version = settings:translation
    else
      bible_menu_left = -280
      mobimenu = ''

  def toggleSettingsMenu
    if settings_menu_left
      settings_menu_left = 0
      bible_menu_left = -280
      mobimenu = 'show_settings_menu'
    else
      settings_menu_left = -280
      mobimenu = ''

  def toggleChronorder
    if @chronorder
      @parallel_books.sort(do |book, koob| return book:bookid - koob:bookid)
      @books.sort(do |book, koob| return book:bookid - koob:bookid)
    else
      @parallel_books.sort(do |book, koob| return book:chronorder - koob:chronorder)
      @books.sort(do |book, koob| return book:chronorder - koob:chronorder)
    @chronorder = !@chronorder
    setCookie('chronorder', @chronorder.toString)

  def showTranslations
    @show_list_of_translations = yes
    @search:change_translation = yes
    toggleBibleMenu

  def backInHistory h, parallel
    if parallel != undefined
      getParallelText(h:translation, h:book, h:chapter, h:verse)
    else
      getText(h:translation, h:book, h:chapter, h:verse)

  def toggleClearCopy
    settings:clear_copy = !settings:clear_copy
    setCookie('clear_copy', settings:clear_copy)

  def toggleVerseBreak
    settings:verse_break = !settings:verse_break
    setCookie('verse_break', settings:verse_break)



  def render
    <self>
      <nav css:transform="translateX({bible_menu_left}px)" css:box-shadow="0 0 {(bible_menu_left + 280) / 4}px rgba(0, 0, 0, 0.3)">
        if parallel_text:display
          <.choose_parallel>
            <a.translation_name a:role="button" .current_translation=(parallel_text:edited_version == settings:translation) :tap.prevent.changeEditedParallel(settings:translation) tabindex="0"> settings:translation
            <a.translation_name a:role="button" .current_translation=(parallel_text:edited_version == parallel_text:translation) :tap.prevent.changeEditedParallel(parallel_text:translation) tabindex="0"> parallel_text:translation
          if parallel_text:edited_version == parallel_text:translation
            <a.translation_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> parallel_text:edited_version
          else
            <a.translation_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        else
          <a.translation_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        <svg:svg.chronological_order .hide_chron_order=@show_list_of_translations .chronological_order_in_use=@chronorder :tap.prevent.toggleChronorder xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
          <title> langdata:chronological_order
          <svg:path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-1-7.59V4h2v5.59l3.95 3.95-1.41 1.41L9 10.41z">
        <ul.translations_list .show_translations_list=@show_list_of_translations>
          for translation in translations
            <li.book_in_list.translation_in_list .active_book=currentTranslation(translation:short_name) :tap.prevent.changeTranslation(translation:short_name) tabindex="0"> translation:full_name
        <.books-container dir="auto">
          if parallel_text:edited_version == parallel_text:translation && parallel_text:display
            for book in @parallel_books
              <a.book_in_list dir="auto" .active_book=(book:bookid==parallel_text:book) :tap.prevent.showChapters(book:bookid) tabindex="0"> book:name
              <ul.list_of_chapters dir="auto" .show_list_of_chapters=(book:bookid==show_chapters_of)>
                for i in Array.from(Array(book:chapters).keys())
                  <li.chapter_number  .active_chapter=((i + 1) == parallel_text:chapter &&book:bookid==parallel_text:book ) :tap.prevent.getParallelText(parallel_text:translation, book:bookid, i+1) tabindex="0"> i+1
          else
            for book in @books
              <a.book_in_list dir="auto" .active_book=(book:bookid==settings:book) :tap.prevent.showChapters(book:bookid) tabindex="0"> book:name
              <ul.list_of_chapters dir="auto" .show_list_of_chapters=(book:bookid==show_chapters_of)>
                for i in Array.from(Array(book:chapters).keys())
                  <li.chapter_number  .active_chapter=((i + 1) == settings:chapter && book:bookid==settings:book) :tap.prevent.getText(settings:translation, book:bookid, i+1)  tabindex="0"> i+1
          <.freespace>

      <main#main tabindex="0" .parallel_text=parallel_text:display css:font-size="{settings:font}px">
        <svg:svg.navigation :tap.prevent.toggleSettingsMenu xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
          <svg:title> langdata:other
          <svg:path d="M0 3h20v2H0V3zm0 6h20v2H0V9zm0 6h20v2H0v-2z">
        <section .parallel=parallel_text:display dir="auto">
          <header>
            <h1 :tap.prevent.toggleBibleMenu()> nameOfBook(settings:book, false), ' ', settings:chapter
          <article>
            <.text-ident> " "
            for verse in @verses
              if settings:verse_break
                <br>
                <.text-ident> " "
              <a.verse id=verse:verse href="#{verse:verse}">
                ' '
                verse:verse
              <span
                  tabindex="0"
                  :keydown.enter.sendBookmarksToDjango
                  :tap.prevent.addToChoosen(verse:pk, verse:verse, 'first')
                  .highlighted=getHighlight(verse:pk)
                  .clicked=choosenid.find(do |element| return element == verse:pk)
                  css:text-decoration-color=getHighlight(verse:pk)
                > verse:text
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
        <section.display_none.parallel .show_parallel=parallel_text:display dir="auto">
          <header>
            <h1 :tap.prevent.toggleBibleMenu(yes)> nameOfBook(parallel_text:book, true), ' ', parallel_text:chapter
          <article>
            <.text-ident> " "
            for verse in @parallel_verses
              if settings:verse_break
                <br>
                <.text-ident> " "
              <a.verse id="p{verse:verse}" href="#p{verse:verse}">
                ' '
                verse:verse
              <span
                :tap.prevent.addToChoosen(verse:pk, verse:verse, 'second')
                .highlighted=getParallelHighlight(verse:pk)
                .clicked=choosenid.find(do |element| return element == verse:pk)
                css:text-decoration-color=getParallelHighlight(verse:pk)> verse:text
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

      <aside.settings-menu css:transform="translateX({settings_menu_left}px)" css:box-shadow="0 0 {(Math.abs(settings_menu_left - 280)) / 4}px rgba(0, 0, 0, 0.3)">
        <p.settings_header> langdata:other
        <input[search:search_input].search id='search' type='search' placeholder=langdata:search input:aria-label=langdata:search :keydown.enter.prevent.getSearchText> langdata:search
        <.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          langdata:theme
          <.theme_checkbox :tap.prevent.changeTheme>
            if settings:theme == "dark"
              <svg:svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="913.059px" height="913.059px" viewBox="0 0 913.059 913.059" style="enable-background:new 0 0 913.059 913.059;" xml:space="preserve">
                <svg:title> @langdata:lighttheme
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
        <.nighttheme>
          langdata:parallel
          <a.parallel_checkbox :tap.prevent.toggleParallelMode>
            <span .parallel_checkbox_turned=parallel_text:display>
        <.nighttheme>
          langdata:clear_copy
          <a.parallel_checkbox :tap.prevent.toggleClearCopy>
            <span .parallel_checkbox_turned=settings:clear_copy>
        <.nighttheme>
          langdata:verse_break
          <a.parallel_checkbox :tap.prevent.toggleVerseBreak>
            <span .parallel_checkbox_turned=settings:verse_break>
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
        <.help :tap.prevent.turnHistory> langdata:history
        <a.help href="mailto:bpavlisinec@gmail.com" target="_blank"> langdata:help
        <.profile_in_settings>
          if user:name
            <a.username :tap.prevent.toProfile(no)> user:name
            <a.prof_btn href="/accounts/logout/"> langdata:logout
          else
            <a.prof_btn href="/accounts/login/"> langdata:login, ' '
            <a.prof_btn.signin href="/signup/"> langdata:signin
        <.freespace>
        <footer>
          <address css:padding-bottom="4px">
            <a href="/api"> "© "
              <time time:datetime="2020-01-16T9:49"> "2019-2020"
              " Павлишинець Богуслав"

      <section.search_results .show_search_results=search:search_div>
        <article.search_hat>
          <svg:svg.close_search :tap.prevent.closeSearch(true) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:close_search
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" css:margin="auto">
          <h1> search:search_result_header
          <svg:svg.filter_search .filter_search_hover=search:show_filters||search:is_filter :tap.prevent=(do search:show_filters = !search:show_filters) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:addfilter
            <svg:path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">
        <article#search_body tabindex="0">
          if @search_verses:length
            if search:show_filters
              <.filters>
                if parallel_text:edited_version == parallel_text:translation && parallel_text:display
                  if search:is_filter then <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @parallel_books
                    <a.book_in_list.book_in_filter dir="auto" :tap.prevent.addFilter(book:bookid)> book:name
                else
                  if search:is_filter then <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @books when @search:bookd_of_results.find(do |element| return element == book:bookid)
                    <a.book_in_list.book_in_filter dir="auto" :tap.prevent.addFilter(book:bookid)> book:name
            if search:is_filter
              <p.search_results_total> getFilteredArray:length, ' ', langdata:totalyresultsofsearch
              for verse, key in getFilteredArray
                <a.search_item>
                  <.search_res_verse_text :tap.prevent.getText(verse:translation, verse:book, verse:chapter, verse:verse)>
                    <span> verse:text
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:book, choosen_parallel), ' '
                    <span> verse:chapter, ':'
                    <span> verse:verse
                    <svg:svg.open_in_parallel style="padding: 8px 4px 0; margin-left: 4px; margin-bottom: -2px;" viewBox="0 0 400 338" :tap.prevent.backInHistory({translation: @search:translation, book: verse:book, chapter: verse:chapter,verse: verse:verse}, yes)>
                      <svg:title> langdata:open_in_parallel
                      <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" inkscape:connector-curvature="0" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter += 50) tabindex="0"> langdata:more_results
                  break
              <div css:padding='12px 0px' css:text-align="center">
                langdata:filter_name, ' ', nameOfBook search:filter, choosen_parallel
                <br>
                <a.more_results css:display="inline-block" css:margin-top="12px" :tap.prevent.dropFilter> langdata:drop_filter
            else
              <p.search_results_total> @search_verses:length, ' ', langdata:totalyresultsofsearch
              for verse, key in @search_verses
                <a.search_item>
                  <.search_res_verse_text :tap.prevent.getText(verse:translation, verse:book, verse:chapter, verse:verse)>
                    <span> verse:text
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:book, choosen_parallel), ' '
                    <span> verse:chapter, ':'
                    <span> verse:verse
                    <svg:svg.open_in_parallel style="padding: 8px 4px 0; margin-left: 4px; margin-bottom: -2px;" viewBox="0 0 400 338" :tap.prevent.backInHistory({translation: @search:translation, book: verse:book, chapter: verse:chapter,verse: verse:verse}, yes)>
                      <svg:title> langdata:open_in_parallel
                      <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" inkscape:connector-curvature="0" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter += 50) tabindex="0"> langdata:more_results
                  break
            <.freespace>
          else
            <div style="display:flex;flex-direction:column;height:100%;justify-content:center;align-items:center">
              <p css:margin-top="32px" css:text-align="center"> langdata:nothing
              <p css:padding="32px 0px 8px"> langdata:translation, search:search_result_translation
              <button.more_results :tap.prevent.showTranslations> langdata:change_translation

      <section.hide .choosen_verses=choosenid:length>
        if show_color_picker
          if window:innerWidth < 600
            <svg:svg.close_colorpicker
                :tap.prevent=(do show_color_picker = !show_color_picker)
                xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0"
                >
              <svg:title> langdata:close
              <svg:path d="M0 11l2-2 5 5L18 3l2 2L7 18z">
          <colorpicker .show-canvas=show_color_picker canvas:alt=langdata:canvastitle id="" tabindex="0">  langdata:canvastitle
        <.markingcontainer>
          <p> getHighlightedRow
          <ul.mark_grid>
            for highlight in highlights.slice().reverse()
              <li.color_mark css:background=highlight :tap.prevent.changeHighlightColor(highlight)>
                <svg:svg.delete_color
                    :tap.prevent.deleteColor(highlight)
                    xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0"
                    >
                  <svg:title> langdata:delete
                  <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
            <li.color_mark css:background="FireBrick" :tap.prevent.changeHighlightColor("FireBrick")>
            <li.color_mark css:background="Chocolate" :tap.prevent.changeHighlightColor("Chocolate")>
            <li.color_mark css:background="GoldenRod" :tap.prevent.changeHighlightColor("GoldenRod")>
            <li.color_mark css:background="OliveDrab" :tap.prevent.changeHighlightColor("OliveDrab")>
            <li.color_mark css:background="RoyalBlue" :tap.prevent.changeHighlightColor("RoyalBlue")>
            <li.color_mark css:background="SlateBlue" :tap.prevent.changeHighlightColor("SlateBlue")>
            <li.color_mark
              css:border="none"
              css:background="linear-gradient(217deg, rgba(255,0,0,.8), rgba(255,0,0,0) 70.71%),
              linear-gradient(127deg, rgba(0,255,0,.8), rgba(0,255,0,0) 70.71%),
              linear-gradient(336deg, rgba(0,0,255,.8), rgba(0,0,255,0) 70.71%)"
              :tap.prevent=(do show_color_picker = !show_color_picker)>
          <.addbuttons>
            <svg:svg.close_search :tap.prevent.clearSpace xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" css:margin="auto" alt=langdata:close>
              <svg:title> langdata:close
              <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt="dismiss">

            <svg:svg.close_search :tap.prevent.deleteBookmarks xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" css:margin="auto" alt=langdata:delete>
              <svg:title> langdata:delete
              <svg:path d="M6 2l2-2h4l2 2h4v2H2V2h4zM3 6h14l-1 14H4L3 6zm5 2v10h1V8H8zm3 0v10h1V8h-1z">

            <svg:svg.save_bookmark :tap.prevent.copyToClipboard xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:copy>
              <svg:title> langdata:copy
              <svg:path d="M6 6V2c0-1.1.9-2 2-2h10a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-4v4a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V8c0-1.1.9-2 2-2h4zm2 0h4a2 2 0 0 1 2 2v4h4V2H8v4zM2 8v10h10V8H2z">

            <svg:svg.save_bookmark .filled=choosen_categories:length :tap.prevent.turnCollections xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:addtocollection>
              <svg:title> langdata:addtocollection
              <svg:path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

            <svg:svg.save_bookmark xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.sendBookmarksToDjango alt=langdata:create>
              <svg:title> langdata:create
              <svg:path d="M0 11l2-2 5 5L18 3l2 2L7 18z">

      <section.addtocollection .show_collections=show_collections>
        <.collectionshat>
          <svg:svg.svgBack xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.turnCollections>
            <svg:title> langdata:back
            <svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
          if addcollection
            <a.saveto> langdata:newcollection
          else
            <a.saveto> langdata:saveto
            <svg:svg.svgAdd :tap.prevent.addCollection xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:addcollection>
              <svg:title> langdata:addcollection
              <svg:line x1="0" y1="10" x2="20" y2="10">
              <svg:line x1="10" y1="0" x2="10" y2="20">
        <.collectionsflex>
          if addcollection
            <input[store:newcollection].newcollectioninput :keydown.enter.prevent.addNewCollection(store:newcollection) id="newcollectioninput" type="text">
          elif @categories:length
            for category in @categories
              if category
                <p.collection
                .add_new_collection=(choosen_categories.find(do |element| return element == category))
                :tap.prevent.addNewCollection(category)> category
            <div css:min-width="16px">
          else
            <p.collection.add_new_collection css:margin="8px auto" :tap.prevent.addCollection> langdata:addcollection
        if (store:newcollection && addcollection) || (choosen_categories:length && !addcollection)
          <button.cancel.add_new_collection :tap.prevent.addNewCollection(store:newcollection)> langdata:save
        else
          <button.cancel :tap.prevent.turnCollections> langdata:cancel

      <section.history.filters .show_history=show_history>
        <.nighttheme css:margin="0">
          <svg:svg.close_search :tap.prevent.turnHistory xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0" css:margin="0 8px">
              <svg:title> langdata:close_search
              <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
          <h1 css:margin="0 0 0 8px"> langdata:history
          <svg:svg.close_search :tap.prevent.clearHistory xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" css:margin="0 12px 0 16px" alt=langdata:delete css:margin-left="auto">
            <svg:title> langdata:delete
            <svg:path d="M6 2l2-2h4l2 2h4v2H2V2h4zM3 6h14l-1 14H4L3 6zm5 2v10h1V8H8zm3 0v10h1V8h-1z">

        <article.historylist>
          for h in @history.slice().reverse
            <div css:display="flex">
              <a.book_in_list :tap.prevent.backInHistory(h)>
                getNameOfBookFromHistory(h:translation, h:book), ' ', h:chapter
                if h:verse
                  ':' + h:verse
                ' ', h:translation
              <svg:svg.open_in_parallel viewBox="0 0 400 338" :tap.prevent.backInHistory(h, yes)>
                <svg:title> langdata:open_in_parallel
                <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" inkscape:connector-curvature="0" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">

      <.online .offline=offline>
        langdata:offline
        <a.reload :tap=(do window:history.go())> langdata:reload