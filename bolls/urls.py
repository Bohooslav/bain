from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('robots.txt', views.robots, name='robots'),
    path('signup/', views.signUp, name='signup'),
    path('api/', views.api, name='api'),
    path('profile/', views.index, name='profile'),

    path('get-categories/',
         views.getCategories, name='getCategories'),
    path('get-searched-bookmarks/<str:query>/',
         views.getSearchedProfileBookmarks, name='getSearchedProfileBookmarks'),
    path('<slug:translation>/<str:piece>/', views.search, name='search'),

    path('get-text/<slug:translation>/<int:book>/<int:chapter>/',
         views.getText, name='getText'),
    path('get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/',
         views.getBookmarks, name='getBookmarks'),
    path('get-profile-bookmarks/<int:range_from>/<int:range_to>/',
         views.getProfileBookmarks, name='getProfileBookmarks'),

    path('save-bookmarks/', views.saveBookmarks, name='saveBookmarks'),
    path('delete-bookmarks/', views.deleteBookmarks, name='deleteBookmarks'),

    path('<slug:translation>/<int:book>/<int:chapter>/',
         views.linkToChapter, name='linkToChapter'),
    path('/<slug:translation>/<int:book>/<int:chapter>/',
         views.linkToChapter, name='linkToChapter'),
    path('<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
         views.linkToVerse, name='linkToVerse'),

]
