#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# data analysis
import pandas as pd
from numpy import nan
from datetime import datetime, timedelta

# string processing
import re
from io import StringIO
from itertools import chain

# In[ ]:


## import local version chat log
with open("do-not-track/meeting_saved_chat.txt", "r", encoding="utf-8") as uploaded_file:
    string_data = uploaded_file.readlines()

# In[ ]:

## extract metadata for "events" in the chat
regex_time = r'\d{2}:\d{2}:\d{2}'
r = re.compile(regex_time)

events = list(filter(r.match, string_data))
events = [line.strip() for line in events]

send_time = [r.match(line).group() for line in events]
send_from_to = [re.sub(regex_time, "", line).strip() for line in events]

# In[ ]:

## extract message lines for each event
n_events = len(events)
msgs = [[] for i in range(n_events)]
i = -1

for (idx, line) in enumerate(string_data):
    if not re.match("\t",line):
        i += 1
    if re.match("\t", line):
        msgs[i].append(line)

## collapse multi-line messages
for (idx, item) in enumerate(msgs):
    if len(item) != 1:
        msgs[idx] = "".join(item)

# In[ ]:

chat_dict = {'time' : send_time, 'message' : msgs, 'sender' : send_from_to}

## unnest message column & make sure it doesn't add extra rows
chat_df = pd.DataFrame(chat_dict).explode('message')
assert(len(events) == chat_df.shape[0])


# In[ ]:

## save the parsed file
chat_df.to_json("do-not-track/chat_df.json", orient = "records")
chat_df[["time", "message"]]