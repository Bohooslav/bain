import YLT, WLC, UBIO, UKRK, LXX, SYNOD, CUV, NTG, AB, translations from "./translations_data.imba"

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

tag App
  prop verses
  prop search_verses
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
        settings:book = getCookie('book')
      if getCookie('chapter')
        settings:chapter = getCookie('chapter')
      @verses = getText(settings:translation, settings:book, settings:chapter)
      switch settings:translation
        when "YLT" then @books = YLT
        when "WLC" then @books = WLC
        when "UBIO" then @books = UBIO
        when "UKRK" then @books = UKRK
        when "LXX" then @books = LXX
        when "SYNOD" then @books = SYNOD
        when "CUV" then @books = CUV
        when "NTG" then @books = NTG
        when "AB" then @books = AB
    @show_chapters_of = 0
    @show_list_of_translations = 0
    @search_verses = {}
    if getCookie('theme')
      settings:theme = getCookie('theme')
      let html = document.querySelector('#html')
      html:dataset:theme = settings:theme
    if getCookie('font')
      settings:font = getCookie('font')


  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def setCookie c_name, value, expiredays
    return window:localStorage.setItem(c_name, value)

  def load url
    var res = await window.fetch(url)
    .then( do |result| result.json())
    .then( do |json| return json)

  def getText translation, book, chapter
    settings:book = book
    settings:chapter = chapter
    let url = "http://127.0.0.1:8000/get-text/" + translation + '/' + book + '/' + chapter + '/'
    @verses = {}
    @verses = JSON.parse(await load url)
    search:search_div = false
    Imba.commit
    setCookie('book', book)
    setCookie('chapter', chapter)

  def getSearchText
    let url = "http://127.0.0.1:8000/" + settings:translation + '/' + search:search_input + '/'
    @search_verses = {}
    @search_verses = JSON.parse(await load url)
    search:search_result_header = search:search_input
    search:search_div = true
    search:counter = 50
    Imba.commit

  def changeTranslation translation
    switch translation
      when "YLT" then @books = YLT
      when "WLC" then @books = WLC
      when "UBIO" then @books = UBIO
      when "UKRK" then @books = UKRK
      when "LXX" then @books = LXX
      when "SYNOD" then @books = SYNOD
      when "CUV" then @books = CUV
      when "NTG" then @books = NTG
      when "AB" then @books = AB

    if books.find(do |element| return element:bookid == settings:book)
      getText(translation, settings:book, settings:chapter)
    else
      getText(translation, books[0]:bookid, 1)
      settings:book = books[0]:bookid
      settings:chapter = 1
    settings:translation = translation
    setCookie('translation', translation)

  def show_chapters bookid
    if bookid != @show_chapters_of
      @show_chapters_of = bookid
    else @show_chapters_of = 0

  def showListOfTranslations
    @show_list_of_translations = !@show_list_of_translations

  def nameOfBook bookid
    for book in books
      if book:bookid == bookid
        return book:name

  def chaptersOfCurrentBook
    for book in books
      if book:bookid == settings:book
        return book:chapters

  def nextChapter
    if settings:chapter + 1 <= chaptersOfCurrentBook
      getText(settings:translation, settings:book, settings:chapter + 1)
    else
      let current_index = books.indexOf(books.find(do |element| return element:bookid == settings:book))
      if books[current_index + 1]
        getText(settings:translation, books[current_index+1]:bookid, 1)

  def prewChapter
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
      settings:font -= 3
      setCookie('font', settings:font)

  def increaceFontSize
    if settings:font < 82
      settings:font = parseInt(settings:font) + 3
      setCookie('font', settings:font)

  def closeSearch
    search:search_div = !search:search_div

  def more_search_verses
    search:counter += 50


  def render
    <self :keydown.esc.closeSearch>
      <div.bible-menu>
        <div.book_name :tap.showListOfTranslations> settings:translation
        <div.translations_list .show_list_of_chapters=@show_list_of_translations>
          for translation in translations
            <div.book_in_list style="font-size: 18px;" :tap.changeTranslation(translation:short_name)> translation:full_name
        for book in books
          <div.book_in_list :tap.show_chapters(book:bookid)> book:name
          <div.list_of_chapters .show_list_of_chapters=(book:bookid==show_chapters_of)>
            for i in Array.from(Array(book:chapters).keys())
              <div.chapter_number :tap.getText(settings:translation, book:bookid, i+1)> i+1
        <div.freespace>

      <div.text .right_align=(settings:translation=="WLC" || settings:translation=="AB") style="font-size: {settings:font}px">
        <h2> nameOfBook(settings:book), ' ', settings:chapter
        <p.text-ident> " "
        if (settings:translation=="WLC" || settings:translation=="AB")
          for verse in verses
            <span.verse id=verse:fields:verse> verse:fields:verse
            <span> verse:fields:text
        else for verse in verses
          <span.verse id=verse:fields:verse> verse:fields:verse
          <span> verse:fields:text
      <div.arrows>
        <button.arrow :tap.prewChapter>
          <svg:svg.arrow_prew xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
            <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">
        <button.arrow :tap.nextChapter>
          <svg:svg.arrow_next xmlns="http://www.w3.org/2000/svg" width="8" height="5" viewBox="0 0 8 5">
            <svg:polygon points="4,3 1,0 0,1 4,5 8,1 7,0">

      <div.settings-menu>
        <p.settings_header> "Other"
        <input[search:search_input].search_btn type='text' placeholder='Search' :keydown.enter.getSearchText> "Search"
        <div.nighttheme .theme_checkbox_light=(settings:theme=="light")>
          "Light theme"
          <div.theme_checkbox :tap.changeTheme>
            <p>
        <div.font_setting>
          "Font size: "
          <div.great_B :tap.decreaceFontSize> "B-"
          "{settings:font}"
          <div.little_B :tap.increaceFontSize> "B+"

      <div.search_results .show_search_results=search:search_div>
        <div.search_hat>
          <svg:svg.close_search :tap.closeSearch id="burger-icon" xmlns="http://www.w3.org/2000/svg" version="1.1" x="0" y="0" viewBox="0 0 20 20" width="20" height="20" space="preserve">
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
                <button.more_results :tap.more_search_verses> "More results"
                break
          else
            <div> "We do not find anything. Verify your translation or simplify your query. Also note that the search is case sensitive so that 'God' and 'god' and 'GOD' are complitly different queries!"

Imba.mount <App>
