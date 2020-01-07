from django.db.models import Count
import ast
import json
from django.contrib.auth.decorators import login_required
from django.contrib.auth import login, authenticate
from django.shortcuts import render, redirect
from django.http import JsonResponse, HttpResponse

from django.contrib.auth.models import User
from .models import Verses, Bookmarks

from bolls.forms import SignUpForm

from django.core.mail import mail_admins, BadHeaderError
from django.views import generic
from django.utils import timezone
from django.http import HttpResponseRedirect, HttpResponse
from django.urls import reverse


def index(request):
    return render(request, 'bolls/index.html')


def getText(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')
    d = []
    for obj in all_objects:
        d.append({
            "pk": obj.pk,
            "verse": obj.verse,
            "text": obj.text
        })
    return JsonResponse(d, safe=False)


def linkToVerse(request, translation, book, chapter, verse):
    return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter, "verse": verse})


def linkToChapter(request, translation, book, chapter):
    return render(request, 'bolls/index.html', {"translation": translation, "book": book, "chapter": chapter})


def search(request, translation, piece):
    results_of_search = Verses.objects.filter(
        translation=translation, text__icontains=piece).order_by('book', 'chapter', 'verse')
    d = []
    for obj in results_of_search:
        d.append({
            "pk": obj.pk,
            "translation": obj.translation,
            "book": obj.book,
            "chapter": obj.chapter,
            "verse": obj.verse,
            "text": obj.text
        })
    return JsonResponse(d, safe=False)


def signUp(request):
    if request.method == 'POST':
        form = SignUpForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)
            login(request, user)
            return redirect('index')
    else:
        form = SignUpForm()
    return render(request, 'registration/signup.html', {'form': form})


@login_required
def getBookmarks(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')

    bookmarks = []
    for obj in all_objects:
        if list(obj.bookmarks_set.all().filter(user=request.user)):
            for bookmark in obj.bookmarks_set.all():
                bookmarks.append({
                    "verse": bookmark.verse.pk,
                    "date": bookmark.date,
                    "color": bookmark.color,
                    "note": bookmark.note,
                })
    return JsonResponse(bookmarks, safe=False)


@login_required
def getProfileBookmarks(request, range_from, range_to):
    user = request.user

    bookmarks = []
    for bookmark in user.bookmarks_set.all().order_by(
            '-date', 'verse')[range_from:range_to]:

        bookmarks.append({
            "verse": {
                "verse_id": bookmark.verse.pk,
                "translation": bookmark.verse.translation,
                "book": bookmark.verse.book,
                "chapter": bookmark.verse.chapter,
                "verse": bookmark.verse.verse,
                "text": bookmark.verse.text,
            },
            "date": bookmark.date,
            "color": bookmark.color,
            "note": bookmark.note,
        })

    return JsonResponse(bookmarks, safe=False)


@login_required
def getSearchedProfileBookmarks(request, query):
    user = request.user
    bookmarks = []
    for bookmark in user.bookmarks_set.all().filter(note__icontains=query).order_by('-date', 'verse'):
        bookmarks.append({
            "verse": {
                "verse_id": bookmark.verse.pk,
                "translation": bookmark.verse.translation,
                "book": bookmark.verse.book,
                "chapter": bookmark.verse.chapter,
                "verse": bookmark.verse.verse,
                "text": bookmark.verse.text,
            },
            "date": bookmark.date,
            "color": bookmark.color,
            "note": bookmark.note,
        })
    return JsonResponse(bookmarks, safe=False)


@login_required
def getCategories(request):
    user = request.user
    all_objects = user.bookmarks_set.values('note').annotate(dcount=Count('note')).order_by('-date')
    return JsonResponse({"data": [b for b in all_objects]}, safe=False)


@login_required
def saveBookmarks(request):
    received_json_data = json.loads(request.body)
    user = User.objects.get(pk=received_json_data["user"])

    for verseid in ast.literal_eval(received_json_data["verses"]):
        verse = Verses.objects.get(pk=verseid)
        try:
            obj = user.bookmarks_set.get(user=user, verse=verse)
            user.bookmarks_set.filter(
                user=user, verse=verse).update(
                    date=received_json_data["date"], color=received_json_data["color"], note=received_json_data["notes"])
        except Bookmarks.DoesNotExist:
            user.bookmarks_set.create(
                verse=verse, date=received_json_data["date"], color=received_json_data["color"], note=received_json_data["notes"])
    return JsonResponse({"response": "200"}, safe=False)


@login_required
def deleteBookmarks(request):
    received_json_data = json.loads(request.body)
    user = User.objects.get(pk=received_json_data["user"])

    for verseid in ast.literal_eval(received_json_data["verses"]):
        verse = Verses.objects.get(pk=verseid)
        user.bookmarks_set.filter(verse=verse).delete()

    return JsonResponse({"response": "200"}, safe=False)


def robots(request):
    filename = "robots.txt"
    content = "User-agent: *\nDisallow: /admin/\nAllow: /\nSitemap: http://bolls.life/static/sitemap.xml"
    response = HttpResponse(content, content_type='text/plain')
    response['Content-Disposition'] = 'attachment; filename={0}'.format(
        filename)
    return response


def api(request):
    return render(request, 'bolls/api.html')
