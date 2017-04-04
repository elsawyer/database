import json

import io
import requests

# Open file to write output to.
test2 = io.open("test2.csv", "w", encoding='utf8')
test2.write("Name, ID, Type, Phone, Location, Price, Closed, Rating, Website \n")

# Got a list of all zip codes in VA from post office website.
zip_codes = []
zips = open("/Users/RachelRambadt/Desktop/ZipCodes.txt", "r")
code = zips.readline()
while code != "":
    code = code.split()
    zip_codes.append(code[0])
    code = zips.readline()


# Make requests for all zip codes.
for zip_code in zip_codes:
        
    app_id = '******'
    app_secret = '**********'
    data = {'grant_type': 'client_credentials',
            'client_id': app_id,
            'client_secret': app_secret}
    token = requests.post('https://api.yelp.com/oauth2/token', data=data)
    access_token = token.json()['access_token']
    url = 'https://api.yelp.com/v3/businesses/search'
    headers = {'Authorization': 'bearer %s' % access_token}
    params = {'location': zip_code,
             }

    resp = requests.get(url=url, params=params, headers=headers)


    import pprint
    #pprint.pprint(resp.json()['businesses'])

    
    # This part puts the output into a new file in csv format. The order is:
    # Name, ID, Type, Phone, Address, Price, Closed? Rating and URL
    
    for string in resp.json()['businesses']:
        name, ID, Type, phone, add, price, closed, rating, url = "null", "null", "null", "null", "null", "null", "null", "null", "null"
        if "name" in string:
            name = string['name'].strip()
            name = name.replace(',', "")
                
        if "id" in string:
            
            ID = string['id'].strip()
            ID = ID.replace(',', "")
        
        if "categories" in string:
            if len(string['categories']) > 0:

                if "alias" in string['categories'][0]:
                    Type = string['categories'][0]['alias']
                 
                
                 
        if "display_phone" in string:
               phone = string['display_phone']
               if phone == " " or phone == "":
                   phone = "null"
               

        if "location" in string:
            if "display_address" in string['location']:
                add = ""
                for i in range(len(string['location']['display_address'])):
                    add = add + string['location']['display_address'][i].strip() + " "
                    add = add.replace(',', "")
            
        
        print(add)
        
        if 'price' in string:
            price = string['price']
           
        if "is_closed" in string:
            closed = str(string['is_closed']) 

        if "rating" in string:
            rating = str(string['rating']) 
        if "url" in string:
            url = string['url']
            

        test2.write(name + ', ')
        test2.write(ID + ', ')
        test2.write(Type + ', ')
        test2.write(phone + ', ')
        test2.write(add + ', ')
        test2.write(price + ', ')
        test2.write(closed + ', ')
        test2.write(rating + ', ')
        test2.write(url + '\n')




test2.close()
    
