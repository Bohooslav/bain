const dataUrl = "https://bolls-256717.appspot.com/"


  def getChoosenVerse verse
    let url = "http://127.0.0.1:8000/get-verse/" + settings:book + '/' + settings:chapter + '/' + verse + '/'
    choosen_text.push JSON.parse(await load url)
    Imba.commit

  def render
    <self>
      <div.parallel_verses>
        for obj, key in choosen_text
          for verse in obj
            <span.verse id=verse:fields:verse>
              ' ', verse:fields:verse
            <span .clicked=choosen.find(do |element| return element == verse:fields:verse) :tap.prevent.addToChoosen(verse:fields:verse)> verse:fields:text
