import YLT, WLC, UBIO, UKRK, LXX, SYNOD, CUV, NTG, AB, NASB, translations from "./translations_data.imba"

let settings = {
  theme: 'dark',
  translation: 'YLT',
  book: 1,
  chapter: 1,
  font: 24,
}

let search = {
  search_input: '',
  search_result_header: '',
  search_div: false,
  counter: 50
}

let paralel_text = {
  display: false,
  translation: 'YLT',
  book: 1,
  chapter: 1,
  edited_version: 'YLT',
}

tag App
  prop verses
  prop search_verses
  prop paralel_verses
  prop paralel_books
  prop books
  prop show_chapters_of
  prop show_list_of_translations
  prop highlighted_verse

  def build
    if window:preloaded_text
      @verses = window:preloaded_text
      @highlighted_verse = window:highlighted_verse
      console.log @highlighted_verse
      switch window:preloaded_text[0]:fields:translation
        when "YLT" then @books = YLT
        when "NASB" then @books = NASB
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTG" then @books = NTG
        when "AB" then @books = AB
      settings:translation = window:preloaded_text[0]:fields:translation
      settings:book = window:preloaded_text[0]:fields:book
      settings:chapter = window:preloaded_text[0]:fields:chapter
      setCookie('translation', settings:translation)
      setCookie('book', settings:book)
      setCookie('chapter', settings:chapter)
    else
      if getCookie('translation')
        settings:translation = getCookie('translation')
      if getCookie('book')
        settings:book = parseInt(getCookie('book'))
      if getCookie('chapter')
        settings:chapter = parseInt(getCookie('chapter'))
      @verses = getText(settings:translation, settings:book, settings:chapter, false)
      switch settings:translation
        when "YLT" then @books = YLT
        when "NASB" then @books = NASB
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTG" then @books = NTG
        when "AB" then @books = AB
    if getCookie('theme')
      settings:theme = getCookie('theme')
      let html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    if getCookie('font')
      settings:font = parseInt(getCookie('font'))
    if getCookie('paralel_display')
      if getCookie('paralel_display') == 'true'
        toggleParalelMode
    @search_verses = {}
    @show_chapters_of = 0
    @show_list_of_translations = 0


  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def setCookie c_name, value, expiredays
    return window:localStorage.setItem(c_name, value)

  def load url
    var res = await window.fetch(url)
    .then( do |result| result.json())
    .then( do |json| return json)

  def getText translation, book, chapter, paralel
    if paralel_text:edited_version == paralel_text:translation && paralel_text:display && paralel
      getParalelText translation, book, chapter
    else
      settings:book = book
      settings:chapter = chapter
      let url = "http://127.0.0.1:8000/get-text/" + translation + '/' + book + '/' + chapter + '/'
      @verses = {}
      @verses = JSON.parse(await load url)
      search:search_div = false
      Imba.commit
      setCookie('book', book)
      setCookie('chapter', chapter)

  def getParalelText translation, book, chapter
    paralel_text:translation = translation
    paralel_text:edited_version = translation
    paralel_text:book = book
    paralel_text:chapter = chapter
    let url = "http://127.0.0.1:8000/get-text/" + translation + '/' + book + '/' + chapter + '/'
    @paralel_verses = {}
    @paralel_verses = JSON.parse(await load url)
    switch paralel_text:translation
      when "YLT" then @paralel_books = YLT
      when "NASB" then @paralel_books = NASB
      when "WLC" then @paralel_books = WLC
      when "UBIO" then @paralel_books = UBIO
      when "UKRK" then @paralel_books = UKRK
      when "LXX" then @paralel_books = LXX
      when "SYNOD" then @paralel_books = SYNOD
      when "CUV" then @paralel_books = CUV
      when "NTG" then @paralel_books = NTG
      when "AB" then @paralel_books = AB
    Imba.commit
    setCookie('translation', settings:translation)
    setCookie('paralel_translation', translation)
    setCookie('paralel_book', book)
    setCookie('paralel_chapter', chapter)

  def toggleParalelMode
    if paralel_text:display
      paralel_text:display = false
    else
      if getCookie('paralel_translation')
        paralel_text:translation = getCookie('paralel_translation')
      if getCookie('paralel_book')
        paralel_text:book = parseInt(getCookie('paralel_book'))
      if getCookie('paralel_chapter')
        paralel_text:chapter = parseInt(getCookie('paralel_chapter'))
      getParalelText(paralel_text:translation, paralel_text:book, paralel_text:chapter)
      paralel_text:display = true
    setCookie('paralel_display', paralel_text:display)

  def changeEditedParalel translation
    paralel_text:edited_version = translation

  def getSearchText
    let url = "http://127.0.0.1:8000/" + settings:translation + '/' + search:search_input + '/'
    @search_verses = {}
    @search_verses = JSON.parse(await load url)
    search:search_result_header = search:search_input
    search:search_div = true
    search:counter = 50
    Imba.commit

  def changeTranslation translation
    if paralel_text:edited_version == paralel_text:translation && paralel_text:display
      switch translation
        when "YLT" then @paralel_books = YLT
        when "NASB" then @paralel_books = NASB
        when "WLC" then @paralel_books = WLC
        when "UBIO" then @paralel_books = UBIO
        when "UKRK" then @paralel_books = UKRK
        when "LXX" then @paralel_books = LXX
        when "SYNOD" then @paralel_books = SYNOD
        when "CUV" then @paralel_books = CUV
        when "NTG" then @paralel_books = NTG
        when "AB" then @paralel_books = AB
      if paralel_books.find(do |element| return element:bookid == paralel_text:book)
        getText(translation, paralel_text:book, paralel_text:chapter, true)
      else
        getText(translation, paralel_books[0]:bookid, 1, true)
        paralel_text:book = paralel_books[0]:bookid
        paralel_text:chapter = 1
      paralel_text:translation = translation
      setCookie('translation', translation)
    else
      switch translation
        when "YLT" then @books = YLT
        when "NASB" then @books = NASB
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTG" then @books = NTG
        when "AB" then @books = AB
      if books.find(do |element| return element:bookid == settings:book)
        getText(translation, settings:book, settings:chapter, false)
      else
        getText(translation, books[0]:bookid, 1, false)
        settings:book = books[0]:bookid
        settings:chapter = 1
      settings:translation = translation
      setCookie('translation', translation)

  def show_chapters bookid
    if bookid != @show_chapters_of
      @show_chapters_of = bookid
    else @show_chapters_of = 0

  def nameOfBook bookid, paralel
    if paralel
      for book in paralel_books
        if book:bookid == bookid
          return book:name
    for book in books
      if book:bookid == bookid
        return book:name

  def chaptersOfCurrentBook paralel
    if paralel == 1
      for book in paralel_books
        if book:bookid == paralel_text:book
          return book:chapters
    else
      for book in books
        if book:bookid == settings:book
          return book:chapters

  def nextChapter paralel
    if paralel == 'true'
      if paralel_text:chapter + 1 <= chaptersOfCurrentBook paralel
        console.log paralel_text:chapter + 1, paralel_text:chapter
        getParalelText(paralel_text:translation, paralel_text:book, paralel_text:chapter + 1)
      else
        let current_index = @paralel_books.indexOf(@paralel_books.find(do |element| return element:bookid == paralel_text:book))
        if @paralel_books[current_index + 1]
          getParalelText(paralel_text:translation, @paralel_books[current_index+1]:bookid, 1)

    else
      if settings:chapter + 1 <= chaptersOfCurrentBook paralel
        console.log settings:chapter + 1, settings:chapter
        getText(settings:translation, settings:book, settings:chapter + 1, false)
      else
        let current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index + 1]
          getText(settings:translation, books[current_index+1]:bookid, 1, false)

  def prewChapter paralel
    if paralel == 'true'
      if paralel_text:chapter - 1 > 0
        getParalelText(paralel_text:translation, paralel_text:book, paralel_text:chapter - 1)
      else
        let current_index = @paralel_books.indexOf(@paralel_books.find(do |element| return element:bookid == paralel_text:book))
        if @paralel_books[current_index - 1]
          getParalelText(paralel_text:translation, @paralel_books[current_index - 1]:bookid, @paralel_books[current_index - 1]:chapters)

    else
      if settings:chapter - 1 > 0
        getText(settings:translation, settings:book, settings:chapter - 1, false)
      else
        let current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
        if books[current_index - 1]
          getText(settings:translation, books[current_index - 1]:bookid, books[current_index - 1]:chapters, false)

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
      settings:font -= 3
      setCookie('font', settings:font)

  def increaceFontSize
    if settings:font < 82
      settings:font = settings:font + 3
      setCookie('font', settings:font)


  def render
    <self>
      <div.bible-menu>
        if paralel_text:display
          <div.choose_paralel>
            <div.translation_name .current_translation=(paralel_text:edited_version == settings:translation) :tap.changeEditedParalel(settings:translation)> settings:translation
            <div.translation_name .current_translation=(paralel_text:edited_version == paralel_text:translation) :tap.changeEditedParalel(paralel_text:translation)> paralel_text:translation
          if paralel_text:edited_version == paralel_text:translation
            <div.book_name :tap=(do @show_list_of_translations = !@show_list_of_translations)> paralel_text:edited_version
          else <div.book_name :tap=(do @show_list_of_translations = !@show_list_of_translations)> settings:translation
        else <div.book_name :tap=(do @show_list_of_translations = !@show_list_of_translations)> settings:translation
        <div.translations_list .show_list_of_chapters=@show_list_of_translations>
          for translation in translations
            <div.book_in_list style="font-size: 18px;" :tap.changeTranslation(translation:short_name)> translation:full_name
        if paralel_text:edited_version == paralel_text:translation && paralel_text:display
          for book in @paralel_books
            <div.book_in_list :tap.show_chapters(book:bookid)> book:name
            <div.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <div.chapter_number :tap.getText(paralel_text:translation, book:bookid, i+1, true)> i+1
        else
          for book in @books
            <div.book_in_list :tap.show_chapters(book:bookid)> book:name
            <div.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
              for i in Array.from(Array(book:chapters).keys())
                <div.chapter_number :tap.getText(settings:translation, book:bookid, i+1, false)> i+1
        <div.freespace>

      <div.text .paralel_text=paralel_text:display style="font-size: {settings:font}px">
        <div .first_paralel=paralel_text:display .right_align=(settings:translation=="WLC" || settings:translation=="AB")>
          <h2> nameOfBook(settings:book, false), ' ', settings:chapter
          <p.text-ident> " "
          if (settings:translation=="WLC" || settings:translation=="AB")
            for verse in verses
              <span.verse id=verse:fields:verse> verse:fields:verse
              <span> verse:fields:text
          else for verse in verses
            <span.verse id=verse:fields:verse> verse:fields:verse
            <span> verse:fields:text
          <div.arrows>
            <button.arrow :tap.prewChapter()>
              <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            <button.arrow :tap.nextChapter()>
              <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

        <div.second_paralel .show_paralel=paralel_text:display .right_align=(paralel_text:translation=="WLC" || paralel_text:translation=="AB")>
          <h2> nameOfBook(paralel_text:book, true), ' ', paralel_text:chapter
          <p.text-ident> " "
          if (paralel_text:translation=="WLC" || paralel_text:translation=="AB")
            for verse in @paralel_verses
              <span.verse id=verse:fields:verse> verse:fields:verse
              <span> verse:fields:text
          else for verse in @paralel_verses
            <span.verse id=verse:fields:verse> verse:fields:verse
            <span> verse:fields:text
          <div.arrows>
            <button.arrow :tap.prewChapter('true')>
              <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
            <button.arrow :tap.nextChapter('true')>
              <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
                <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

      <div.settings-menu>
        <p.settings_header> "Other"
        <input[search:search_input].search_btn type='text' placeholder='Search' :keydown.enter.getSearchText :keydown.esc=(do search:search_div = false)> "Search"
        <div.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          "Light theme"
          <div.theme_checkbox :tap.changeTheme>
            <span>
              if settings:theme == "dark"
                <svg:svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="913.059px" height="913.059px" viewBox="0 0 913.059 913.059" style="enable-background:new 0 0 913.059 913.059;" xml:space="preserve">
                  <svg:g>
                    <svg:path d="M789.581,777.485c62.73-62.73,103.652-139.002,122.785-219.406c5.479-23.031-22.826-38.58-39.524-21.799   c-0.205,0.207-0.41,0.412-0.615,0.617c-139.57,139.57-367.531,136.879-503.693-8.072   c-128.37-136.658-126.685-348.817,3.673-483.579c1.644-1.699,3.3-3.378,4.97-5.037c16.744-16.635,1.094-44.811-21.869-39.354   c-79.689,18.938-155.326,59.276-217.75,121.035c-182.518,180.576-183.546,473.345-2.245,655.14   C315.821,958.032,608.883,958.182,789.581,777.485z">
              else
                <svg:svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                  <svg:path d="M10 14a4 4 0 1 1 0-8 4 4 0 0 1 0 8zM9 1a1 1 0 1 1 2 0v2a1 1 0 1 1-2 0V1zm6.65 1.94a1 1 0 1 1 1.41 1.41l-1.4 1.4a1 1 0 1 1-1.41-1.41l1.4-1.4zM18.99 9a1 1 0 1 1 0 2h-1.98a1 1 0 1 1 0-2h1.98zm-1.93 6.65a1 1 0 1 1-1.41 1.41l-1.4-1.4a1 1 0 1 1 1.41-1.41l1.4 1.4zM11 18.99a1 1 0 1 1-2 0v-1.98a1 1 0 1 1 2 0v1.98zm-6.65-1.93a1 1 0 1 1-1.41-1.41l1.4-1.4a1 1 0 1 1 1.41 1.41l-1.4 1.4zM1.01 11a1 1 0 1 1 0-2h1.98a1 1 0 1 1 0 2H1.01zm1.93-6.65a1 1 0 1 1 1.41-1.41l1.4 1.4a1 1 0 1 1-1.41 1.41l-1.4-1.4z">
        <div.font_setting>
          "Font size: "
          <div.great_B :tap.decreaceFontSize> "B-"
          "{settings:font}"
          <div.little_B :tap.increaceFontSize> "B+"
        <div.nighttheme .theme_checkbox_light=paralel_text:display>
          "Paralel view"
          <div.paralel_checkbox .paralel_checkbox_turned=paralel_text:display :tap.toggleParalelMode>
            <span>

      <div.search_results .show_search_results=search:search_div>
        <div.search_hat>
          <svg:svg.close_search :tap=(do search:search_div = false) id="burger-icon" xmlns="http://www.w3.org/2000/svg" version="1.1" x="0" y="0" viewBox="0 0 20 20" width="20" height="20" space="preserve">
            <svg:line id="line1" x1="0" y1="5" x2="20" y2="5" data-svg-origin="20 5" style="" transform="matrix(1,0,0,1,0,0)">
            <svg:line id="line2" x1="0" y1="15" x2="20" y2="15" data-svg-origin="20 15" style="" transform="matrix(1,0,0,1,0,0)">
          <h2> search:search_result_header
        <div.search_body>
          if search_verses:length
            for verse, key in search_verses
              <span>
              <a.search_item href="/{verse:fields:translation}/{verse:fields:book}/{verse:fields:chapter}/#{verse:fields:verse}" target="_blank">
                <div.search_res_verse_text>
                  <span> verse:fields:text
                <div.search_res_verse_header>
                  <span> nameOfBook(verse:fields:book)
                  ' '
                  <span> verse:fields:chapter
                  ':'
                  <span> verse:fields:verse
              if key > search:counter
                <button.more_results :tap=(do search:counter += 50)> "More results"
                break
          else
            <div> "We do not find anything. Verify your translation or simplify your query. Also note that the search is case sensitive so that 'God' and 'god' and 'GOD' are complitly different queries!"

Imba.mount <App>
