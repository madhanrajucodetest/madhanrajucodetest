import re

regex = '([a-zA-Z0-9_.-])+@([a-zA-Z0-9])+.([a-zA-Z0-9])+'

def validate_Email(email_value):
    if(re.search(regex,email_value)):
        return 'valid'
    else:
        return 'invalid'