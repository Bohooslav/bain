import "./loading.imba"
import *  as BOOKS from "./translations_books.json"

import {svg_paths} from "./svg_paths.imba"

let highlights_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let collection_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let notes_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let query = ''
let storage =
	username: ''
	name: ''

let taken_usernames = []
let loading = no
let show_options_of = ''

export tag profile-page
	bookmarks = []
	highlights = []
	notes = []
	books = []
	collections = []
	tab = 0
	list_for_display = []

	def setup
		highlights_range = {
			from: 0,
			to: 32,
			loaded: 0
		}
		notes_range = {
			from: 0,
			to: 32,
			loaded: 0
		}
		collection_range = {
			from: 0,
			to: 32,
			loaded: 0
		}
		loading = true
		bookmarks = []
		highlights = []
		notes = []
		query = ''
		show_options_of = ''
		getProfileBookmarks()
		if window.navigator.onLine
			getCategories()


	def mount
		document.title = "Bolls · " + data.getUserName()
		setup!

	def loadData url
		var res = await window.fetch url
		return res.json!

	def nameOfBook bookid, translation
		for book in BOOKS[translation]
			if book.bookid == bookid
				return book.name

	def getTitleRow translation, book, chapter, verses
		let row = nameOfBook(book, translation) + ' ' + chapter + ':'
		for id, key in verses.sort(do |a, b| return a - b)
			if id == verses[key - 1] + 1
				if id == verses[key+1] - 1
					continue
				else
					row += '-' + id
			else
				!key ? (row += id) : (row += ',' + id)
		return row

	def getCategories
		const url = "/get-categories/"
		collections = []
		const resdata = await loadData(url)
		collections = resdata.data
		imba.commit()

	def parseBookmarks bookmarksdata, bookmarkstype
		let newItem = {
			verse: [],
			text: []
		}
		for item, key in bookmarksdata
			newItem.date = new Date(item.date)
			newItem.color = item.color
			newItem.collection = item.collection
			newItem.note = item.note
			newItem.translation = item.verse.translation
			newItem.book = item.verse.book
			newItem.chapter = item.verse.chapter
			newItem.verse = [item.verse.verse]
			newItem.pks = [item.verse.pk]
			newItem.title = getTitleRow newItem.translation, newItem.book, newItem.chapter, newItem.verse
			if self[bookmarkstype][self[bookmarkstype].length - 1]
				if item.date == self[bookmarkstype][self[bookmarkstype].length - 1].date.getTime()
					self[bookmarkstype][self[bookmarkstype].length - 1].verse.push(item.verse.verse)
					self[bookmarkstype][self[bookmarkstype].length - 1].pks.push(item.verse.pk)
					self[bookmarkstype][self[bookmarkstype].length - 1].text.push(item.verse.text)
					self[bookmarkstype][self[bookmarkstype].length - 1].title = getTitleRow newItem.translation, newItem.book, newItem.chapter, self[bookmarkstype][self[bookmarkstype].length - 1].verse
				else
					newItem.text.push(item.verse.text)
					self[bookmarkstype].push(newItem)
					newItem = {
						verse: [],
						text: []
					}
			else
				newItem.text.push(item.verse.text)
				self[bookmarkstype].push(newItem)
				newItem = {
						verse: [],
						text: []
					}

	def getProfileBookmarks
		tab = 0
		if highlights_range.loaded != highlights_range.to
			highlights_range.from = highlights_range.loaded
			highlights_range.to = highlights_range.from + 32

			const url = "/get-profile-bookmarks/" + highlights_range.from + '/' + highlights_range.to + '/'

			let bookmarksdata
			if window.navigator.onLine
				bookmarksdata = await loadData(url)
			else
				bookmarksdata = await data.getBookmarksFromStorage() || []
			highlights_range.loaded += bookmarksdata.length
			parseBookmarks(bookmarksdata, 'highlights')
		list_for_display = highlights
		loading = no
		imba.commit()


	def getSearchedBookmarks collection
		collection_range.from = collection_range.loaded
		collection_range.to = collection_range.from + 32
		tab = 1
		if collection
			if collection != query
				collection_range.from = 0
				collection_range.to = 32
				collection_range.loaded = 0
				bookmarks = []

			query = collection
			if collection_range.loaded == collection_range.to or collection_range.loaded == 0
				const url = "/get-searched-bookmarks/{collection}/{collection_range.from}/{collection_range.to}/"
				const data = await loadData(url)
				collection_range.loaded += data[0].length
				parseBookmarks(data[0], 'bookmarks')
			list_for_display = bookmarks
			loading = no
			imba.commit()

	def getBookmarksWithNotes
		notes_range.from = notes_range.loaded
		notes_range.to = notes_range.from + 32
		tab = 2
		if notes_range.loaded == notes_range.to or notes_range.loaded == 0
			const data = await loadData("/get-notes-bookmarks/{notes_range.from}/{notes_range.to}/")
			notes_range.loaded += data[0].length
			parseBookmarks(data[0], 'notes')
		list_for_display = notes
		loading = no
		imba.commit()



	def scroll
		if (clientHeight - 512 < scrollTop + window.innerHeight) && !loading && query == ''
			loading = yes
			if tab == 0
				if highlights_range.loaded == highlights_range.to
					getProfileBookmarks()
			elif tab == 1
				if collection_range.loaded == collection_range.to
					getSearchedBookmarks()
			else
				if notes_range.loaded == notes_range.to
					getBookmarksWithNotes!


	def goToBookmark bookmark
		log bookmark, verse
		let bible = document.getElementsByTagName("bible-reader")
		bible[0].getText(bookmark.translation, bookmark.book, bookmark.chapter, bookmark.verse)


	def showOptions title
		if show_options_of == title then show_options_of = ''
		else show_options_of = title

	def deleteBookmark bookmark
		data.requestDeleteBookmark(bookmark.pks)
		for pk in bookmark.pks
			if bookmarks.find(do |bm| return bm.pks == pk)
				bookmarks.splice(bookmarks.indexOf(bookmarks.find(do |bm| return bm.pks == pk)), 1)
			if highlights.find(do |bm| return bm.pks == pk)
				highlights.splice(highlights.indexOf(highlights.find(do |bm| return bm.pks == pk)), 1)
		show_options_of = ''
		imba.commit()

	def copyToClipboard bookmark
		data.shareCopying(bookmark)
		show_options_of = ''

	def showDeleteForm
		show_options_of = 'delete_form'
		storage.username = ''
		window.history.pushState({profile: yes}, "Delete Account")

	def showEditForm
		show_options_of = 'edit_form'
		storage.username = data.user.username
		storage.name = data.user.name
		window.history.pushState({profile: yes}, "Edit Account")

	def editAccountFormIsValid
		let valid = -1
		let edit_account = document.getElementById('edit_account')
		if edit_account
			for node in edit_account.childNodes
				if node.tagName == 'INPUT'
					if node.checkValidity()
						valid++
		return valid

	def editAccount
		if editAccountFormIsValid() && window.navigator.onLine
			loading = yes
			window.fetch("/edit-account/", {
				method: "POST",
				cache: "no-cache",
				headers: {
					'X-CSRFToken': data.get_cookie('csrftoken'),
					"Content-Type": "application/json"
				},
				body: JSON.stringify({
					newusername: storage.username,
					newname: storage.name || '',
				}),
			})
			.then(do |response|
				if response.status == 200
					data.showNotification('account_edited')
					data.user.username = storage.username
					data.user.name = storage.name
					data.setCookie('username', data.user.username)
					data.setCookie('name', data.user.name)
					show_options_of = ''
				elif response.status == 409
					taken_usernames.push storage.username
					data.showNotification('username_taken')
			)
			loading = no


	def render
		<self @scroll=scroll>
			<header.profile_hat>
				<.collectionsflex[z-index: 100000]>
					<a.svgBack [pos:relative m:auto 16px auto 0 l:8px] route-to='/'>
						<svg[w:20px min-width: 20px h:32px fill:inherit] viewBox="0 0 20 20">
							<title> data.lang.back
							<path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
					<h1[margin: 1em 4px]> data.getUserName()
					if window.navigator.onLine
						<.change_password.help>
							<svg.helpsvg @click=showOptions('account_actions') viewBox="0 0 24 24" width="18px" height="18px">
								<title> data.lang.edit_account
								<path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z">
							<.languages[pos:fixed right:{window.innerWidth > 960 ? (window.innerWidth - 886) / 2 : 36}px] .show_languages=(show_options_of == 'account_actions')>
								if data.user.is_password_usable then <a @click.prevent=(do window.location = "/accounts/password_change/")><button> data.lang.change_password
								<button @click=showDeleteForm()> data.lang.delete_account
								<button @click=showEditForm()> data.lang.edit_account

			<div.nav>
				<button.tab .active-tab=tab==0 @click=getProfileBookmarks()> data.lang.all
				<button.tab .active-tab=tab==1 @click=getSearchedBookmarks(0)> data.lang.collections
				<button.tab .active-tab=tab==2 @click=getBookmarksWithNotes> data.lang.notes

			if tab == 1
				<.collectionsflex [flex-wrap: wrap]>
					for collection in collections
						if collection
							<p.collection @click=getSearchedBookmarks(collection)> collection
					<div [min-width: 16px]>



			for bookmark in list_for_display
				<article.bookmark_in_list [border-color: {bookmark.color}]>
					<p.bookmark_text innerHTML=bookmark.text.join(" ") @click=goToBookmark(bookmark) dir="auto">
					if bookmark.collection
						<p.bookmark_collections>
							for collection in bookmark.collection.split(' | ')
								<p.collection @click=getSearchedBookmarks(collection)> collection
					if bookmark.note
						<p.profile_note.EditingArea[overflow: auto;] innerHTML=bookmark.note dir="auto">
					<p.dataflex>
						<span.booktitle dir="auto"> bookmark.title, ' ', bookmark.translation
						<time.time time.datetime="bookmark.date"> bookmark.date.toLocaleString()
						<svg._options @click=showOptions(bookmark.title) viewBox="0 0 20 20">
							<path d="M10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0-6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4z">
						<.languages[right: {window.innerWidth > 960 ? (window.innerWidth - 886) / 2 : 36}px] .show_languages=(bookmark.title == show_options_of)>
							<button @click=deleteBookmark(bookmark)> data.lang.delete
							<button @click=goToBookmark(bookmark)> data.lang.open
							<button @click=copyToClipboard(bookmark)> data.lang.copy
				<hr.hr>

			if loading
				<loading-animation[padding: 128px 0]>
			else
				<div.freespace>

			if !highlights.length && !collections.length
				<p[text-align: center]> data.lang.thereisnobookmarks



			<div#daf[visibility: {show_options_of == "delete_form" || show_options_of == "edit_form" ? 'visible' : 'hidden'}]>
				<section.search_results .show_search_results=(show_options_of == "delete_form" || show_options_of == "edit_form")>
					if show_options_of == "delete_form"
						<form action="/delete-my-account/">
							<header.search_hat>
								<h1[margin:auto]> data.lang.are_you_sure
								<svg.close_search :click=(do show_options_of = '') viewBox="0 0 20 20" tabindex="0">
									<title> data.lang.close
									<path d=svg_paths.close [margin:auto]>
							<p[margin-bottom:16px]> data.lang.cannot_be_undone
							<label> data.lang.delete_account_label
							<input.search bind=storage.username [margin: 8px 0 border-radius:4px]>
							if storage.username == data.user.username
								<button.change_language> data.lang.i_understand
							else
								<button.change_language disabled> data.lang.i_understand
					else
						<article#edit_account>
							<header.search_hat>
								<h1[margin:auto]> data.lang.edit_account
								<svg.close_search :click=(do show_options_of = '') viewBox="0 0 20 20" tabindex="0">
									<title> data.lang.close
									<path d=svg_paths.close css:margin="auto">
							<label> data.lang.edit_username_label
							<input.search bind=storage.username .invalid=taken_usernames.includes(storage.username) pattern='[a-zA-Z0-9_@+\.-]{1,150}' required maxlength=150 [margin:8px 0 border-radius:4px]>
							if taken_usernames.includes(storage.username)
								<p.errormessage> data.lang.username_taken
							<label> data.lang.edit_name_label
							<input.search bind=storage.name maxlength=30 [margin: 8px 0 border-radius:4px]>
							if editAccountFormIsValid()
								<button.change_language :click.editAccount()> data.lang.edit_account
							else
								<button.change_language disabled :click.editAccount()> data.lang.edit_account



			if !window.navigator.onLine
				<div[pposition: fixed bottom: 16px left: 16px color: var(--text-color) background: var(--background-color) padding: 8px border-radius: 8px text-align: center border: 1px solid var(--btn-bg-hover) z-index: 1000]>
					data.lang.offline
					<svg[transform: translateY(0.2em) fill: $text-color] width="1.25em" height="1.26em" viewBox="0 0 24 24">
						<path fill="none" d="M0 0h24v24H0V0z">
						<path d="M23.64 7c-.45-.34-4.93-4-11.64-4-1.32 0-2.55.14-3.69.38L18.43 13.5 23.64 7zM3.41 1.31L2 2.72l2.05 2.05C1.91 5.76.59 6.82.36 7L12 21.5l3.91-4.87 3.32 3.32 1.41-1.41L3.41 1.31z">
					<a.reload @click=(do window.location.reload(true))> data.lang.reload

	css
		h: 100vh
		ofy: auto
		padding: 0 calc(50% - 470px) 256px
		d: block
		pos: relative


		.nav
			d:flex

		.tab
			p:12px 16px
			font:inherit
			fs:0.8em
			c:inherit
			tt:uppercase
			bg:transparent @hover:$btn-bg-hover
			bdb:4px solid transparent
			cursor:pointer

		.active-tab
			bcb:$accent-hover-color
