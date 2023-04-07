#from django.shortcuts import render
from django.template import loader
# Create your views here.
from django.http import HttpResponse
from django.shortcuts import render

def index(request):
    return render(request, 'polls/inherited.html', context={"var1": "string_another", "list_var": ["string_absolutely_new"]})
