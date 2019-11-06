from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('profile/', views.profile, name='profile'),
    path('signup/', views.signUp, name='signup'),
    path('get-text/<slug:translation>/<int:book>/<int:chapter>/', views.getText, name='getText'),
    path('<slug:translation>/<str:piece>/', views.search, name='search'),
    path('get-bookmarks/<slug:translation>/<int:book>/<int:chapter>/',
         views.getBookmarks, name='getBookmarks'),
    path('get-profile-bookmarks/<int:range_from>/<int:range_to>/',
         views.getProfileBookmarks, name='getProfileBookmarks'),
    path('save-bookmarks/', views.saveBookmarks, name='saveBookmarks'),
    path('delete-bookmarks/', views.deleteBookmarks, name='deleteBookmarks'),
]
