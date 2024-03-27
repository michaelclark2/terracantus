from django.http import HttpResponse
from django.contrib.auth.models import User


def index(request):
    count = User.objects.count()
    return HttpResponse("hello! there are {} users".format(count))
