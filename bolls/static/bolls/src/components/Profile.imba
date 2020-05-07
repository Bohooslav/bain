import "./translations_books.json" as BOOKS
import {Load} from "./loading.imba"

let user = {
	name: '',
}
let limits_of_range = {
	from: 0,
	to: 32,
	loaded: 0
}
let verses = []
let query = ''
let loading = no
let show_options_of = ''

export tag Profile < main
	prop bookmarks default: []
	prop loaded_bookmarks default: []
	prop books default: []
	prop categories default: []

	def setup
		limits_of_range:from = 0
		limits_of_range:to = 32
		limits_of_range:loaded = 0
		loading = true
		@bookmarks = []
		@loaded_bookmarks = []
		query = ''
		show_options_of = ''
		getProfileBookmarks(limits_of_range:from, limits_of_range:to)
		if window:navigator:onLine
			getCategories
		if window:navigator:onLine
			try
				let data = await loadData("/user-logged/")
				if data:username
					user:name = data:username
			catch error
				console.error('Error: ', error)

	def mount
		@data.hideBible()
		window:addEventListener('scroll', do render)

	def unmount
		@data.showBible()
		window:removeEventListener('scroll', do render)

	def getCookie c_name
		return window:localStorage.getItem(c_name)

	def loadData url
		var res = await window.fetch url
		return res.json

	def nameOfBook bookid, translation
		for book in BOOKS[translation]
			if book:bookid == bookid
				return book:name

	def getTitleRow translation, book, chapter, verses
		let row = nameOfBook(book, translation) + ' ' + chapter + ':'
		for id, key in verses.sort(do |a, b| return a - b)
			if id == verses[key - 1] + 1
				if id == verses[key+1] - 1
					continue
				else
					row += '-' + id
			else
				if !key
					row += id
				else
					row += ',' + id
		return row

	def getProfileBookmarks range_from, range_to
		let url = "/get-profile-bookmarks/" + range_from + '/' + range_to + '/'
		let bookmarksdata
		if window:navigator:onLine
			bookmarksdata = await loadData(url)
		else
			console.log @data
			bookmarksdata = await @data.getBookmarksFromStorage() || []
		limits_of_range:loaded += bookmarksdata:length
		let newItem = {
			verse: [],
			text: []
		}
		for item, key in bookmarksdata
			newItem:date = Date.new(item:date)
			newItem:color = item:color
			newItem:note = item:note
			newItem:translation = item:verse:translation
			newItem:book = item:verse:book
			newItem:chapter = item:verse:chapter
			newItem:verse = [item:verse:verse]
			newItem:pks = [item:verse:verse_id]
			newItem:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, newItem:verse
			if @loaded_bookmarks[@loaded_bookmarks:length - 1]
				if item:date == @loaded_bookmarks[@loaded_bookmarks:length - 1]:date.getTime
					@loaded_bookmarks[@loaded_bookmarks:length - 1]:verse.push(item:verse:verse)
					@loaded_bookmarks[@loaded_bookmarks:length - 1]:pks.push(item:verse:verse_id)
					@loaded_bookmarks[@loaded_bookmarks:length - 1]:text.push(item:verse:text)
					@loaded_bookmarks[@loaded_bookmarks:length - 1]:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, @loaded_bookmarks[@loaded_bookmarks:length - 1]:verse
				else
					newItem:text.push(item:verse:text)
					@loaded_bookmarks.push(newItem)
					newItem = {
						verse: [],
						text: []
					}
			else
				newItem:text.push(item:verse:text)
				@loaded_bookmarks.push(newItem)
				newItem = {
						verse: [],
						text: []
					}
		loading = no
		limits_of_range:from = range_from
		limits_of_range:to = range_to
		Imba.commit

	def getCategories
		let url = "/get-categories/"
		@categories = []
		let data = await loadData(url)
		for categories in data:data
			for piece in categories:note.split(' | ')
				if piece != ''
					@categories.push(piece)
		@categories = Array.from(Set.new(@categories))
		Imba.commit()

	def toBible
		window:history.back()
		orphanize

	def getMoreBookmarks
		if limits_of_range:loaded == limits_of_range:to
			getProfileBookmarks(limits_of_range:to, limits_of_range:to + 32)

	def goToBookmark bookmark
		let bible = document:getElementsByClassName("Bible")
		bible[0]:_tag.getText(bookmark:translation, bookmark:book, bookmark:chapter)
		orphanize
		setTimeout(&,1200) do
			window:location:hash = "#{bookmark:verse[0]}"

	def getSearchedBookmarks category
		if category
			query = category
			@bookmarks = []
			let url = "/get-searched-bookmarks/" + category + '/'
			let data = await loadData(url)
			let newItem = {
				verse: [],
				text: []
			}
			for item, key in data
				newItem:date = Date.new(item:date)
				newItem:color = item:color
				newItem:note = item:note
				newItem:translation = item:verse:translation
				newItem:book = item:verse:book
				newItem:chapter = item:verse:chapter
				newItem:verse = [item:verse:verse]
				newItem:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, newItem:verse
				if @bookmarks[@bookmarks:length - 1]
					if item:date == @bookmarks[@bookmarks:length - 1]:date.getTime
						@bookmarks[@bookmarks:length - 1]:verse.push(item:verse:verse)
						@bookmarks[@bookmarks:length - 1]:text.push(item:verse:text)
						@bookmarks[@bookmarks:length - 1]:title = getTitleRow newItem:translation, newItem:book, newItem:chapter, @bookmarks[@bookmarks:length - 1]:verse
					else
						newItem:text.push(item:verse:text)
						@bookmarks.push(newItem)
						newItem = {
							verse: [],
							text: []
						}
				else
					newItem:text.push(item:verse:text)
					@bookmarks.push(newItem)
					newItem = {
							verse: [],
							text: []
						}
			if !bookmarks:length
				let meg = document.getElementById('defaultmassage')
				meg:innerHTML = @data.lang:nothing
			Imba.commit()
		else closeSearch

	def closeSearch
		query = ''

	def onscroll
		if (dom:clientHeight - 512 < window:scrollY + window:innerHeight) && !loading
			loading = yes
			getMoreBookmarks

	def showOptions title
		if show_options_of == title
			show_options_of = ''
		else
			show_options_of = title

	def deleteBookmark bookmark
		@data.requestDeleteBookmark(bookmark:pks)
		for verse in bookmark:verse
			if @bookmarks.find(do |bm| return bm:pks == bookmark:pks)
				@bookmarks.splice(@bookmarks.indexOf(@bookmarks.find(do |bm| return bm:pks == bookmark:pks)), 1)
			if @loaded_bookmarks.find(do |bm| return bm:pks == bookmark:pks)
				@loaded_bookmarks.splice(@loaded_bookmarks.indexOf(@loaded_bookmarks.find(do |bm| return bm:pks == bookmark:pks)), 1)
		show_options_of = ''
		Imba.commit

	def copyToClipboard bookmark
		@data.copyToClipboard(bookmark)
		show_options_of = ''

	def render
		<self :onscroll=onscroll>
			<header.profile_hat>
				if !query
					<.collectionsflex css:flex-wrap="wrap">
						<svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.toBible>
							<svg:title> @data.lang:back
							<svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
						<h1> user:name.charAt(0).toUpperCase() + user:name.slice(1)
						<a.change_password.help href="/accounts/password_change/">
							<span> @data.lang:change_password
							<svg:svg.helpsvg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="18px" height="18px">
								<svg:title> @data.lang:change_password
								<svg:path d="M0 0h24v24H0z" fill="none">
								<svg:path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z">
					<.collectionsflex css:flex-wrap="wrap">
						for category in @categories
							if category
								<p.collection :tap.prevent.getSearchedBookmarks(category)> category
						<div css:min-width="16px">
				else
					<.collectionsflex css:flex-wrap="wrap">
						<svg:svg.svgBack.backInProfile xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" :tap.prevent.closeSearch>
							<svg:title> @data.lang:back
							<svg:path d="M3.828 9l6.071-6.071-1.414-1.414L0 10l.707.707 7.778 7.778 1.414-1.414L3.828 11H20V9H3.828z">
						<h1> query
			for bookmark in (query ? @bookmarks : @loaded_bookmarks)
				<article.bookmark_in_list css:border-color="{bookmark:color}">
					<text-as-html[{text: bookmark:text.join(" ")}].bookmark_text :tap.prevent.goToBookmark(bookmark) dir="auto">
					if bookmark:note
						<p.note> bookmark:note
					<p.dataflex>
						<span.booktitle dir="auto"> bookmark:title, ' ', bookmark:translation
						<time.time time:datetime="bookmark:date"> bookmark:date.toLocaleString()
						<svg:svg._options :tap.prevent.showOptions(bookmark:title) xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20">
							<svg:path d="M10 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0-6a2 2 0 1 1 0-4 2 2 0 0 1 0 4zm0 12a2 2 0 1 1 0-4 2 2 0 0 1 0 4z">
						<.languages css:right="{window:innerWidth > 960 ? (window:innerWidth - 886) / 2 : 32}px" .show_languages=(bookmark:title==show_options_of)>
							<button :tap.prevent.deleteBookmark(bookmark)> @data.lang:delete
							<button :tap.prevent.goToBookmark(bookmark)> @data.lang:open
							<button :tap.prevent.copyToClipboard(bookmark)> @data.lang:copy
				<hr.hr>
			if loading && ((limits_of_range:loaded == limits_of_range:to) || limits_of_range:loaded == 0)
				<Load css:padding="128px 0">
			else
				<div.freespace>
			if !@loaded_bookmarks:length && !@categories:length
				<p css:text-align="center"> @data.lang:thereisnobookmarks

		if !window:navigator:onLine
			<div style="position: fixed;bottom: 16px;left: 16px;color: var(--text-color);background: var(--background-color);padding: 8px;border-radius: 8px;text-align: center;border: 1px solid var(--btn-bg-hover);z-index: 1000">
				@data.lang:offline
				<svg:svg css:transform="translateY(0.2em)" fill="var(--text-color)" xmlns="http://www.w3.org/2000/svg" width="1.25em" height="1.26em" viewBox="0 0 24 24">
					<svg:path fill="none" d="M0 0h24v24H0V0z">
					<svg:path d="M23.64 7c-.45-.34-4.93-4-11.64-4-1.32 0-2.55.14-3.69.38L18.43 13.5 23.64 7zM3.41 1.31L2 2.72l2.05 2.05C1.91 5.76.59 6.82.36 7L12 21.5l3.91-4.87 3.32 3.32 1.41-1.41L3.41 1.31z">
				<a.reload :tap=(do window:location.reload(true))> @data.lang:reload
