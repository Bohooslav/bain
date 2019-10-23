let choosen = []
let choosen_text = []


  def getChoosenVerse verse
    let url = "http://127.0.0.1:8000/get-verse/" + settings:book + '/' + settings:chapter + '/' + verse + '/'
    choosen_text.push JSON.parse(await load url)
    Imba.commit

  def addToChoosen id
    if choosen.find(do |element| return element == id)
      choosen.splice(choosen.indexOf(id), 1)
    else
      choosen.push id


              # <span .clicked=choosen.find(do |element| return element == verse:fields:verse) :tap.prevent.addToChoosen(verse:fields:verse)> verse:fields:text

            # <span .clicked=choosen.find(do |element| return element == verse:fields:verse) :tap.prevent.addToChoosen(verse:fields:verse)> verse:fields:text


      <div.hide .choosen_verses=choosen:length>
        <svg:svg.close_search :tap.prevent=(do choosen = [] and choosen_text = []) xmlns="http://www.w3.org/2000/svg" version="1.1" x="0" y="0" viewBox="0 0 20 20" width="20" height="20" space="preserve">
          <svg:line id="line1" x1="0" y1="5" x2="20" y2="5" data-svg-origin="20 5" style="" transform="matrix(1,0,0,1,0,0)">
          <svg:line id="line2" x1="0" y1="15" x2="20" y2="15" data-svg-origin="20 15" style="" transform="matrix(1,0,0,1,0,0)">
        nameOfBook settings:book, ' '
        settings:chapter, ':'
        for id, key in choosen.sort(do |a, b| return a > b)
          if id == choosen[key - 1] + 1
            if id == choosen[key+1] - 1
              continue
            else
              '-'
              id
          else
            if !key
              id
            else
              ','
              id


            <div.parallel_verses>
              for obj, key in choosen_text
                for verse in obj
                  <span.verse id=verse:fields:verse>
                    ' ', verse:fields:verse
                  <span .clicked=choosen.find(do |element| return element == verse:fields:verse) :tap.prevent.addToChoosen(verse:fields:verse)> verse:fields:text