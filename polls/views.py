#from django.shortcuts import render
from django.template import loader
# Create your views here.
from django.http import HttpResponse
from django.shortcuts import render

def index(request):
    return render(request, 'polls/index.html', context={
            'latest_question_list': ["hello", "what??!?", "<script>alert('XSS');</script>"],
        })
