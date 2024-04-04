from django.http import HttpResponse
from django.template import loader


def index(request):
    message = "Hello world!"
    template = loader.get_template("index.html")
    context = {"message": message}
    return HttpResponse(template.render(context, request))
