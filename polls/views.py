#from django.shortcuts import render
from django.template import loader
# Create your views here.
from django.http import HttpResponse


def index(request):
    latest_question_list = ["hello", "what??!?"]
    template = loader.get_template('polls/index.html')
    context = {
        'latest_question_list': latest_question_list,
    }
    return HttpResponse(template.render(context, request))