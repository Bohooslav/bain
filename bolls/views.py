import ast, json
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth import login, authenticate
from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.core.serializers import serialize

from django.contrib.auth.models import User
from .models import Verses, Bookmarks

from bolls.forms import SignUpForm

def index(request):
    return render(request, 'bolls/index.html')


def getText(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')
    data = serialize('json', all_objects)
    return JsonResponse(data, safe=False)


def search(request, translation, piece):
    results_of_search = Verses.objects.filter(
        translation=translation, text__icontains=piece).order_by('book', 'chapter', 'verse')
    data = serialize('json', results_of_search)
    return JsonResponse(data, safe=False)


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
def profile(request):
    return redirect('index')


@login_required
def getBookmarks(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')

    bookmarks = []
    for obj in all_objects:
        if list(obj.bookmarks_set.all().filter(user=request.user)):
            bookmarks.append(serialize(
                'json', obj.bookmarks_set.all()))

    return JsonResponse({"data": bookmarks}, safe=False)


@login_required
def getProfileBookmarks(request, range_from, range_to):
    user = request.user
    all_objects = user.bookmarks_set.all().order_by('date')[range_from:range_to]

    bookmarks = serialize(
        'json', all_objects, use_natural_foreign_keys=True)

    return JsonResponse({"data": bookmarks}, safe=False)


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
    return JsonResponse({"200": "ok"}, safe=False)


@login_required
def deleteBookmarks(request):
    received_json_data = json.loads(request.body)
    user = User.objects.get(pk=received_json_data["user"])

    for verseid in ast.literal_eval(received_json_data["verses"]):
        verse = Verses.objects.get(pk=verseid)
        print(verse)
        user.bookmarks_set.filter(verse=verse).delete()

    return JsonResponse({"200": "ok"}, safe=False)
