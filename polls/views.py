#from django.shortcuts import render
from django.template import loader
# Create your views here.
from django.http import HttpResponse
from django.shortcuts import render

def index(request):
    return render(request, 'polls/cycle_bug.html', context={"A": ["1", "2", "3"]})  # Подтверждение бага https://code.djangoproject.com/ticket/34468.
