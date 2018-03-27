# Scraper for Baseball-Reference Box Score


from bs4 import BeautifulSoup, Comment
import urllib.request as url
import pandas as pd
import re
link = "http://www.baseball-reference.com/boxes/CLE/CLE201611020.shtml"
req = url.Request(link)
page = url.urlopen(req)
soup = BeautifulSoup(page,"lxml")

# Annoyingly, the table we need is in the comments, so we need to find them first
comments = soup.findAll(text=lambda text:isinstance(text, Comment))

# Find the comment containing 'play_by_play'
box_string = [comment.extract() for comment in comments if 'play_by_play' in comment]

# read_html returns a list of tables - since there's only one, we take the zeroth
box = pd.read_html(box_string[0])[0]

# Remove the rows which are annotations (substitutions, end of inning recaps)
final_box = box[box['Score'].notnull()]
# Output to CSV
final_box.to_csv("G7_box.csv")
