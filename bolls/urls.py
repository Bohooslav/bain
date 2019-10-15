from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('<slug:translation>/<str:piece>/', views.search, name='search'),
    path('<slug:translation>/<int:book>/<int:chapter>/', views.linkToText, name='linkToText'),
    path('get-text/<slug:translation>/<int:book>/<int:chapter>/',
         views.getText, name='getText'),
]
