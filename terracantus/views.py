from django.http import HttpResponse
from django.contrib.auth.models import User


def index(request):
    count = User.objects.count()
    message = "Hello world!" + str(
        " There are {} users".format(count) if count > 0 else ""
    )

    return HttpResponse(message)
