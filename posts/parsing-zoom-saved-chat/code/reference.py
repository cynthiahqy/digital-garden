## from https://github.com/tomytjandra/zoom-chat-analyzer-app/blob/master/app.py

# data analysis
import pandas as pd
from numpy import nan
from datetime import datetime, timedelta

# string processing
import re
from io import StringIO

# FUNCTION: convert txt to dataframe
def convert_local_chat_to_df(file):
    chats = []

    regex_time = r'\d{2}:\d{2}:\d{2}'
    # regex_author = r'\bFrom \s(.*?:)'

    for line in file.split('\n'):

        info = re.search(regex_time, line)
        if info is not None:
            time = info.group()

            if "privately" in line:
                author = re.split(' to ', line.strip()[14:], flags=re.IGNORECASE)
                sender = author[0].strip()
                temporary = re.split(' : ', author[1].strip(), flags=re.IGNORECASE)
                receiver = temporary[0].replace('(privately)', '')
                message = temporary[1]
            elif "Direct Message" in line:
                author = re.split(' to ', line.strip()[14:], flags=re.IGNORECASE)
                sender = author[0].strip()
                temporary = re.split(' : ', author[1].strip(), flags=re.IGNORECASE)
                receiver = temporary[0].replace('(Direct Message)', '')
                message = temporary[1]
            else:
                author = re.split(' : ', line.strip()[14:], flags=re.IGNORECASE)
                sender = author[0].strip()
                receiver = "Everyone"
                message = author[1].strip()

            # author = re.search(regex_author, line).group()
            # sender = author.split(' to ')[0].replace('From', '').strip()
            # receiver = author.split(' to ')[1].replace(':', '').replace('(Direct Message)', '').strip()
        # else:
        #     message = line.strip()

            chat = {
                'time': time,
                'from': sender,
                'to': receiver,
                'message': message
            }

            chats.append(chat)

    return pd.DataFrame(chats)

# read uploaded txt file and convert to dataframe
uploaded_file = open("meeting_saved_chat.txt", "r", encoding="utf-8")
# stringio = StringIO(uploaded_file.getvalue().decode("utf-8"))
string_data = uploaded_file.read()
chats_df = convert_local_chat_to_df(string_data)