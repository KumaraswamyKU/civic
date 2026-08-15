from django.db import models


class Department(models.Model):
    class Code(models.TextChoices):
        GARBAGE = "garbage", "Waste Management Department"
        WATER = "water", "Water Supply Department"
        ELECTRICAL = "electrical", "Electrical Department"

    code = models.CharField(max_length=20, choices=Code.choices, unique=True)
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ["name"]
