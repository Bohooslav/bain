import "./translations.json" as translations
import en_leng, uk_leng, ru_leng from "./langdata.imba"
let Dexie = require 'dexie'
Dexie = Dexie:default

export class State
	prop downloaded_translations
	prop can_work_with_db
	prop db
	prop downloading_of_this_translations
	prop deleting_of_all_transllations
	prop show_languages
	prop language
	prop lang
	prop notification

	def initialize
		@can_work_with_db = yes
		@downloaded_translations = []
		@downloading_of_this_translations = []
		@deleting_of_all_transllations = no
		@show_languages = no
		if getCookie('language')
			setLanguage(getCookie('language'))
		else
			switch window:navigator:language.slice(0, 2)
				when 'uk'
					@language = 'ukr'
					document:lastChild:lang = "uk"
					if !window:translation
						setCookie('translation', 'HOM')
				when 'ru'
					@language = 'ru'
					document:lastChild:lang = "ru-RU"
					if !window:translation
						setCookie('translation', 'SYNOD')
				when 'pt'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'ARA')
				when 'no'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'DNB')
				when 'de'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'SCH')
				when 'he'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'WLCC')
				when 'zh'
					@language = 'eng'
					document:lastChild:lang = "en"
					if !window:translation
						setCookie('translation', 'CUV')
				else
					@language = 'eng'
					document:lastChild:lang = "en"
			setLanguage(@language)
		@db = Dexie.new('versesdb')
		@db.version(1).stores({
			verses: '&pk, translation, [translation+book+chapter], [translation+book+chapter+verse]',
			bookmarks: '&verse, *notes'
		})
		checkDownloadedTranslations()
		checkSavedBookmarks()

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

	def getCookie c_name
		return window:localStorage.getItem(c_name)

	def setCookie c_name, value
		return window:localStorage.setItem(c_name, value)

	def loadData url
		var res = await window.fetch url
		return res.json

	def checkDownloadedTranslations
		@downloaded_translations = JSON.parse(getCookie('downloaded_translations')) || []
		let checked_translations = await Promise.all(
			translations.map(
				do |translation|
					@db.transaction('r', @db:verses, do
						const data = await @db:verses.get({translation: translation:short_name})
						return data:translation
					).catch(do |e|
						return null
					)
			)
		)
		@downloaded_translations = checked_translations.filter(do |item| return item != null)
		setCookie('downloaded_translations', JSON.stringify(@downloaded_translations))

	def checkSavedBookmarks
		@db.transaction('rw', @db:bookmarks, do
			const stored_bookmarks_count = await @db:bookmarks.count()
			if stored_bookmarks_count > 0 &&  window:navigator:onLine
				const bookmarks_in_offline = await @db:bookmarks.toArray()
				let verses = [], bookmarks = [], date = bookmarks_in_offline[0]:date, color = bookmarks_in_offline[0]:color
				let notes = ''
				for category, key in bookmarks_in_offline[0]:notes
					notes += category
					if key + 1 < bookmarks_in_offline[0]:notes:length
						notes += " | "
				for bookmark in bookmarks_in_offline
					if bookmark:date == date
						verses.push(bookmark:verse)
					else
						bookmarks.push({
							verses: verses,
							date: date,
							color: color,
							notes: notes
						})
						verses = [bookmark:verse]
						date = bookmark:date
						color = bookmark:color
						for category, key in bookmark:notes
							notes += category
							if key + 1 < bookmark:notes:length
								notes += " | "
					if bookmark == bookmarks_in_offline[bookmarks_in_offline:length - 1]
						bookmarks.push({
							verses: verses,
							date: date,
							color: color,
							notes: notes
						})
				bookmarks.map(do |bookmark|
					window.fetch("/save-bookmarks/", {
						method: "POST",
						cache: "no-cache",
						headers: {
							'X-CSRFToken': get_cookie('csrftoken'),
							"Content-Type": "application/json"
						},
						body: JSON.stringify({
							verses: JSON.stringify(bookmark:verses),
							color: bookmark:color,
							date: bookmark:date,
							notes: bookmark:notes
						}),
					})
					.then(do |response| response.json())
					.then(do |data| console.log data)
					.catch(do |e| console.log(e))
				)
				@db.transaction('rw', @db:bookmarks, do
					@db:bookmarks.clear()
				)
		).catch(do |e|
			@can_work_with_db = no
			console.log('Uh oh : ' + e)
		)

	def downloadTranslation translation
		if (!@downloaded_translations.find(do |element| return element == translation) && window:navigator:onLine)
			@downloading_of_this_translations.push(translation)
			Imba.commit
			let begtime = Date.now()
			let url = '/get-translation/' + translation + '/'
			const array_of_verses = await loadData(url)
			console.log("Translation is downloaded. Time: ", (Date.now() - begtime) / 1000, "s")
			@db.transaction("rw", @db:verses, do
				await @db:verses.bulkPut(array_of_verses)
				@downloaded_translations.push(translation)
				@downloading_of_this_translations.splice(@downloading_of_this_translations.indexOf(@downloading_of_this_translations.find(do |element| return element == translation)), 1)
				console.log("Translation is saved. Time: ", (Date.now() - begtime) / 1000, "s")
				Imba.commit
			).catch (do |e|
				console.error(e:stack)
			)

	def deleteTranslation translation
		@downloading_of_this_translations.push(translation)
		Imba.commit
		let begtime = Date.now()
		@db.transaction("rw", @db:verses, do
			@db:verses.where({translation: translation}).delete().then(do |deleteCount|
				console.log( "Deleted ", deleteCount, " objects. Time: ", (Date.now() - begtime) / 1000)
				@downloaded_translations.splice(@downloaded_translations.indexOf(@downloaded_translations.find(do |element| return element === translation)), 1)
				@downloading_of_this_translations.splice(@downloading_of_this_translations.indexOf(@downloading_of_this_translations.find(do |element| return element == translation)), 1)
				Imba.commit
			)
		).catch(do |e|
			console.log e
		)

	def deleteBookmark pks
		let begtime = Date.now()
		@db.transaction("rw", @db:bookmarks, do
			const res = await Promise.all(pks.map(do |pk|
				console.log(pk)
				@db:bookmarks.where({verse: pk}).delete().then(do |deleteCount|
					console.log( "Deleted ", deleteCount, " objects. Time: ", (Date.now() - begtime) / 1000)
				)
			))
		).catch(do |e|
			console.log e
		)

	def clearVersesTable
		@deleting_of_all_transllations = yes
		Imba.commit
		@db.transaction("rw", @db:verses, do
			await @db:verses.clear()
			@downloaded_translations = []
			@downloading_of_this_translations = []
			@deleting_of_all_transllations = no
			Imba.commit
		).catch(do |e|
			console.log e
		)

	def saveBookmarksToStorageUntillOnline bookmarkobj
		let bookmarks_array = []
		for verse in bookmarkobj:verses
			bookmarks_array.push({
				verse: verse,
				date: bookmarkobj:date,
				color: bookmarkobj:color,
				notes: bookmarkobj:notes
			})
		@db.transaction("rw", @db:bookmarks, do
			await @db:bookmarks.bulkPut(bookmarks_array)
		).catch (do |e|
			console.error(e)
		)

	def getBookmarksFromStorage bookmarks_array
		@db.transaction("r", @db:bookmarks, do
			let some_array = await Promise.all(
				bookmarks_array.map(do |versepk|
					await @db:bookmarks.get(versepk)
				)
			)
			return some_array.filter(do |item| return item != undefined)
		).catch (do |e|
			console.error(e)
		)

	def getChapterFromDB translation, book, chapter, verse
		@db.transaction("r", @db:verses, do
			let data = await @db:verses.where({translation: translation, book: book, chapter: chapter}).toArray()
			if data:length
				data.sort(do |a, b| return a:verse - b:verse)
				return data
			else
				return []
		).catch(do |e|
			console.log e
			return []
		)

	def getParallelVersesFromStorage
		return await Promise.all(compare_translations.map(do |translation|
			const finded_verses = await Promise.all(choosen_for_comparison.map(do |verse|
				@db.transaction("r", @db:verses, do
					const wait_for_verses = await @db:verses.get({translation: translation, book: compare_parallel_of_book, chapter: compare_parallel_of_chapter, verse: verse})
					return wait_for_verses ? wait_for_verses : {"translation": translation}
				).catch(do |e|
					console.log e
					return {"translation": translation}
				)))
			return finded_verses
		))

	def getSearchedTextFromStorage
		let begtime = Date.now()
		@db.transaction("r", @db:verses, do
			let data = await @db:verses.where({translation: search:search_result_translation}).filter(do |verse|
				return verse:text.includes(search:search_input)
			).toArray()
			console.log("Finded ", data:length, " objects. Time: ", (Date.now() - begtime) / 1000)
			if data:length
				return data
			else
				return []
		).catch(do |e|
			console.log e
			return []
		)

	def getBookmarksFromStorage
		@db.transaction("r", @db:bookmarks, @db:verses, do
			let bookmarks = await @db:bookmarks.toArray()
			bookmarks = Promise.all(bookmarks.map(do |bookmark|
				bookmark:verse = await @db.transaction("r", @db:verses, do
					@db:verses.get({pk: bookmark:verse})
				).catch (do |e|
					console.error(e)
				)
				return bookmark
			))
			return bookmarks
		).catch (do |e|
			console.error(e)
		)

	def setLanguage language
		@language = language
		switch language
			when 'ukr' then @lang = uk_leng
			when 'ru' then @lang = ru_leng
			else @lang = en_leng
		setCookie('language', language)

	def copyToClipboard copyobj
		let value = '«'
		value += copyobj:text.join(' ').trim() + '»<br><br>' + copyobj:title
		if getCookie('clear_copy') != 'true'
			value += ' ' + copyobj:translation + ' ' + "https://bolls.life" + '/'+ copyobj:translation + '/' + copyobj:book + '/' + copyobj:chapter + '/' + copyobj:verse.sort(do |a, b| return a - b)[0]
		let aux = document.createElement("p")
		aux:innerHTML = value
		document:body.appendChild(aux)
		let range = document.createRange()
		range.selectNode(aux)
		window.getSelection().addRange(range)
		document.execCommand("copy")
		document:body.removeChild(aux)
		showNotification('copied')

	def showNotification ntfctn
		@notification = @lang[ntfctn]
		setTimeout(&, 2000) do
			if @notification == @lang[ntfctn]
				@notification = ''

	def requestDeleteBookmark pks
		if window:navigator:onLine
			window.fetch("/delete-bookmarks/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					verses: JSON.stringify(pks),
				}),
			})
			.then(do |response| response.json())
			.then(do |data|
			showNotification('deleted'))
		else
			deleteBookmark(bookmark:verse)
			setCookie('bookmarks-to-delete', JSON.stringify(pks))