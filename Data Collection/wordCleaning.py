import pandas as pd
import re
import os
# Read the file
os.chdir('Box Sync/Spring 2017/ARCH 5400/Assignments/Final Project')
text = open("Data/words.txt",'r')

data = text.readlines()

text.close()

data[0]

def topics(text):
    # Remove parentheses
    temp = re.sub('[\(|\)]','', string=text)
    # Extract topic number and all words
    temp = re.findall("^\d+|[a-zA-Z]{2,}", temp)
    # Append Topic X - English"
    temp[0] = "Topic "+ temp[0] + " - English"
    temp2 = [temp[0]]+ [", ".join(temp[1:])]
    return(temp2)


# Sanity Check
topics(data[1])

# List comprehension
topicWords = [topics(x) for x in data]

# Create a data frame
df = pd.DataFrame(topicWords)

# Use `rename()` to rename your columns
df.rename(columns={0:"lang.topic", 1:"words"}, inplace = True)
df.to_csv("Data/topicWords.csv",index=False)
