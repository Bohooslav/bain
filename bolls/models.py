from django.db import models


class Verses(models.Model):
    translation = models.CharField(max_length=120)
    book = models.PositiveSmallIntegerField()
    chapter = models.PositiveSmallIntegerField()
    verse = models.PositiveSmallIntegerField()
    text = models.TextField()
