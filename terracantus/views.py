from django.http import HttpResponse


def index(request):
    message = "Hello world!"
    return HttpResponse(message)
