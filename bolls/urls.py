from django.urls import path
from . import views
from django.conf.urls import handler404, handler500

urlpatterns = [
    path('', views.index, name='index'),
    path('get-categories/', views.getCategories, name='getCategories'),
    path('robots.txt', views.robots, name='robots'),
    path('signup/', views.signUp, name='signup'),
    path('api/', views.api, name='api'),
    path('sw.js', views.sw, name='sw'),
    path('profile/', views.index, name='profile'),
    path('downloads/', views.index, name='downloads'),
    path('get-history/', views.getHistory, name='getHistory'),
    path('save-history/', views.saveHistory, name='saveHistory'),
    path('save-bookmarks/', views.saveBookmarks, name='saveBookmarks'),
    path('delete-bookmarks/', views.deleteBookmarks, name='deleteBookmarks'),
    path('user-logged/', views.userLogged, name="userLogged"),
    path('get-translation/<slug:translation>/',
         views.getTranslation, name="getTranslation"),
    path('get-paralel-verses/', views.getParallelVerses, name='getParallelVerses'),
    path('get-searched-bookmarks/<str:query>/',
         views.getSearchedProfileBookmarks, name='getSearchedProfileBookmarks'),
    path('search/<slug:translation>/<str:piece>/', views.search, name='search'),
    path('<slug:translation>/<str:piece>/', views.search, name='search'),
    path('get-text/<slug:translation>/<int:book>/<int:chapter>/',
         views.getText, name='getText'),
    path('get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/',
         views.getBookmarks, name='getBookmarks'),
    path('get-profile-bookmarks/<int:range_from>/<int:range_to>/',
         views.getProfileBookmarks, name='getProfileBookmarks'),
    path('<slug:translation>/<int:book>/<int:chapter>/',
         views.linkToChapter, name='linkToChapter'),
    path('/<slug:translation>/<int:book>/<int:chapter>/',
         views.linkToChapter, name='linkToChapter'),
    path('<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
         views.linkToVerse, name='linkToVerse'),
    path('/<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
         views.linkToVerse, name='/linkToVerse'),
]
handler404 = views.handler404
handler500 = views.handler500
