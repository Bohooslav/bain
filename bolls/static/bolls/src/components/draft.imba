if tr[0]:text
    <li.search_item draggable="true" :ondragover.dragOver() :ondragstart.dragStart() :ondragend.dragEnd() id="compare_{tr[0]:translation}">
        <.search_res_verse_text>
            for aoefv in tr
                <search-text-as-html[aoefv]>
                ' '
        <.search_res_verse_header>
            <svg:svg.open_in_parallel :click.prevent.changeOrder(key, -1) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <svg:title> @data.lang:move_up
                <svg:path d="M10.707 7.05L10 6.343 4.343 12l1.414 1.414L10 9.172l4.243 4.242L15.657 12z">
            <svg:svg.open_in_parallel :click.prevent.changeOrder(key, 1) style="margin-right: auto;" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
                <svg:title> @data.lang:move_down
                <svg:path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z">
            <span> tr[0]:translation
            <svg:svg.open_in_parallel :click.prevent.copyToClipboardFromParallel(tr) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 561 561" alt=@data.lang:copy>
                <svg:title> @data.lang:copy
                <svg:path d=svg_paths:copy>
            <svg:svg.open_in_parallel style="margin: 0 8px;" viewBox="0 0 400 338" :click.prevent.backInHistory({translation: tr[0]:translation, book: tr[0]:book, chapter: tr[0]:chapter,verse: tr[0]:verse}, yes)>
                <svg:title> @data.lang:open_in_parallel
                <svg:path d=svg_paths:columnssvg style="fill:inherit;fill-rule:evenodd;stroke:none;stroke-width:1.81818187">
            <svg:svg.remove_parallel.close_search :click.prevent.addTranslation({short_name: tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=@data.lang:delete>
                <svg:title> @data.lang:delete
                <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=@data.lang:delete>
else
    <li draggable="true" :ondragover.dragOver() :ondragstart.dragStart() :ondragend.dragEnd() id="compare_{tr[0]:translation}" style="padding: 16px 0;display: flex; align-items: center;">
        @data.lang:the_verse_is_not_available, tr[0]:translation, tr[0]:text
        <svg:svg.remove_parallel.close_search style="margin: -8px 8px 0 auto;" :click.prevent.addTranslation({short_name: tr[0]:translation}) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" alt=@data.lang:delete>
            <svg:title> @data.lang:delete
            <svg:path d="M10 8.586L2.929 1.515 1.515 2.929 8.586 10l-7.071 7.071 1.414 1.414L10 11.414l7.071 7.071 1.414-1.414L11.414 10l7.071-7.071-1.414-1.414L10 8.586z" alt=@data.lang:delete>
