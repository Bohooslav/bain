from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('profile/', views.profile, name='profile'),
    path('signup/', views.signUp, name='signup'),

    path('<slug:translation>/<str:piece>/', views.search, name='search'),

    path('get-text/<slug:translation>/<int:book>/<int:chapter>/', views.getText, name='getText'),
    path('get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/', views.getBookmarks, name='getBookmarks'),
    path('get-profile-bookmarks/<int:range_from>/<int:range_to>/', views.getProfileBookmarks, name='getProfileBookmarks'),

    path('save-bookmarks/', views.saveBookmarks, name='saveBookmarks'),
    path('delete-bookmarks/', views.deleteBookmarks, name='deleteBookmarks'),

    path('<slug:translation>/<int:book>/<int:chapter>/<int:verse>/',
         views.linkToVerse, name='linkToVerse'),
    path('<slug:translation>/<int:book>/<int:chapter>/',
         views.linkToChapter, name='linkToChapter'),
]
