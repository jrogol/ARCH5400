import pandas as pd
from sqlalchemy import create_engine
import sqlalchemy
from pandas.io import sql

data = pd.read_csv("English_Chicago.csv")

# Drop the 'index' axis, as we need it not.
data = data.drop(['Unnamed: 0'], axis = 1)

engine = create_engine('postgresql://jamesrogol@localhost:5432/chicago')

data.to_sql('topic_assignment', engine, if_exists = 'replace', index = False,
dtype = {'user_id':sqlalchemy.BIGINT})

engine.connect()

result = engine.execute('SELECT * FROM topic_assignment LIMIT 10;')
for i in result:
    print(i)
engine.connect().close()


import json

data = open('Langauge.json').read()
langs = pd.read_json(data)
langs = langs.drop('status', axis=1)

langs.to_sql('languages', engine, if_exists = 'replace', index = False)
