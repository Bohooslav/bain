from django.shortcuts import render, get_object_or_404
from django.http import JsonResponse
from django.core import serializers

from .models import Verses


def index(request):
    return render(request, 'bolls/index.html')

def search(request, translation, piece):
    results_of_search = Verses.objects.filter(
        translation=translation, text__icontains=piece).order_by('book', 'chapter', 'verse')
    data = serializers.serialize('json', results_of_search)
    return JsonResponse(data, safe=False)

def linkToText(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')
    context = {'text': serializers.serialize('json', all_objects), }
    return render(request, 'bolls/index.html', context)

def getVerses(request, book, chapter, verse):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, verse=verse).order_by('book', 'chapter')
    data = serializers.serialize('json', all_objects)
    return JsonResponse(data, safe=False)

def getText(request, translation, book, chapter):
    all_objects = Verses.objects.filter(
        book=book, chapter=chapter, translation=translation).order_by('verse')
    data = serializers.serialize('json', all_objects)
    return JsonResponse(data, safe=False)
