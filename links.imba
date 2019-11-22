
    var D = []
    for translation in translations
      var B
      switch translation:short_name
        when "YLT" then B = YLT
        when "NASB" then B = YLT
        when "KJV" then B = YLT
        when "WLC" then B = WLC
        when "UBIO" then B = UBIO
        when "UKRK" then B = UKRK
        when "LXX" then B = LXX
        when "SYNOD" then B = SYNOD
        when "CUV" then B = CUV
        when "NTGT" then B = NTGT
        when "HOM" then B = HOM
      D.push {translation: translation:short_name, books: B}
    console.log D
    var urls = []
    for translation in D
      for book in translation:books
        for chapter in Array.from(Array(book:chapters).keys())
          urls.push("http://www.bolls.life" + '/' + translation:translation + '/' + book:bookid + '/' + (chapter + 1))
    console.log urls
