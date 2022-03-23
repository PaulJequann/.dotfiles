#!/usr/bin/env pythonmisc3

import requests
import os

response = requests.get('https://api.gemini.com/v2/ticker/btcusd')
jsonResponse = response.json()

def format_num(num):
    num = float('{:.3g}'.format(num))
    magnitude = 0
    while abs(num) >= 1000:
        magnitude += 1
        num /= 1000.0
    return '{}{}'.format('{:f}'.format(num).rstrip('0').rstrip('.'), ['', 'K', 'M', 'B', 'T'][magnitude])


price = format_num(float(jsonResponse["bid"]))
os.system('sketchybar -m --set btc label='+ price)
