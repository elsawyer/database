#code from http://stackoverflow.com/questions/40729122/authenticating-yelp-fusion-api-with-python-requests

import requests

app_id = '' #put app id in quotes
app_secret = '' #put app secret in quotes
data = {'grant_type': 'client_credentials',
        'client_id': app_id,
        'client_secret': app_secret}
token = requests.post('https://api.yelp.com/oauth2/token', data=data)
access_token = token.json()['access_token']
url = 'https://api.yelp.com/v3/businesses/search'
headers = {'Authorization': 'bearer %s' % access_token}
params = {'location': 23454,
         }

resp = requests.get(url=url, params=params, headers=headers)

import pprint
pprint.pprint(resp.json()['businesses'])