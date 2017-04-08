'''Adapted from
 https://adesquared.wordpress.com/2013/06/16/using-python-beautifulsoup-to-scrape-a-wikipedia-table/'''

initial_link = "https://www.theguardian.com/sport/live/2016/nov/02/world-series-2016-game-7-chicago-cubs-cleveland-indians-live"


def getLinks(link):
    from bs4 import BeautifulSoup
    import urllib.request as url
    import pandas as pd
    import re
    from datetime import datetime as dt
    import time
    header = {'User-Agent': 'Mozilla/5.0'} #Needed to prevent 403 error on Wikipedia
    req = url.Request(link,headers=header)
    page = url.urlopen(req)
    soup = BeautifulSoup(page,"html5lib")
    list1=[]
    try:
        nextLink = 'https://www.theguardian.com'+soup.find('a',attrs={"data-link-name":"older page"})['href']
        list1.append(nextLink)
        list1.extend(getLinks(nextLink))
    except: pass
    return list1


links = getLinks(initial_link)
# Add the original link
links.append(initial_link)
test

def guardian_parser(links):
    from bs4 import BeautifulSoup
    import urllib.request as url
    import pandas as pd
    import re
    from datetime import datetime as dt
    import time
    # This is the initial link
    header = {'User-Agent': 'Mozilla/5.0'} #Needed to prevent 403 error on Wikipedia
    # Empty list to hold the results
    data = []
    for link in links:
        req = url.Request(link,headers=header)
        page = url.urlopen(req)
        soup = BeautifulSoup(page,"html5lib")
        # Look for the div elements that are key events
        patt = re.compile("is-key-event")
        keyEvents = soup.article.findAll('div', attrs={'class':patt})
        # Iterate over the keyEvents, extract the necessary data and add it to the data list
        for event in keyEvents:
            date = event.find('time')['datetime']
            head = event.find('h2').text
            content = event.find('div', attrs={'itemprop':'articleBody'}).text.strip()
            e = [date,head,content]
            data.append(e)
        time.sleep(20)
    return data

blog = guardian_parser(links)
blog

df = pd.DataFrame(blog, columns=['timestamp','header','text'])
df.timestamp


type(keyEvents[0].find('time')['datetime'])
