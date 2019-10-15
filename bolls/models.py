from django.db import models


# class Bibles(models.Model):
#     Title = models.CharField(max_length=32)
#     Abbreviation = models.CharField(max_length=4)

class Verses(models.Model):
    # bible = models.ForeignKey(Bibles, on_delete=models.CASCADE)
    translation = models.CharField(max_length=120)
    book = models.PositiveSmallIntegerField()
    chapter = models.PositiveSmallIntegerField()
    verse = models.PositiveSmallIntegerField()
    text = models.TextField()
