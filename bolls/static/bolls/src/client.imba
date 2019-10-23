import YLT, WLC, UBIO, UKRK, LXX, SYNOD, CUV, NTGT, HOM, translations from "./translations_data.imba"

import eng_leng, ukr_leng from "./langdata.imba"


let settings = {
  theme: 'dark',
  translation: 'YLT',
  book: 1,
  chapter: 1,
  font: 24,
  language: 'eng'
}

let search = {
  search_input: '',
  search_result_header: '',
  search_result_translation: '',
  search_div: false,
  counter: 50,
  show_filters: false,
  is_filter: false,
  filter: 0
}

let parallel_text = {
  display: false,
  translation: 'KJV',
  book: 1,
  chapter: 1,
  edited_version: 'KJV',
}

let mobimenu = ''
let offline = false


tag App
  prop verses
  prop search_verses
  prop parallel_verses
  prop parallel_books
  prop books
  prop show_chapters_of
  prop show_list_of_translations
  prop linked_verse
  prop langdata
  prop show_languages


  def build
    if window:preloaded_text
      @verses = window:preloaded_text
      @linked_verse = window:highlighted_verse
      switchTranslation window:preloaded_text[0]:fields:translation, false
      settings:translation = window:preloaded_text[0]:fields:translation
      settings:book = window:preloaded_text[0]:fields:book
      settings:chapter = window:preloaded_text[0]:fields:chapter
      parallel_text:display = false
      if getCookie('language')
        settings:language = getCookie('language')
      else
        switch window:navigator:language
          when 'uk' then settings:language = 'ukr'
          else settings:language = 'eng'
    else
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
          else settings:language = 'eng'
      @verses = getText(settings:translation, settings:book, settings:chapter)
      switchTranslation settings:translation, false
    if getCookie('theme')
      settings:theme = getCookie('theme')
      let html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    if getCookie('font')
      settings:font = parseInt(getCookie('font'))
    if getCookie('parallel_display')
      if getCookie('parallel_display') == 'true'
        toggleParallelMode
    switch settings:language
      when 'eng' then @langdata = eng_leng
      when 'ukr' then @langdata = ukr_leng
    @search_verses = {}
    @show_chapters_of = 0
    @show_list_of_translations = 0
    @show_languages = false


  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def setCookie c_name, value, expiredays
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
        when "KJV" then @books = YLT
        when "NASB" then @books = YLT
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTGT" then @books = NTGT
        when "HOM" then @books = HOM

  def load url
    if window:navigator:onLine
      offline = false
    else
      offline = true
    var res = await window.fetch(url)
    .then( do |result| result.json())
    .then( do |json| return json)

  def getText translation, book, chapter
    settings:book = book
    settings:chapter = chapter
    let url = "get-text/" + translation + '/' + book + '/' + chapter + '/'
    @verses = {}
    @verses = JSON.parse(await load url)
    search:search_div = false
    dropFilter
    Imba.commit
    setCookie('book', book)
    setCookie('chapter', chapter)

  def getParallelText translation, book, chapter
    parallel_text:translation = translation
    parallel_text:edited_version = translation
    parallel_text:book = book
    parallel_text:chapter = chapter
    let url = "get-text/" + translation + '/' + book + '/' + chapter + '/'
    @parallel_verses = {}
    @parallel_verses = JSON.parse(await load url)
    switchTranslation parallel_text:translation, true
    Imba.commit
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

  def getSearchText
    let url
    if parallel_text:edited_version == parallel_text:translation && parallel_text:display
      url = parallel_text:edited_version + '/' + search:search_input + '/'
      search:search_result_translation = parallel_text:edited_version
    else
      url = settings:translation + '/' + search:search_input + '/'
      search:search_result_translation = settings:translation
    @search_verses = {}
    @search_verses = JSON.parse(await load url)
    search:search_result_header = search:search_input
    search:search_div = true
    search:counter = 50
    unflag 'show_settings_menu'
    Imba.commit

  def onmousemove e
    if e.x > window:outerWidth - 20
      flag 'show_settings_menu'
    elif e.x < window:outerWidth - 210 && !mobimenu
      unflag 'show_settings_menu'
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

  def changeTranslation translation
    if parallel_text:edited_version == parallel_text:translation && parallel_text:display
      switchTranslation translation, true
      if parallel_books.find(do |element| return element:bookid == parallel_text:book)
        getParallelText(translation, parallel_text:book, parallel_text:chapter)
      else
        getParallelText(translation, parallel_books[0]:bookid, 1)
        parallel_text:book = parallel_books[0]:bookid
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

  def showChapters bookid
    if bookid != @show_chapters_of
      @show_chapters_of = bookid
    else @show_chapters_of = 0

  def nameOfBook bookid, parallel
    if parallel
      for book in parallel_books
        if book:bookid == bookid
          return book:name
    for book in books
      if book:bookid == bookid
        return book:name

  def chaptersOfCurrentBook parallel
    if parallel == 1
      for book in parallel_books
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
    if settings:font < 64 && window:outerWidth > 480
      settings:font = settings:font + 2
      setCookie('font', settings:font)
    elif settings:font < 42
      settings:font = settings:font + 2
      setCookie('font', settings:font)


  def setLanguage language
    settings:language = language
    switch language
      when 'eng' then @langdata = eng_leng
      when 'ukr' then @langdata = ukr_leng
    setCookie('language', language)
    show_languages = !@show_languages

  def ontouchstart touch
    self

  def ontouchend touch
    if touch.dx > 64 && mobimenu != 'show_settings_menu'
      flag 'show_bible_menu'
      mobimenu = 'show_bible_menu'
      unflag 'show_settings_menu'
    elif touch.dx < -64 && mobimenu != 'show_bible_menu'
      flag 'show_settings_menu'
      mobimenu = 'show_settings_menu'
      unflag 'show_bible_menu'
    elif touch.dx > 64 && mobimenu == 'show_settings_menu'
      mobimenu = ''
      unflag 'show_settings_menu'
    elif touch.dx < -64 && mobimenu == 'show_bible_menu'
      mobimenu = ''
      unflag 'show_bible_menu'
    else
      if touch.x < 210 && mobimenu == 'show_bible_menu'
        return
      elif touch.x > window:outerWidth - 210
        unflag 'show_bible_menu'
        mobimenu = ''
        return
      else
        unflag 'show_settings_menu'
        unflag 'show_bible_menu'
        mobimenu = ''

  def ontouchcancel touch
    unflag 'show_bible_menu'
    unflag 'show_settings_menu'
    mobimenu = ''



  def render
    <self>
      <div.bible-menu>
        if parallel_text:display
          <div.choose_parallel>
            <div.translation_name .current_translation=(parallel_text:edited_version == settings:translation) :tap.prevent.changeEditedParallel(settings:translation)> settings:translation
            <div.translation_name .current_translation=(parallel_text:edited_version == parallel_text:translation) :tap.prevent.changeEditedParallel(parallel_text:translation)> parallel_text:translation
          if parallel_text:edited_version == parallel_text:translation
            <div.book_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations)> parallel_text:edited_version
          else <div.book_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations)> settings:translation
        else <div.book_name :tap.prevent=(do @show_list_of_translations = !@show_list_of_translations)> settings:translation
        <div.translations_list .show_list_of_chapters=@show_list_of_translations>
          for translation in translations
            <div.book_in_list css:font-size="18px" :tap.prevent.changeTranslation(translation:short_name)> translation:full_name
        if parallel_text:edited_version == parallel_text:translation && parallel_text:display
          for book in @parallel_books
            <div.book_in_list :tap.prevent.showChapters(book:bookid)> book:name
            <div.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <div.chapter_number :tap.prevent.getParallelText(parallel_text:translation, book:bookid, i+1)> i+1
        else
          for book in @books
            <div.book_in_list :tap.prevent.showChapters(book:bookid)> book:name
            <div.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <div.chapter_number :tap.prevent.getText(settings:translation, book:bookid, i+1)> i+1
        <div.freespace>

      <div.text .parallel_text=parallel_text:display css:font-size="{settings:font}px">
        <div .first_parallel=parallel_text:display .right_align=(settings:translation=="WLC")>
          <h2> nameOfBook(settings:book, false), ' ', settings:chapter
          <p.text-ident> " "
          if (settings:translation=="WLC")
            for verse in verses
              <span.verse id=verse:fields:verse>
                ' '
                verse:fields:verse
              <span> verse:fields:text
          else for verse in verses
            <span.verse id=verse:fields:verse>
              ' '
              verse:fields:verse
            <span> verse:fields:text
          <div.arrows>
            <button.arrow css:margin-right="auto" :tap.prevent.prewChapter()>
              <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            <button.arrow :tap.prevent.nextChapter()>
              <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

        <div.second_parallel .show_parallel=parallel_text:display .right_align=(parallel_text:translation=="WLC")>
          <h2> nameOfBook(parallel_text:book, true), ' ', parallel_text:chapter
          <p.text-ident> " "
          if (parallel_text:translation=="WLC")
            for verse in @parallel_verses
              <span.verse id=verse:fields:verse>
                ' '
                verse:fields:verse
              <span> verse:fields:text
          else for verse in @parallel_verses
            <span.verse id=verse:fields:verse>
              ' '
              verse:fields:verse
            <span> verse:fields:text
          <div.arrows>
            <button.arrow :tap.prevent.prewChapter('true')>
              <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            <button.arrow :tap.prevent.nextChapter('true')>
              <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

      <div.settings-menu>
        <p.settings_header> langdata:other
        <input[search:search_input].search_btn type='search' placeholder=langdata:search :keydown.enter.getSearchText :keydown.esc=(do search:search_div = false)> "Search"
        <div.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          langdata:theme
          <div.theme_checkbox :tap.prevent.changeTheme>
            <span>
              if settings:theme == "dark"
                <svg:svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="913.059px" height="913.059px" viewBox="0 0 913.059 913.059" style="enable-background:new 0 0 913.059 913.059;" xml:space="preserve">
                  <svg:g>
                    <svg:path d="M789.581,777.485c62.73-62.73,103.652-139.002,122.785-219.406c5.479-23.031-22.826-38.58-39.524-21.799   c-0.205,0.207-0.41,0.412-0.615,0.617c-139.57,139.57-367.531,136.879-503.693-8.072   c-128.37-136.658-126.685-348.817,3.673-483.579c1.644-1.699,3.3-3.378,4.97-5.037c16.744-16.635,1.094-44.811-21.869-39.354   c-79.689,18.938-155.326,59.276-217.75,121.035c-182.518,180.576-183.546,473.345-2.245,655.14   C315.821,958.032,608.883,958.182,789.581,777.485z">
              else
                <svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                  <svg:path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
        <div.font_setting>
          langdata:font
          <div.great_B :tap.prevent.decreaceFontSize> "B-"
          "{settings:font}"
          <div.little_B :tap.prevent.increaceFontSize> "B+"
        <div.nighttheme .theme_checkbox_light=parallel_text:display>
          langdata:parallel
          <div.parallel_checkbox .parallel_checkbox_turned=parallel_text:display :tap.prevent.toggleParallelMode>
            <span>
        <div.nighttheme>
          langdata:language
          <button.change_language :tap.prevent=(do @show_languages = !@show_languages)>
            if settings:language == 'ukr'
              "Українська"
            if settings:language == 'eng'
              "English"
          <div.languages .show_languages=show_languages>
            <button :tap.prevent.setLanguage('ukr')> "Українська"
            <button :tap.prevent.setLanguage('eng')> "English"
        <a.help href="mailto:bpavlisinec@gmail.com"> langdata:help

      <div.search_results .show_search_results=search:search_div>
        <div.search_hat>
          <svg:svg.close_search :tap.prevent=(do search:search_div = false) xmlns="http://www.w3.org/2000/svg" version="1.1" x="0" y="0" viewBox="0 0 20 20" width="20" height="20" space="preserve">
            <svg:line id="line1" x1="0" y1="5" x2="20" y2="5" data-svg-origin="20 5" style="" transform="matrix(1,0,0,1,0,0)">
            <svg:line id="line2" x1="0" y1="15" x2="20" y2="15" data-svg-origin="20 15" style="" transform="matrix(1,0,0,1,0,0)">
          <h2> search:search_result_header
          <svg:svg.filter_search .filter_search_hover=search:show_filters||search:is_filter :tap.prevent=(do search:show_filters = !search:show_filters) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
            <svg:path d="M12 12l8-8V0H0v4l8 8v8l4-4v-4z">
        <div.search_body id="search_body" tabindex="0">
          if search_verses:length
            if search:show_filters
              <div.filters>
                if parallel_text:edited_version == parallel_text:translation && parallel_text:display
                  <div.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @parallel_books
                    <div.book_in_list :tap.prevent.addFilter(book:bookid)> book:name
                else
                  <div.book_in_list :tap.prevent.dropFilter> langdata:drop_filter
                  for book in @books
                    <div.book_in_list :tap.prevent.addFilter(book:bookid)> book:name
            if search:is_filter
              for verse, key in search_verses when verse:fields:book == search:filter
                <a.search_item href="/{verse:fields:translation}/{verse:fields:book}/{verse:fields:chapter}/#{verse:fields:verse}" target="_blank">
                  <div.search_res_verse_text>
                    <span> verse:fields:text
                  <div.search_res_verse_header>
                    <span> nameOfBook(verse:fields:book), ' '
                    <span> verse:fields:chapter, ':'
                    <span> verse:fields:verse
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter = key + 50)> langdata:more_results
                  break
              <div css:padding='12px 0px'>
                langdata:filter_name, ' ', nameOfBook search:filter

            else
              for verse, key in search_verses
                <a.search_item href="/{verse:fields:translation}/{verse:fields:book}/{verse:fields:chapter}/#{verse:fields:verse}" target="_blank">
                  <div.search_res_verse_text>
                    <span> verse:fields:text
                  <div.search_res_verse_header>
                    <span> nameOfBook(verse:fields:book), ' '
                    <span> verse:fields:chapter, ':'
                    <span> verse:fields:verse
                if key > search:counter
                  <button.more_results :tap.prevent=(do search:counter += 50)> langdata:more_results
                  break
          else
            <p> langdata:nothing
            <p> langdata:translation, search:search_result_translation



      <div.online .offline=offline>
        langdata:offline


Imba.mount <App>
