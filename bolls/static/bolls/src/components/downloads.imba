import en_leng, uk_leng, ru_leng from "./langdata.imba"

export tag Downloads
  prop ld default: []
  prop link default: false

  def build
    if getCookie('language')
      switch getCookie('language')
        when 'eng' then @ld = en_leng
        when 'ukr' then @ld = uk_leng
        when 'ru' then @ld = ru_leng
    else
      switch window:navigator:language
        when 'uk' then @ld = uk_leng
        when 'ru-RU' then @ld = ru_leng
        else @ld = en_leng

    if window:navigator:platform.slice(0, 5) == "Linux"
      @link = "https://storage.cloud.google.com/bolls-256717.appspot.com/bolls-0.1.1.AppImage"
    elif window:navigator:platform.slice(0, 3) == "Mac"
      @link = "https://storage.cloud.google.com/bolls-256717.appspot.com/bolls-0.1.0.dmg"
    elif window:navigator:platform.slice(0, 3) == "Win"
      @link = "https://storage.cloud.google.com/bolls-256717.appspot.com/Bolls%20Setup%200.1.0.exe"
    console.log @link

  def mount
    let bible = document:getElementsByClassName("Bible")
    if bible[0]
      bible[0]:classList.add("display_none")

  def unmount
    let bible = document:getElementsByClassName("Bible")
    bible[0]:classList.remove("display_none")

  def getCookie c_name
    return window:localStorage.getItem(c_name)

  def toBible
    window:history.back()
    orphanize


  def render
    <self>
      <.collectionsflex css:flex-wrap="wrap" css:cursor="pointer" :tap.prevent.toBible>
        <svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
          <svg:title> @ld:back
          <svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
        <p css:margin="24px" css:font-weight="500"> @ld:back
      <header css:text-align="center">
        <img css:height="128px" css:width="128px" src="/static/light.png" alt="Bolls logo">
        <h1.exhortation> @ld:exhortation
        if @link
          <a#download-bolls href=@link> @ld:download, " Bolls"
      <#downloads-container>
        <a.platform-item href="https://storage.cloud.google.com/bolls-256717.appspot.com/bolls-0.1.0.dmg">
          <svg:svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 49.3 49.2" style="enable-background:new 0 0 49.3 49.2;" xml:space="preserve">
            <svg:title> @ld:download-for, " MacOS"
            <svg:path class="st0" d="M24.6,0C11,0,0,11,0,24.6s11,24.6,24.6,24.6s24.7-11,24.7-24.6S38.2,0,24.6,0z M26.1,9.9c1.1-1.3,3-2.3,4.6-2.3  c0.2,1.8-0.5,3.6-1.6,4.9c-1.1,1.3-2.9,2.3-4.6,2.2C24.2,13,25.1,11.1,26.1,9.9z M34.9,34.7c-1.3,1.9-2.6,3.8-4.7,3.8  c-2.1,0-2.7-1.2-5.1-1.2S22,38.5,20,38.6s-3.6-2-4.9-3.9c-2.7-3.8-4.7-10.9-2-15.6c1.4-2.4,3.8-3.8,6.4-3.9c2,0,3.9,1.4,5.1,1.4  s3.5-1.7,5.9-1.4c1,0,3.8,0.4,5.7,3.1c-0.1,0.1-3.4,2-3.3,5.9c0,4.7,4.1,6.2,4.2,6.3C37,30.4,36.4,32.6,34.9,34.7z">
          <p> @ld:download-for, " MacOS"
        <a.platform-item href="https://storage.cloud.google.com/bolls-256717.appspot.com/Bolls%20Setup%200.1.0.exe">
          <svg:svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 49.2 49.2" style="enable-background:new 0 0 49.2 49.2;" xml:space="preserve">
            <svg:title> @ld:download-for, " Windows"
            <svg:path class="st0" d="M24.6,0C11,0,0,11,0,24.6s11,24.6,24.6,24.6s24.6-11,24.6-24.6S38.2,0,24.6,0z M21.3,36.3l-11.2-1.6v-9.1h11.2  V36.3z M21.3,24H10.1v-9.1l11.2-1.7V24z M37.9,38.7l-15.1-2.2v-11h15.1V38.7z M37.9,24h-15V13l15-2.2V24z">
          <p> @ld:download-for, " Windows"
        <a.platform-item href="https://storage.cloud.google.com/bolls-256717.appspot.com/bolls-0.1.1.AppImage">
          <svg:svg.platforms_svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve">
            <svg:title> @ld:download-for, " Linux"
            <svg:path class="st0" d="M256,512C114.6,512,0,397.4,0,256S114.6,0,256,0s256,114.6,256,256S397.4,512,256,512z M237,128.5  c-119.4,9.6-87.7,135.7-89.5,178c-1.6,22.3-9,49.7-19.5,77.5h32.3c3.3-11.8,5.8-23.4,6.8-34.5c1.9,1.4,4,2.7,6.2,3.9  c3.6,2.1,6.7,5,10,8c7.7,7,16.4,14.9,33.4,15.9c1.1,0.1,2.3,0.1,3.4,0.1c17.2,0,29-7.5,38.5-13.6c4.5-2.9,8.5-5.4,12.1-6.6  c10.5-3.3,19.6-8.6,26.5-15.3c1.1-1.1,2.1-2.1,3-3.2c3.8,14,9,29.7,14.8,45.4h69c-16.5-25.6-33.6-50.6-33.3-82.5  C351.4,238.3,357.9,118.9,237,128.5z M287.7,290.9c-5.5-2.4-10-4-13.6-5.3c2-4,3.3-8.9,3.4-14.3l0,0c0.3-13.1-6.3-23.7-14.7-23.8  c-8.4,0-15.5,10.6-15.8,23.7l0,0c0,0.4,0,0.9,0,1.3c-5.2-2.4-10.3-4.1-15.3-5.2c0-0.5-0.1-1-0.1-1.5l0,0  c-0.5-23.9,14.1-43.6,32.7-44.1c18.5-0.5,34,18.4,34.4,42.3l0,0c0.2,10.8-2.7,20.7-7.6,28.4C290.1,291.9,288.9,291.4,287.7,290.9z   M267.3,298.7c4,1.4,8.6,3,14.7,5.6h0.1c5.7,2.3,12.5,6.6,12.2,13.7c-0.5,10.9-14.7,21.1-27.9,25.3h-0.1c-5.5,1.8-10.4,4.9-15.5,8.2  c-8.7,5.6-17.7,11.3-30.6,11.3c-0.9,0-1.7,0-2.6-0.1c-11.9-0.7-17.4-5.8-24.5-12.2c-3.7-3.4-7.5-6.9-12.5-9.8l-0.1-0.1  c-10.7-6-17.3-13.5-17.7-20c-0.2-3.2,1.2-6.1,4.3-8.4c6.7-5,11.1-8.3,14.1-10.4c3.3-2.4,4.3-3.1,5-3.8c0.5-0.5,1.1-1,1.7-1.6  c6.1-5.9,16.3-15.9,32-15.9c9.6,0,20.2,3.7,31.5,11C256.8,295,261.4,296.6,267.3,298.7z M217.6,320.7c-15.3-1.1-27.5-5.3-32.9-8.9  c-3.3-2.3-7.8-1.4-10.1,1.9s-1.4,7.9,1.9,10.1c8.7,5.9,24,10.2,40,11.4c2.7,0.2,5.7,0.3,8.9,0.3c13.9,0,31.7-1.3,50.6-10.1  c3.6-1.7,5.2-6,3.5-9.7c-1.7-3.6-6-5.2-9.7-3.5C249.4,321.7,230.4,321.6,217.6,320.7z M196,271.5L196,271.5  c-1.1-11.7-7.4-20.6-14-19.7c-6.6,0.8-11,10.9-9.8,22.6c0.5,5.1,2,9.7,4,13.1c-0.5,0.4-1.9,1.5-3.6,2.7c-1.3,0.9-2.8,2-4.6,3.4  c-5-6.5-8.4-15.9-9-26.5l0,0c-1.2-20.6,8.7-38,22-38.7c13.4-0.8,25.1,15.3,26.3,35.9l0,0c0.1,1.1,0.1,2.2,0.1,3.3  c-4.2,1.1-8,2.6-11.5,4.4C196,271.8,196,271.7,196,271.5z">
          <p> @ld:download-for, " Linux"
        <a.platform-item href="https://snapcraft.io/bolls">
          <svg:svg.platforms_svg id="svg3957" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://www.w3.org/2000/svg" height="64.558mm" width="64.558mm" version="1.1" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" viewBox="0 0 244 244.00001">
            <svg:title> @ld:snapstore
            <svg:g id="Page-1" fill="none" transform="scale(5.5455)">
              <svg:g id="snapcraft-primary-icon--dark">
              <svg:circle id="Oval" cy="22" cx="22" r="22" fill="#252525">
              <svg:g id="snapcraft-logo--web" transform="translate(7,8)">
                <svg:path id="Combined-Shape" fill="#82bfa1" d="m18.06 7.28 6.92 3.08-6.92 6.92zm-13.22 23.22l8.49-15.92 3.73 3.7zm-4.84-30 17.47 6.32v11.05z">
                <svg:polygon id="Shape" points="28.53 6.82 18.46 6.82 31.4 12.57" fill="#fa6340">
          <p> @ld:snapstore
      <.freespace>