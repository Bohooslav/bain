from django.db import models
from django.contrib.auth.models import User


# class VersesManager(models.Manager):
#     def get_by_natural_key(self, translation, book, chapter, verse, text):
#         return self.get(translation=translation, book=book, chapter=chapter, verse=verse, text=text)


class Verses(models.Model):
    translation = models.CharField(max_length=120)
    book = models.PositiveSmallIntegerField()
    chapter = models.PositiveSmallIntegerField()
    verse = models.PositiveSmallIntegerField()
    text = models.TextField()

    # objects = VersesManager()

    # class Meta:
    #     unique_together = [['translation', 'book', 'chapter', 'verse', 'text']]

    def natural_key(self):
        return (self.translation, self.book, self.chapter, self.verse, self.text)


class Bookmarks(models.Model):
    verse = models.ForeignKey(Verses, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    date = models.BigIntegerField()
    color = models.CharField(max_length=32)
    note = models.TextField(default=None)
