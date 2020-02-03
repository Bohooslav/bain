import "./translations_books.json" as BOOKS
import "./translations.json" as translations
import en_leng, uk_leng, ru_leng from "./langdata.imba"
import {Profile} from './Profile'
import {Load} from "./loading.imba"
import {Downloads} from "./downloads.imba"

let on_electron = false
if window:process
  on_electron = true
  console.log window:process:versions:electron

let settings = {
  theme: 'light',
  translation: 'YLT',
  book: 1,
  chapter: 1,
  font: {
    size: 24,
    family: "sans, sans-serif",
    name: "Sans",
    line-height: 1.6,
    max-width: 90,
  },
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
let bible_menu_left = -300
let settings_menu_left = -300
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
let loading = no
let menuicons = yes
let show_fonts = no
let show_help = no
let show_compare = no
let choosen_for_comparison = []
let comparison_parallel = []
let show_translations_for_comparison = no
let compare_translations = []
let compare_parallel_of_chapter
let compare_parallel_of_book
let highlighted_title = ''
let fonts = [
  {
    name: "David Libre",
    code: "'David Libre', serif"
  },
  {
    name: "Bellefair",
    code: "'Bellefair', serif"
  },
  {
    name: "M PLUS 1p",
    code: "'M PLUS 1p', sans-serif"
  },
  {
    name: "Roboto Slab",
    code: "'Roboto Slab', serif"
  },
  {
    name: "System UI",
    code: "system-ui"
  }
  {
    name: "Sans",
    code: "Sans, Sans-serif"
  },
  {
    name: "Monospace",
    code: "monospace"
  },
]

document:onkeyup = do |e|
  var e = e || window:event
  if document.getElementById("search") != document:activeElement
    if e:code == "ArrowRight" && e:altKey && e:ctrlKey
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.nextChapter('true')
    elif e:code == "ArrowLeft" && e:altKey && e:ctrlKey
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.prewChapter('true')
    elif e:code == "ArrowRight" && e:ctrlKey
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.nextChapter
    elif e:code == "ArrowLeft" && e:ctrlKey
      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.prewChapter
  if e:code == "Escape"
    let bible = document:getElementsByClassName("Bible")
    bible[0]:_tag.clearSpace
    let profile = document:getElementsByClassName("Profile")
    if profile[0]
      profile[0]:_tag.orphanize
      window:history.back()
  if e:code == "KeyH" && e:altKey && e:ctrlKey
    menuicons = !menuicons
    Imba.commit
    window:localStorage.setItem("menuicons", menuicons)

window:onpopstate = do |event|
  let state = event:state
  if state
    if state:profile || state:downloads
      if state:profile
        let profile = document:getElementsByClassName("Profile")
        if !profile[0]
          console.log "mount"
          Imba.mount <Profile>
      if state:downloads
        let downloads = document:getElementsByClassName("Downloads")
        if !downloads[0]
          Imba.mount <Downloads>
    else
      onpopstate = yes
      let profile = document:getElementsByClassName("Profile")
      if profile[0]
        profile[0]:_tag.orphanize
      let downloads = document:getElementsByClassName("Downloads")
      if downloads[0]
        downloads[0]:_tag.orphanize

      let bible = document:getElementsByClassName("Bible")
      bible[0]:_tag.unflag("display_none")
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
      let url = "/get-history/"
      try
        loadData(url).then do |data|
          @history = JSON.parse(data:history)
          window:localStorage.setItem("history", JSON.stringify(@history))
      catch error
        console.error('Error: ', error)
    if getCookie('translation')
      settings:translation = getCookie('translation')
    if getCookie('book')
      settings:book = parseInt(getCookie('book'))
    if getCookie('chapter')
      settings:chapter = parseInt(getCookie('chapter'))
    if getCookie('language')
      settings:language = getCookie('language')
    else
      switch window:navigator:language.slice(0, 2)
        when 'uk'
          settings:language = 'ukr'
          if !window:translation
            settings:translation = 'UKRK'
          setCookie('language', settings:language)
          document:lastChild:lang = "uk"
        when 'ru'
          settings:language = 'ru'
          if !window:translation
            settings:translation = 'SYNOD'
          setCookie('language', settings:language)
          document:lastChild:lang = "ru-RU"
        else document:lastChild:lang = "en"
    setCookie('translation', settings:translation)
    compare_translations.unshift(settings:translation)
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
    elif window:location:pathname == '/downloads/'
      @verses = getText(settings:translation, settings:book, settings:chapter, window:verse)
      toDownloads yes
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
      settings:font:size = parseInt(getCookie('font'))
    if getCookie('font-family')
      settings:font:family = getCookie('font-family')
    if getCookie('font-name')
      settings:font:name = getCookie('font-name')
    if getCookie('line-height')
      settings:font:line-height = parseFloat(getCookie('line-height'))
    if getCookie('max-width')
      settings:font:max-width = parseInt(getCookie('max-width'))
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
    if getCookie('menuicons') == 'false'
      menuicons = no
    if JSON.parse(getCookie("compare_translations"))
      compare_translations = JSON.parse(getCookie("compare_translations"))
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
        bookid_of_results: [],
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
    Imba.commit

  def saveToHistory translation, book, chapter, verse, parallel
    if getCookie("history")
      @history = JSON.parse(getCookie("history"))
    if @history.find(do |element| return element:chapter == chapter && element:book == book && element:translation == translation)
      @history.splice(@history.indexOf(@history.find(do |element| return element:chapter == chapter && element:book == book && element:translation == translation)), 1)
    @history.push({"translation": translation, "book": book, "chapter": chapter, "verse": verse, "parallel": parallel})
    window:localStorage.setItem("history", JSON.stringify(@history))

    if window:username
      window.fetch("/save-history/", {
        method: "POST",
        cache: "no-cache",
        headers: {
          'X-CSRFToken': get_cookie('csrftoken'),
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
            history: JSON.stringify(@history),
          })
      })
      .then(do |response| response.json())
      .then(do |data| console.log data)

  def loadData url
    isOnline
    window.fetch(url).then do |res|
      return res.json

  def getText translation, book, chapter, verse
    if !(translation == settings:translation && book == settings:book && chapter == settings:chapter) || !@verses:length
      loading = yes
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
      try
        loadData(url).then do |data|
          @verses = data
          loading = no
          scheduler.mark
      catch error
        console.error('Error: ', error)

      if user:name
        url = "/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'
        try
          loadData(url).then do |data|
            @bookmarks = data
        catch error
          console.error('Error: ', error)

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
        foundVerse verse
    else clearSpace

  def foundVerse verse, parallel
    setTimeout(&,300) do
      let searched_verse = document.getElementById(verse)
      if searched_verse
        if parallel
          window:location:hash = "#p{verse}"
        else
          window:location:hash = "#{verse}"
      else foundVerse verse

  def mount
    let search = document.getElementById('search_body')
    if search
      search:onscroll = do
        if this:scrollTop > this:scrollHeight - this:clientHeight - 512
          self:_search:counter += 20
          Imba.commit
          scheduler.mark

  def getParallelText translation, book, chapter, verse
    if !(translation == parallel_text:translation && book == parallel_text:book && chapter == parallel_text:chapter) || !@parallel_verses:length || !parallel_text:display
      let url = "/get-text/" + translation + '/' + book + '/' + chapter + '/'
      @parallel_verses = []
      try
        loadData(url).then do |data|
          @parallel_verses = data
          scheduler.mark
      catch error
        console.error('Error: ', error)

      if @chronorder
        @chronorder = !@chronorder
        toggleChronorder

      if window:username
        url = "/get-bookmarks/" + translation + '/' + book + '/' + chapter + '/'
        @parallel_bookmarks = []
        try
          loadData(url).then do |data|
            @parallel_bookmarks = data
            scheduler.mark
        catch error
          console.error('Error: ', error)

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

      switchTranslation translation, yes
      parallel_text:translation = translation
      parallel_text:edited_version = translation
      parallel_text:book = book
      parallel_text:chapter = chapter
      clearSpace
      Imba.commit
      setCookie('parallel_display', parallel_text:display)
      saveToHistory translation, book, chapter, 0, yes
      setCookie('parallel_translation', translation)
      setCookie('parallel_book', book)
      setCookie('parallel_chapter', chapter)

      if verse
        foundVerse verse, yes

  def clearSpace
    bible_menu_left = -300
    settings_menu_left = -300
    search:search_div = no
    show_history = no
    mobimenu = ''
    dropFilter
    choosen = []
    choosenid = []
    addcollection = no
    show_color_picker = no
    show_collections = no
    choosen_parallel = no
    show_help = no
    show_compare = no
    show_translations_for_comparison = no
    choosen_categories = []
    if document.getElementById('main')
      document.getElementById('main').focus()
    Imba.commit

  def turnHelpBox
    if show_help
      clearSpace
    else
      clearSpace
      show_help = !show_help

  def toggleParallelMode
    if parallel_text:display
      parallel_text:display = no
      clearSpace
    else
      if getCookie('parallel_translation')
        parallel_text:translation = getCookie('parallel_translation')
      if getCookie('parallel_book')
        parallel_text:book = parseInt(getCookie('parallel_book'))
      if getCookie('parallel_chapter')
        parallel_text:chapter = parseInt(getCookie('parallel_chapter'))
      getParallelText(parallel_text:translation, parallel_text:book, parallel_text:chapter)
      parallel_text:display = yes
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
    search:search_input = search:search_input.replace(/\//g, '')
    search:search_input = search:search_input.replace(/\\/g, '')
    if search:search_input != '' && (search:search_result_header != search:search_input || !@search:search_div)
      clearSpace
      loading = yes
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
      try
        loadData(url).then do |data|
          @search_verses = data
          @search:bookid_of_results = []
          for verse in @search_verses
            if !@search:bookid_of_results.find(do |element| return element == verse:book)
              @search:bookid_of_results.push verse:book
          closeSearch
          Imba.commit
      catch error
        console.error('Error: ', error)

  def closeSearch close
    loading = no
    @search:counter = 50
    @search:search_div = yes
    if close
      @search:search_div = !@search:search_div
      @search:change_translation = no
    @search:search_result_header = @search:search_input
    settings_menu_left = -300
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
    if settings:font:size > 16
      settings:font:size -= 2
      setCookie('font', settings:font:size)

  def increaceFontSize
    if settings:font:size < 64 && window:innerWidth > 480
      settings:font:size = settings:font:size + 2
      setCookie('font', settings:font:size)
    elif settings:font:size < 40
      settings:font:size = settings:font:size + 2
      setCookie('font', settings:font:size)

  def setFontFamily font
    settings:font:family = font:code
    settings:font:name = font:name
    setCookie('font-family', font:code)
    setCookie('font-name', font:name)
    show_fonts = no

  def setLanguage language
    settings:language = language
    switch language
      when 'ukr' then @langdata = uk_leng
      when 'ru' then @langdata = ru_leng
      else @langdata = en_leng
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
    if window:innerWidth > 600
      if e.x < 32
        bible_menu_left = 0
        mobimenu = 'show_bible_menu'
      elif e.x > window:innerWidth - 32
        settings_menu_left = 0
        mobimenu = 'show_settings_menu'
      elif 300 < e.x < window:innerWidth - 300
        bible_menu_left = -300
        settings_menu_left = -300
        mobimenu = ''

  def ontouchstart touch
    if touch.x < 32 || touch.x > window:innerWidth - 32
      inzone = true
    self

  def ontouchupdate touch
    if inzone
      if (bible_menu_left < 0 && touch.dx < 300) && mobimenu != 'show_settings_menu'
        bible_menu_left = touch.dx - 300
      if (settings_menu_left < 0 && touch.dx > -300) && mobimenu != 'show_bible_menu'
        settings_menu_left = - 300 - touch.dx
    else
      if mobimenu == 'show_bible_menu' && touch.dx < 0
        bible_menu_left = touch.dx
      if mobimenu == 'show_settings_menu' && touch.dx > 0
        settings_menu_left = - touch.dx
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
        settings_menu_left = -300
        bible_menu_left = -300
        mobimenu = ''
    elif mobimenu == 'show_bible_menu'
      if touch.dx < -64
        bible_menu_left = -300
        mobimenu = ''
      else bible_menu_left = 0
    elif mobimenu == 'show_settings_menu'
      if touch.dx > 64
        settings_menu_left = -300
        mobimenu = ''
      else settings_menu_left = 0
    elif document.getSelection == '' && Math.abs(touch.dy) < 36 && !mobimenu && !search:search_div && !show_history && !choosenid:length
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
    bible_menu_left = -300
    settings_menu_left = -300
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
        if window:innerWidth < 600
          if parallel == "first"
            window:location:hash = "#{id}"
          else
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
    if choosenid:length
      highlighted_title = getHighlightedRow

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
    if !window:username
      window:location:pathname = "/signup/";
    window.fetch("/save-bookmarks/", {
      method: "POST",
      cache: "no-cache",
      headers: {
        'X-CSRFToken': get_cookie('csrftoken'),
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        verses: JSON.stringify(choosenid),
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
    # else
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
      value += '"\n\n' + getHighlightedRow
      if !settings:clear_copy
        value += ' ' + parallel_text:translation + ', ' + "https://bolls.life" + '/' + parallel_text:translation + '/' + parallel_text:book + '/' + parallel_text:chapter
    else
      value += '"\n\n' + getHighlightedRow
      if !settings:clear_copy
        value += ' ' + settings:translation + ' ' + "https://bolls.life" + '/'+ settings:translation + '/' + settings:book + '/' + settings:chapter + '/' + choosen.sort(do |a, b| return a - b)[0]
    aux:textContent = value
    document:body.appendChild(aux)
    aux.select()
    document.execCommand("copy")
    document:body.removeChild(aux)
    clearSpace

  def toProfile from_build = no
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
    document:title = "Bolls " + " | " + window:username
    Imba.mount <Profile>

  def toDownloads from_build
    clearSpace
    flag("display_none")
    if !from_build
      window:history.pushState(
          {
            parallel: no,
            downloads: yes
          },
          "downloads",
          "/downloads/"
        )
    document:title = "Bolls " + " " + @langdata:download
    Imba.mount <Downloads>

  def getNameOfBookFromHistory translation, bookid
    let books = []
    books = BOOKS[translation]
    for book in books
      if book:bookid == bookid
        return book:name

  def turnHistory
    show_history = !show_history
    settings_menu_left = -300
    mobimenu = ''

  def clearHistory
    turnHistory
    @history = []
    window:localStorage.setItem("history", "[]")
    if window:username
      window.fetch("/save-history/", {
        method: "POST",
        cache: "no-cache",
        headers: {
          'X-CSRFToken': get_cookie('csrftoken'),
          "Content-Type": "application/json"
        },
        body: JSON.stringify({
            history: JSON.stringify(@history),
          })
      })
      .then(do |response| response.json())
      .then(do |data| console.log data)

  def turnCollections
    if addcollection
      addcollection = no
    else
      show_collections = !show_collections
      show_color_picker = no
      if show_collections && window:user
        getCategories

  def getCategories
    let url = "/get-categories/"
    @categories = []
    try
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
    catch error
      console.error('Error: ', error)

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
        @categories.unshift(collection)
        sendBookmarksToDjango
        clearSpace
      if collection == store:newcollection
        document.getElementById('newcollectioninput'):value = ''
        store:newcollection = ""
    else
      sendBookmarksToDjango
      clearSpace

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
      settings_menu_left = -300
      mobimenu = 'show_bible_menu'
      if parallel
        parallel_text:edited_version = parallel_text:translation
      else
        parallel_text:edited_version = settings:translation
    else
      bible_menu_left = -300
      mobimenu = ''

  def toggleSettingsMenu
    if settings_menu_left
      settings_menu_left = 0
      bible_menu_left = -300
      mobimenu = 'show_settings_menu'
    else
      settings_menu_left = -300
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
      parallel_text:display = yes
      setCookie('parallel_display', parallel_text:display)
    else
      getText(h:translation, h:book, h:chapter, h:verse)

  def toggleClearCopy
    settings:clear_copy = !settings:clear_copy
    setCookie('clear_copy', settings:clear_copy)

  def toggleVerseBreak
    settings:verse_break = !settings:verse_break
    setCookie('verse_break', settings:verse_break)

  def translationFullName tr
    translations.find(do |translation| return translation:short_name == tr):full_name

  def toggleCompare
    if !window:username
      window:location = "/signup/"
    let book, chapter
    if choosen:length
      choosen_for_comparison = choosen
    if choosen_parallel == 'second'
      compare_parallel_of_chapter = parallel_text:chapter
      compare_parallel_of_book = parallel_text:book
    else
      compare_parallel_of_chapter = settings:chapter
      compare_parallel_of_book = settings:book
    isOnline
    loading = yes
    window.fetch("/get-paralel-verses/", {
      method: "POST",
      cache: "no-cache",
      headers: {
        'X-CSRFToken': get_cookie('csrftoken'),
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        translations: JSON.stringify(compare_translations),
        verses: JSON.stringify(choosen_for_comparison),
        book: compare_parallel_of_book,
        chapter: compare_parallel_of_chapter,
      }),
    })
    .then(do |response| response.json())
    .then(do |data|
        comparison_parallel = []
        comparison_parallel = data
        clearSpace
        loading = no
        show_compare = yes
        Imba.commit()
      )

  def addTranslation translation
    if !compare_translations.find(do |element| return element == translation:short_name)
      compare_translations.unshift(translation:short_name)
      toggleCompare
    else
      compare_translations.splice(compare_translations.indexOf(compare_translations.find(do |element| return element == translation:short_name)), 1)
      comparison_parallel.splice(comparison_parallel.indexOf(comparison_parallel.find(do |element| return element[0]:translation == translation:short_name)), 1)
    window:localStorage.setItem("compare_translations", JSON.stringify(compare_translations))
    show_translations_for_comparison = no

  def changeOrder key, value
    if !((key == 0 && value < 0) || (key == compare_translations:length - 1 && value > 0))
      let tmp = comparison_parallel[key]
      comparison_parallel[key] = comparison_parallel[key + value]
      comparison_parallel[key + value] = tmp
      tmp = compare_translations[key]
      compare_translations[key] = compare_translations[key + value]
      compare_translations[key + value] = tmp
      Imba.commit

  def changeLineHeight increace
    if increace && settings:font:line-height < 2.6
      settings:font:line-height += 0.2
    elif settings:font:line-height > 1.2
      settings:font:line-height -= 0.2
    setCookie('line-height', settings:font:line-height)

  def changeMaxWidth increace
    if increace && settings:font:max-width < 150
      settings:font:max-width += 15
    elif settings:font:max-width > 30
      settings:font:max-width -= 15
    setCookie('max-width', settings:font:max-width)


  def render
    <self>
      <nav css:left="{bible_menu_left}px" css:box-shadow="0 0 {(bible_menu_left + 300) / 16}px rgba(0, 0, 0, 0.3)">
        if parallel_text:display
          <.choose_parallel>
            <p.translation_name title=translationFullName(settings:translation) a:role="button" .current_translation=(parallel_text:edited_version == settings:translation) :tap.prevent.changeEditedParallel(settings:translation) tabindex="0"> settings:translation
            <p.translation_name title=translationFullName(parallel_text:translation) a:role="button" .current_translation=(parallel_text:edited_version == parallel_text:translation) :tap.prevent.changeEditedParallel(parallel_text:translation) tabindex="0"> parallel_text:translation
          if parallel_text:edited_version == parallel_text:translation
            <p.translation_name title=langdata:change_translation :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> parallel_text:edited_version
          else
            <p.translation_name title=langdata:change_translation :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        else
          <p.translation_name title=langdata:change_translation :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations) tabindex="0"> settings:translation
        <svg:svg.chronological_order .hide_chron_order=@show_list_of_translations .chronological_order_in_use=@chronorder :tap.prevent.toggleChronorder xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" title=langdata:chronological_order>
          <title> langdata:chronological_order
          <svg:path d="M10 20a10 10 0 1 1 0-20 10 10 0 0 1 0 20zm0-2a8 8 0 1 0 0-16 8 8 0 0 0 0 16zm-1-7.59V4h2v5.59l3.95 3.95-1.41 1.41L9 10.41z">
        <ul.translations_list .show_translations_list=@show_list_of_translations>
          for translation in translations
            <li.book_in_list.translation_in_list .active_book=currentTranslation(translation:short_name) :tap.prevent.changeTranslation(translation:short_name) tabindex="0"> translation:full_name
          <.freespace>
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

      <main#main tabindex="0" .parallel_text=parallel_text:display style="font-family: {settings:font:family}; font-size: {settings:font:size}px; line-height: {settings:font:line-height}; max-width: {settings:font:max-width}em">
        <section .parallel=parallel_text:display dir="auto">
          <header>
            <h1 :tap.prevent.toggleBibleMenu() title=translationFullName(settings:translation)> nameOfBook(settings:book, false), ' ', settings:chapter
          <article>
            <.text-ident> " "
            for verse in @verses
              if settings:verse_break
                <br>
                <.text-ident> " "
              <a.verse id=verse:verse href="#{verse:verse}">
                ' '
                verse:verse
              <text-as-html[{text: verse:text}]
                  tabindex="0"
                  :keydown.enter.sendBookmarksToDjango
                  :tap.prevent.addToChoosen(verse:pk, verse:verse, 'first')
                  .highlighted=getHighlight(verse:pk)
                  .clicked=choosenid.find(do |element| return element == verse:pk)
                  css:text-decoration-color=getHighlight(verse:pk)
                >
            <.arrows>
              <a.arrow :tap.prevent.prewChapter() title=langdata:prew>
                <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:prew
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
              <a.arrow :tap.prevent.nextChapter() title=langdata:next>
                <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                  <svg:title> langdata:next
                  <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            if choosen:length
              <.freespace>
        <section.display_none.parallel .show_parallel=parallel_text:display dir="auto">
          <header>
            <h1 :tap.prevent.toggleBibleMenu(yes) title=translationFullName(parallel_text:translation)> nameOfBook(parallel_text:book, true), ' ', parallel_text:chapter
          <article>
            <.text-ident> " "
            for verse in @parallel_verses
              if settings:verse_break
                <br>
                <.text-ident> " "
              <a.verse id="p{verse:verse}" href="#p{verse:verse}">
                ' '
                verse:verse
              <text-as-html[{text: verse:text}]
                :tap.prevent.addToChoosen(verse:pk, verse:verse, 'second')
                .highlighted=getParallelHighlight(verse:pk)
                .clicked=choosenid.find(do |element| return element == verse:pk)
                css:text-decoration-color=getParallelHighlight(verse:pk)>
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

      <aside css:right="{settings_menu_left}px" css:box-shadow="0 0 {(settings_menu_left + 300) / 16}px rgba(0, 0, 0, 0.3)">
        <p.settings_header> langdata:other
        <input[search:search_input].search id='search' type='search' placeholder=langdata:search input:aria-label=langdata:search :keydown.enter.prevent.getSearchText> langdata:search
        <.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          langdata:theme
          <.theme_checkbox :tap.prevent.changeTheme>
            if settings:theme == "dark"
              <svg:svg css:transform="scale(1.2)" xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" height="24" viewBox="0 0 24 24" width="24">
                <svg:g>
                  <svg:rect fill="none" height="24" width="24">
                <svg:g>
                  <svg:path d="M11.1,12.08C8.77,7.57,10.6,3.6,11.63,2.01C6.27,2.2,1.98,6.59,1.98,12c0,0.14,0.02,0.28,0.02,0.42 C2.62,12.15,3.29,12,4,12c1.66,0,3.18,0.83,4.1,2.15C9.77,14.63,11,16.17,11,18c0,1.52-0.87,2.83-2.12,3.51 c0.98,0.32,2.03,0.5,3.11,0.5c3.5,0,6.58-1.8,8.37-4.52C18,17.72,13.38,16.52,11.1,12.08z">
                <svg:path d="M7,16l-0.18,0C6.4,14.84,5.3,14,4,14c-1.66,0-3,1.34-3,3s1.34,3,3,3c0.62,0,2.49,0,3,0c1.1,0,2-0.9,2-2 C9,16.9,8.1,16,7,16z">
            else
              <svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <svg:title> @langdata:nighttheme
                <svg:path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
        <.nighttheme>
          langdata:font
          <a.great_B :tap.prevent.decreaceFontSize> "B-"
          "{settings:font:size}"
          <a.little_B :tap.prevent.increaceFontSize> "B+"
        <.btnbox>
          <svg:svg.cbtn :tap.prevent.changeLineHeight(no) xmlns="http://www.w3.org/2000/svg" width="38" height="14" viewBox="0 0 38 14" fill="context-fill" style="padding: calc(42px - 26px) 0;">
            <svg:title> @langdata:decreace_line-height
            <svg:rect x="0" y="0" width="28" height="2">
            <svg:rect x="0" y="6" width="38" height="2">
            <svg:rect x="0" y="12" width="18" height="2">
          <svg:svg.cbtn :tap.prevent.changeLineHeight(yes) xmlns="http://www.w3.org/2000/svg" width="38" height="24" viewBox="0 0 38 24" fill="context-fill" style="padding: calc(42px - 28px) 0;">
            <svg:title> @langdata:increace_line-height
            <svg:rect x="0" y="0" width="28" height="2">
            <svg:rect x="0" y="11" width="38" height="2">
            <svg:rect x="0" y="22" width="18" height="2">
        if window:innerWidth > 600
          <.btnbox>
            <svg:svg.cbtn :tap.prevent.changeMaxWidth(no) xmlns="http://www.w3.org/2000/svg" width="42" height="16" viewBox="0 0 42 16" fill="context-fill" style="padding: calc(42px - 28px) 0;">
              <svg:title> @langdata:increace_max-width
              <svg:path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z">
              <svg:path d="M38.5,7 L32.75,1.25 L34,6.58831647e-15 L42,8 L41.375,8.625 L34,16 L32.75,14.75 L38.5,9 L24,9 L24,7 L38.5,7 Z" transform="translate(33.000000, 8.000000) scale(-1, 1) translate(-33.000000, -8.000000)">
            <svg:svg.cbtn :tap.prevent.changeMaxWidth(yes) xmlns="http://www.w3.org/2000/svg" width="44" height="16" viewBox="0 0 44 16" fill="context-fill" style="padding: calc(42px - 28px) 0;">
              <svg:title> @langdata:decreace_max-width
              <svg:path d="M14.5,7 L8.75,1.25 L10,-1.91791433e-15 L18,8 L17.375,8.625 L10,16 L8.75,14.75 L14.5,9 L1.13686838e-13,9 L1.13686838e-13,7 L14.5,7 Z" transform="translate(9.000000, 8.000000) scale(-1, 1) translate(-9.000000, -8.000000)">
              <svg:path d="M40.5,7 L34.75,1.25 L36,-5.17110888e-16 L44,8 L43.375,8.625 L36,16 L34.75,14.75 L40.5,9 L26,9 L26,7 L40.5,7 Z">
        <.nighttheme css:flex-wrap="wrap">
          langdata:font-family
          <button.change_language :tap.prevent=(do show_fonts = !show_fonts)>
            settings:font:name
          <.languages .show_languages=show_fonts>
            for font in fonts
              <button :tap.prevent.setFontFamily(font) css:font-family=font:code> font:name
        <.nighttheme>
          langdata:parallel
          <a.parallel_checkbox :tap.prevent.toggleParallelMode>
            <span .parallel_checkbox_turned=parallel_text:display>
        <.help :tap.prevent.turnHistory>
          langdata:history
          <svg:svg.asidesvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
            <svg:title> langdata:history
            <svg:path d="M0 0h24v24H0z" fill="none">
            <svg:path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z">
        <.profile_in_settings>
          if user:name
            <a.username :tap.prevent.toProfile(no)> user:name
            <a.prof_btn href="/accounts/logout/"> langdata:logout
          else
            <a.prof_btn href="/accounts/login/"> langdata:login, ' '
            <a.prof_btn.signin href="/signup/"> langdata:signin
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
            <button :tap.prevent.setLanguage('ru')> "Русский"
            <button :tap.prevent.setLanguage('eng')> "English"
        if !on_electron
          <a.help :click.prevent.toDownloads(no)>
            langdata:download
            <svg:svg.asidesvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
              <svg:title> langdata:download
              <svg:path d="M0 0h24v24H0z" fill="none">
              <svg:path d="M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96zM17 13l-5 5-5-5h3V9h4v4h3z">
        <a.help :click.prevent.turnHelpBox()>
          langdata:help
          <svg:svg.asidesvg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
            <svg:title> langdata:help
            <svg:path fill="none" d="M0 0h24v24H0z">
            <svg:path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z">
        <.freespace>
        <footer css:padding-bottom="4px">
          <a href="/api">
            "© "
            <time time:datetime="2020-01-22T12:38"> "2019-2020"
            " Павлишинець Богуслав"

      <section.search_results .show_search_results=search:search_div>
        <article.search_hat>
          <svg:svg.close_search :tap.prevent.closeSearch(true) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:close
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" css:margin="auto">
          <h1> search:search_result_header
          <svg:svg.filter_search .filter_search_hover=search:show_filters||search:is_filter :tap.prevent=(do search:show_filters = !search:show_filters) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> langdata:addfilter
            <svg:path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">
        <article#search_body.search_body tabindex="0">
          if @search_verses:length
            <.filters .show=search:show_filters>
              if parallel_text:edited_version == parallel_text:translation && parallel_text:display
                if search:is_filter then <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                for book in @parallel_books
                  <a.book_in_list.book_in_filter dir="auto" :tap.prevent.addFilter(book:bookid)> book:name
              else
                if search:is_filter then <a.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                for book in @books when @search:bookid_of_results.find(do |element| return element == book:bookid)
                  <a.book_in_list.book_in_filter dir="auto" :tap.prevent.addFilter(book:bookid)> book:name
            if search:is_filter
              <p.search_results_total> getFilteredArray:length, ' ', langdata:totalyresultsofsearch
              for verse, key in getFilteredArray
                <a.search_item>
                  <.search_res_verse_text :tap.prevent.getText(verse:translation, verse:book, verse:chapter, verse:verse)>
                    <text-as-html[{text: verse:text}]>
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:book, choosen_parallel), ' '
                    <span> verse:chapter, ':'
                    <span> verse:verse
                    <svg:svg.open_in_parallel style="margin-left: 4px;" viewBox="0 0 400 338" :tap.prevent.backInHistory({translation: @search:translation, book: verse:book, chapter: verse:chapter,verse: verse:verse}, yes)>
                      <svg:title> langdata:open_in_parallel
                      <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
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
                    <text-as-html[{text: verse:text}]>
                  <.search_res_verse_header>
                    <span> nameOfBook(verse:book, choosen_parallel), ' '
                    <span> verse:chapter, ':'
                    <span> verse:verse
                    <svg:svg.open_in_parallel style="margin-left: 4px;" viewBox="0 0 400 338" :tap.prevent.backInHistory({translation: @search:translation, book: verse:book, chapter: verse:chapter,verse: verse:verse}, yes)>
                      <svg:title> langdata:open_in_parallel
                      <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter += 50) tabindex="0" style="margin: auto; display: flex;"> langdata:more_results
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
                xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16" tabindex="0"
                >
              <svg:title> langdata:close
              <svg:path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">
          <colorpicker .show-canvas=show_color_picker canvas:alt=langdata:canvastitle id="" tabindex="0">  langdata:canvastitle
        <p> highlighted_title
        <ul.mark_grid>
          for highlight in highlights.slice().reverse()
            <li.color_mark css:background=highlight :tap.prevent.changeHighlightColor(highlight)>
              <svg:svg.delete_color
                  :tap.prevent.deleteColor(highlight)
                  xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0"
                  >
                <svg:title> langdata:delete
                <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
          <li.color_mark css:background="FireBrick" :tap.prevent.changeHighlightColor("#b22222")>
          <li.color_mark css:background="Chocolate" :tap.prevent.changeHighlightColor("#d2691e")>
          <li.color_mark css:background="GoldenRod" :tap.prevent.changeHighlightColor("#daa520")>
          <li.color_mark css:background="OliveDrab" :tap.prevent.changeHighlightColor("#6b8e23")>
          <li.color_mark css:background="RoyalBlue" :tap.prevent.changeHighlightColor("#4169e1")>
          <li.color_mark css:background="#984da5" :tap.prevent.changeHighlightColor("#984da5")>
          <li.color_mark
            css:border="none"
            css:background="linear-gradient(217deg, rgba(255,0,0,.8), rgba(255,0,0,0) 70.71%),
            linear-gradient(127deg, rgba(0,255,0,.8), rgba(0,255,0,0) 70.71%),
            linear-gradient(336deg, rgba(0,0,255,.8), rgba(0,0,255,0) 70.71%)"
            :tap.prevent=(do show_color_picker = !show_color_picker)>
        <#addbuttons>
          <svg:svg.close_search :tap.prevent.clearSpace() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:close>
            <svg:title> langdata:close
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=langdata:delete>
          <svg:svg.close_search :tap.prevent.deleteBookmarks() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16" alt=langdata:delete>
            <svg:title> langdata:delete
            <svg:path fill-rule="evenodd" clip-rule="evenodd" d="M11 2H9C9 1.45 8.55 1 8 1H5C4.45 1 4 1.45 4 2H2C1.45 2 1 2.45 1 3V4C1 4.55 1.45 5 2 5V14C2 14.55 2.45 15 3 15H10C10.55 15 11 14.55 11 14V5C11.55 5 12 4.55 12 4V3C12 2.45 11.55 2 11 2ZM10 14H3V5H4V13H5V5H6V13H7V5H8V13H9V5H10V14ZM11 4H2V3H11V4Z">
          <svg:svg.save_bookmark :tap.prevent.copyToClipboard() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=langdata:copy>
            <svg:title> langdata:copy
            <svg:path d="M395.25,0h-306c-28.05,0-51,22.95-51,51v357h51V51h306V0z M471.75,102h-280.5c-28.05,0-51,22.95-51,51v357	c0,28.05,22.95,51,51,51h280.5c28.05,0,51-22.95,51-51V153C522.75,124.95,499.8,102,471.75,102z M471.75,510h-280.5V153h280.5V510 z">
          <svg:svg.save_bookmark :tap.prevent.toggleCompare() version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="580.125px" height="580.125px" viewBox="0 0 580.125 580.125" style="enable-background:new 0 0 580.125 580.125; transform: rotate(90deg);" xml:space="preserve">
            <svg:title> @langdata:compare
            <svg:path d="M573.113,298.351l-117.301-117.3c-3.824-3.825-10.199-5.1-15.299-2.55c-5.102,2.55-8.926,7.65-8.926,12.75v79.05    c-38.25,0-70.125,6.375-96.9,19.125V145.35h73.951c6.375,0,11.475-3.825,12.75-8.925c2.549-5.1,1.273-11.475-2.551-15.3    L301.537,3.825C298.988,1.275,295.162,0,291.338,0c-3.825,0-7.65,1.275-10.2,3.825l-118.575,117.3    c-3.825,3.825-5.1,10.2-2.55,15.3c2.55,5.1,7.65,8.925,12.75,8.925h75.225v142.8c-26.775-12.75-58.65-19.125-98.175-19.125v-79.05    c0-6.375-3.825-11.475-8.925-12.75c-5.1-2.55-11.475-1.275-15.3,2.55l-117.3,117.3c-2.55,2.55-3.825,6.375-3.825,10.2    s1.275,7.649,3.825,10.2l117.3,117.3c3.825,3.825,10.2,5.1,15.3,2.55c5.1-2.55,8.925-7.65,8.925-12.75v-66.3    c72.675,0,96.9,24.225,96.9,98.175v79.05c0,24.226,19.125,43.351,42.075,44.625h2.55c22.949-1.274,42.074-20.399,42.074-44.625    v-79.05c0-73.95,22.951-98.175,96.9-98.175v66.3c0,6.375,3.826,11.475,8.926,12.75c5.1,2.55,11.475,1.275,15.299-2.55    l117.301-117.3c2.551-2.551,3.824-6.375,3.824-10.2S575.662,300.9,573.113,298.351z">
          <svg:svg.save_bookmark .filled=choosen_categories:length :tap.prevent.turnCollections() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:addtocollection>
            <svg:title> langdata:addtocollection
            <svg:path d="M2 2c0-1.1.9-2 2-2h12a2 2 0 0 1 2 2v18l-8-4-8 4V2zm2 0v15l6-3 6 3V2H4z">

          <svg:svg.save_bookmark css:padding="10px 0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 16" :tap.prevent.sendBookmarksToDjango alt=langdata:create>
            <svg:title> langdata:create
            <svg:path fill-rule="evenodd" clip-rule="evenodd" d="M12 5L4 13L0 9L1.5 7.5L4 10L10.5 3.5L12 5Z">

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
              <svg:title> langdata:close
              <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z">
          <h1 css:margin="0 0 0 8px"> langdata:history
          <svg:svg.close_search :tap.prevent.clearHistory xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" style="padding: 0; margin: 0 12px 0 16px; width: 32px;" alt=langdata:delete css:margin-left="auto">
            <svg:title> langdata:delete
            <svg:path d="M15 16h4v2h-4v-2zm0-8h7v2h-7V8zm0 4h6v2h-6v-2zM3 20h10V8H3v12zM14 5h-3l-1-1H6L5 5H2v2h12V5z">
        <article.historylist>
          if @history:length
            for h in @history.slice().reverse
              <div css:display="flex">
                <a.book_in_list :tap.prevent.backInHistory(h)>
                  getNameOfBookFromHistory(h:translation, h:book), ' ', h:chapter
                  if h:verse
                    ':' + h:verse
                  ' ', h:translation
                <svg:svg.open_in_parallel viewBox="0 0 400 338" :tap.prevent.backInHistory(h, yes)>
                  <svg:title> langdata:open_in_parallel
                  <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
          else
            <p css:padding="12px"> langdata:empty_history

      <.search_results .show_search_results=show_help>
        <article.search_hat>
          <svg:svg.close_search :tap.prevent.turnHelpBox() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> @langdata:close
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" css:margin="auto">
          <h1> @langdata:help
          <a href="mailto:bpavlisinec@gmail.com">
            <svg:svg.filter_search xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16">
              <svg:title> langdata:help
              <svg:g>
                  <svg:path d="M16 2L0 7l3.5 2.656L14.563 2.97 5.25 10.656l4.281 3.156z">
                  <svg:path d="M3 8.5v6.102l2.83-2.475-.66-.754L4 12.396V8.5z" style="line-height:normal;font-variant-ligatures:normal;font-variant-position:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-alternates:normal;font-feature-settings:normal;text-indent:0;text-align:start;text-decoration-line:none;text-decoration-style:solid;text-decoration-color:#000;text-transform:none;text-orientation:mixed;shape-padding:0;isolation:auto;mix-blend-mode:normal" color="#000" font-weight="400" font-family="sans-serif" white-space="normal" overflow="visible" fill-rule="evenodd">
        <article#helpFAQ.search_body tabindex="0">
          <p style="color: var(--accent-hover-color); font-size: 0.9em;"> @langdata:faqmsg
          for q in @langdata:HB
            <h3> q[0]
            <p> q[1]
          <address.still_have_questions>
            @langdata:still_have_questions
            <a href="mailto:bpavlisinec@gmail.com"> " bpavlisinec@gmail.com"

      <.search_results .show_search_results=show_compare>
        <article.search_hat>
          <svg:svg.close_search :tap.prevent.clearSpace() xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" tabindex="0">
            <svg:title> @langdata:close
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" css:margin="auto">
          <h1> highlighted_title
          <svg:svg.filter_search :tap.prevent=(do show_translations_for_comparison = !show_translations_for_comparison) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:addcollection style="stroke: var(--text-color);">
            <svg:title> @langdata:compare
            <svg:line x1="0" y1="10" x2="20" y2="10">
            <svg:line x1="10" y1="0" x2="10" y2="20">
        <article.search_body tabindex="0">
          <.filters .show=show_translations_for_comparison>
            for translation in translations when !compare_translations.find(do |element| return element == translation:short_name)
              <a.book_in_list.book_in_filter dir="auto" :tap.prevent.addTranslation(translation)> translation:short_name, ', ', translation:full_name
          if compare_translations:length
            for tr, key in comparison_parallel
              if tr[0]:text
                <a.search_item>
                  <.search_res_verse_text :tap.prevent.getText(tr[0]:translation, tr[0]:book, tr[0]:chapter, tr[0]:verse)>
                    for aoeirf in tr
                      <text-as-html[{text: aoeirf:text}]>
                      ' '
                  <.search_res_verse_header>
                    <svg:svg.open_in_parallel :tap.prevent.changeOrder(key, -1) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                      <svg:title> @langdata:move_up
                      <svg:path d="M10.707 7.05L10 6.343 4.343 12l1.414 1.414L10 9.172l4.243 4.242L15.657 12z">
                    <svg:svg.open_in_parallel :tap.prevent.changeOrder(key, 1) style="margin-right: auto;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                      <svg:title> @langdata:move_down
                      <svg:path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z">
                    <span> tr[0]:translation
                    <svg:svg.open_in_parallel style="margin-left: 4px;" viewBox="0 0 400 338" :tap.prevent.backInHistory({translation: tr[0]:translation, book: tr[0]:book, chapter: tr[0]:chapter,verse: tr[0]:verse}, yes)>
                      <svg:title> langdata:open_in_parallel
                      <svg:path d="m 35.947269,14.468068 c -7.96909,0.761819 -16.598173,3.661819 -16.598173,5.578181 0,0.283637 -0.409098,0.516366 -0.9091,0.516366 -0.498179,0 -1.332722,0.650908 -1.854541,1.445453 -0.520001,0.794545 -2.256364,2.158182 -3.856366,3.03091 -4.285453,2.334544 -5.9854532,4.496361 -7.5981802,9.663636 -0.7927282,2.536363 -1.6272727,4.750909 -1.858182,4.921819 -0.2290916,0.170908 -1.0600004,2.521818 -1.8454543,5.225454 L 0,49.764433 V 168.41534 287.06625 l 1.4272725,4.91455 c 0.7854539,2.70181 1.6163627,5.05454 1.8454543,5.22545 0.2309093,0.17092 1.0654538,2.38545 1.858182,4.92182 1.612727,5.16726 3.3127272,7.32728 7.5981802,9.66363 1.600002,0.87272 3.336365,2.23636 3.856366,3.03092 0.521819,0.79452 1.356362,1.44362 1.854541,1.44362 0.500002,0 0.9091,0.23274 0.9091,0.51819 0,0.97455 6.109083,3.84182 10.278172,4.82544 7.17819,1.69457 80.296372,1.94183 87.632732,0.29821 6.04365,-1.35455 8.16364,-2.48183 9.22727,-4.90546 0.40182,-0.9109 0.87272,-1.79637 1.04909,-1.96547 5.33636,-5.12908 5.2909,-24.29272 -0.0655,-26.3327 -0.29454,-0.11269 -0.53818,-0.51092 -0.53818,-0.88365 0,-1.3 -2.77638,-4.72909 -4.30183,-5.31455 -5.89455,-2.25456 -9.98909,-2.5109 -40.25998,-2.5109 -36.860001,0 -34.947277,0.51454 -36.567284,-9.83638 -0.858176,-5.48545 -0.858176,-198.001811 0,-203.489084 1.620007,-10.350909 -0.292717,-9.836364 36.567284,-9.836364 30.27089,0 34.36543,-0.254545 40.25998,-2.510908 1.52545,-0.583637 4.30183,-4.012727 4.30183,-5.312727 0,-0.374545 0.24364,-0.772727 0.53818,-0.885455 5.35636,-2.04 5.40181,-21.203636 0.0655,-26.332727 -0.17637,-0.16909 -0.64727,-1.052729 -1.04909,-1.965455 -1.05091,-2.392728 -3.17091,-3.545455 -8.92001,-4.845456 -5.51091,-1.245455 -69.73089,-1.650909 -81.619991,-0.512726 m 246.099981,0.529091 c -5.69089,1.21091 -7.93817,2.427274 -8.91452,4.829091 -0.37091,0.912726 -1.60183,3.692727 -2.73819,6.18 -4.27455,9.361817 0.24001,27.027273 7.3291,28.67091 8.94546,2.072725 10.49999,2.156362 40.21634,2.156362 36.34002,0 34.19274,-0.58909 35.82365,9.836364 0.85818,5.487273 0.85818,198.003634 0,203.489084 -1.63091,10.42546 0.51637,9.83638 -35.82365,9.83638 -29.71635,0 -31.27088,0.0836 -40.21634,2.15818 -7.08909,1.64182 -11.60365,19.30728 -7.3291,28.6709 1.13636,2.48545 2.36728,5.26729 2.73819,6.17819 2.17818,5.35636 7.25091,5.97636 48.99091,5.98726 47.96181,0.011 53.39271,-0.65817 60,-7.39999 1.30546,-1.33091 3.97272,-3.35817 5.92728,-4.50365 5.00909,-2.93636 5.34181,-3.44362 7.8509,-12.03272 1.23455,-4.22727 2.63636,-8.98183 3.11636,-10.56728 1.30909,-4.31999 1.30909,-235.821808 0,-240.143626 -0.48,-1.585453 -1.88181,-6.340002 -3.11636,-10.565455 -2.50909,-8.589091 -2.84181,-9.098182 -7.8509,-12.032726 -1.95456,-1.147273 -4.62182,-3.172728 -5.92728,-4.505456 -6.62545,-6.759999 -12.08,-7.425455 -60.30728,-7.359999 -30.57273,0.03999 -35.33819,0.174545 -39.76911,1.118181 M 87.376365,79.578977 c -4.607281,1.176365 -8.121816,2.990911 -9.203634,4.752728 -0.27636,0.44909 -2.036369,1.681818 -3.910908,2.740001 -5.672728,3.203638 -7.954555,10.047268 -6.37819,19.130914 0.736366,4.23454 3.161817,9.64908 4.325463,9.64908 0.30363,0 2.779992,1.52728 5.505453,3.39273 8.1709,5.59637 11.061814,6.05454 35.805451,5.66182 l 56.45636,-0.32 5.72727,-2.60364 c 7.41637,-3.37091 9.73092,-5.63089 13.21092,-12.89272 3.3909,-7.07273 3.38726,-7.00365 0.48909,-13.678185 -2.98546,-6.872727 -6.95455,-10.823637 -14.29275,-14.223636 l -5.09272,-2.36 -57.0909,-0.24 C 93.743646,78.36625 91.839989,78.440796 87.376365,79.578977 M 241.08363,78.920795 c -6.49817,0.452729 -11.56727,2.516364 -15.91091,6.474546 -1.22364,1.116365 -2.97454,2.685455 -3.89091,3.487273 -1.76363,1.540005 -6.18547,10.963629 -6.1509,13.103646 0.10547,6.45272 7.52182,15.68726 15.91999,19.81998 l 5.64364,2.7782 49.26727,0.30908 c 24.90001,0.38364 28.70364,-0.17455 35.30363,-5.16909 2.17092,-1.64362 4.80001,-3.34182 5.84364,-3.77272 7.77637,-3.22182 7.46546,-24.098183 -0.41817,-28.092733 -1.69818,-0.861818 -4.38547,-2.790907 -5.97272,-4.290908 -4.51637,-4.265455 -7.36,-4.769092 -27.79638,-4.927273 -9.29818,-0.07091 -48.62546,0.05455 -51.83818,0.279999 M 84.821812,147.80261 c -16.609086,1.92911 -23.163629,22.64728 -11.147262,35.23274 6.041815,6.32908 5.400001,6.20544 34.03271,6.47818 33.53273,0.31999 74.59455,-0.45455 77.58363,-6.79637 0.68002,-1.44182 2.23455,-4.10182 3.45275,-5.91092 3.30727,-4.90544 3.30727,-11.87635 0,-16.7818 -1.2182,-1.8091 -2.77273,-4.47092 -3.45275,-5.91274 -2.89271,-6.13636 -43.69271,-6.93272 -74.3418,-6.82 -12.341809,0.0454 -24.098174,0.27455 -26.127278,0.51091 m 148.270908,0.0309 c -1.52181,0.30546 -3.65453,0.71456 -4.73818,0.90909 -1.86183,0.33274 -6.94364,4.48182 -6.94364,5.66728 0,0.29636 -1.24546,2.43272 -2.76544,4.74908 -2.71274,4.1291 -2.76728,4.31274 -2.76728,9.25636 0,4.94365 0.0545,5.12546 2.76728,9.25455 1.51998,2.31638 2.76544,4.44183 2.76544,4.72184 0,0.8418 4.18183,4.75817 5.67818,5.31999 6.85637,2.57273 87.83092,2.74544 92.66909,0.21091 17.19273,-9.00365 17.19273,-29.98365 0,-39.02183 -2.79635,-1.46909 -80.21455,-2.36727 -86.66545,-1.06727 M 87.438188,212.96987 c -3.589094,0.91636 -5.980006,2.05274 -9.718182,4.61273 -2.727273,1.86727 -5.20728,3.39456 -5.51091,3.39456 -1.163646,0 -3.589097,5.41452 -4.325463,9.65091 -1.576365,9.08362 0.705462,15.92726 6.37819,19.12908 1.874539,1.05818 3.634548,2.2909 3.910908,2.73999 3.005456,4.89819 10.938184,6.20002 35.379999,5.81273 l 56.48909,-0.31818 5.07999,-2.35455 c 7.32544,-3.39453 11.29818,-7.34908 14.28183,-14.22 2.89817,-6.67272 2.90181,-6.60364 -0.48909,-13.67635 -3.48,-7.26546 -5.79455,-9.52181 -13.22183,-12.90002 l -5.74001,-2.60909 -57.05998,-0.23999 c -19.069101,-0.22 -21.067263,-0.14363 -25.454542,0.97818 m 153.645442,-0.62182 c -6.73272,0.44726 -13.41273,3.35091 -18.27818,7.94727 -2.64363,2.4982 -7.63273,11.95275 -7.67454,14.54728 -0.0345,2.14 4.38727,11.56364 6.1509,13.10546 0.91637,0.80181 2.70909,2.40909 3.98364,3.57091 1.27455,1.16181 4.41636,3.1109 6.98181,4.32909 l 4.66364,2.21455 50.3891,0.0545 c 25.75637,0.0654 28.65817,-0.35455 33.4109,-4.84727 1.59092,-1.50366 4.28183,-3.43821 5.98001,-4.29821 7.88363,-3.99454 8.19454,-24.87271 0.41817,-28.09271 -1.04363,-0.43272 -3.67272,-2.12911 -5.84181,-3.77273 -6.75273,-5.11092 -52.11091,-6.62546 -80.18364,-4.75819" style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
                    <svg:svg#remove_parallel.close_search :tap.prevent.addTranslation({short_name: tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:delete>
                      <svg:title> langdata:delete
                      <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=langdata:delete>
              else
                <p style="padding: 16px 0;display: flex;">
                  @langdata:the_verse_is_not_available, tr[0]:translation, tr[0]:text
                  <svg:svg#remove_parallel.close_search style="margin: -8px 0 0 auto;" :tap.prevent.addTranslation({short_name: tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=langdata:delete>
                    <svg:title> langdata:delete
                    <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=langdata:delete>
            <.freespace>
          else
            <p style="text-align: center;"> @langdata:add_translations_msg
            <button.more_results style="margin: 16px auto; display: flex;" :tap.prevent=(do show_translations_for_comparison = !show_translations_for_comparison)> @langdata:add_translations_btn

      if menuicons
        <svg:svg.navigation :tap.prevent.toggleBibleMenu() style="left: 0;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
          <svg:title> langdata:change_book
          <svg:path d="M3 5H7V6H3V5ZM3 8H7V7H3V8ZM3 10H7V9H3V10ZM14 5H10V6H14V5ZM14 7H10V8H14V7ZM14 9H10V10H14V9ZM16 3V12C16 12.55 15.55 13 15 13H9.5L8.5 14L7.5 13H2C1.45 13 1 12.55 1 12V3C1 2.45 1.45 2 2 2H7.5L8.5 3L9.5 2H15C15.55 2 16 2.45 16 3ZM8 3.5L7.5 3H2V12H8V3.5ZM15 3H9.5L9 3.5V12H15V3Z">
        <svg:svg.navigation :tap.prevent.toggleSettingsMenu() style="right: 0; transform: scaleY(0.8);" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 10">
          <svg:title> langdata:other
          <svg:path fill-rule="evenodd" clip-rule="evenodd" d="M11.41 6H0.59C0 6 0 5.59 0 5C0 4.41 0 4 0.59 4H11.4C11.99 4 11.99 4.41 11.99 5C11.99 5.59 11.99 6 11.4 6H11.41ZM11.41 2H0.59C0 2 0 1.59 0 1C0 0.41 0 0 0.59 0H11.4C11.99 0 11.99 0.41 11.99 1C11.99 1.59 11.99 2 11.4 2H11.41ZM0.59 8H11.4C11.99 8 11.99 8.41 11.99 9C11.99 9.59 11.99 10 11.4 10H0.59C0 10 0 9.59 0 9C0 8.41 0 8 0.59 8Z">

      <.online .offline=offline>
        langdata:offline
        <svg:svg css:transform="translateY(0.2em)" fill="var(--text-color)" xmlns="http://www.w3.org/2000/svg" width="1.25em" height="1.26em" viewBox="0 0 24 24">
          <svg:path fill="none" d="M0 0h24v24H0V0z">
          <svg:path d="M23.64 7c-.45-.34-4.93-4-11.64-4-1.32 0-2.55.14-3.69.38L18.43 13.5 23.64 7zM3.41 1.31L2 2.72l2.05 2.05C1.91 5.76.59 6.82.36 7L12 21.5l3.91-4.87 3.32 3.32 1.41-1.41L3.41 1.31z">
        <a.reload :tap=(do window:location.reload(true))> langdata:reload

      if loading
        <Load style="position: fixed; top: 50%; left: 50%;">

tag text-as-html < span
  def mount
    schedule(events: yes)
    dom:innerHTML = @data:text

  def tick
    if @data:text != dom:innerHTML
      dom:innerHTML = @data:text
      render

  def render
    <self>