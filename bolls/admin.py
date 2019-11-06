from django.contrib import admin

from .models import Verses, Bookmarks


class BookmarksAdmin(admin.ModelAdmin):
    list_display = ('verse', 'user', 'date', 'color', 'note')


# admin.site.register(Verses)
admin.site.register(Bookmarks, BookmarksAdmin)
