#!/usr/bin/env python3
from ipydex import IPS, ip_syshook, ST, activate_ips_on_exception, dirsearch
activate_ips_on_exception()

from brish import z
import datetime
now = datetime.datetime.now()
import os.path
import traceback
from IPython import embed
from plumbum import local
import tempfile
import base64
from email.mime.audio import MIMEAudio
from email.mime.base import MIMEBase
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import mimetypes
import os
import datetime
import re
import copy
import sys
from bs4 import BeautifulSoup, SoupStrainer
import requests
from urllib.parse import urlparse

import importlib.util

spec = importlib.util.spec_from_file_location(
    "tsend", local.env["NIGHTDIR"] + "/python/telegram-send/tsend.py"
)
ts = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ts)
from syncer import sync
tsend = sync(ts.tsend)

# zsh = local["zsh"]["-c"]
# local.env['pkDel'] = 'y'
os.environ['pkDel'] = 'y'
lblProcessed = "Label_7772537585229918833"
lblTest = "Label_4305264623189976109"


def ecerr(str):
    print(f"{date}           {str}", file=sys.stderr)


tokenpath = local.env["HOME"] + "/.gmail.token"
credpath = local.env["HOME"] + "/.gmail.credentials.json"
import ezgmail as g

g.init(tokenFile=tokenpath, credentialsFile=credpath)
service = g.SERVICE_GMAIL


def printLabels():
    results = service.users().labels().list(userId="me").execute()
    labels = results.get("labels", [])

    if not labels:
        print("No labels found.")
    else:
        print("Labels:")
        for label in labels:
            print(label["name"] + " " + label["id"])


def parseContentTypeHeaderForEncoding(value):
    """Helper function called by GmailMessage:__init__()."""
    mo = re.search('charset="(.*?)"', value)
    if mo is None:
        emailEncoding = "UTF-8"  # We're going to assume UTF-8 and hope for the best. Safety not guaranteed.
    else:
        emailEncoding = mo.group(1)
    return emailEncoding


def getHtml(messageObj):
    emailEncoding = "UTF-8"  # We're going to assume UTF-8 and hope for the best. Safety not guaranteed.
    r = ""

    def frompart(part):
        if part["mimeType"].upper() == "TEXT/HTML" and "data" in part["body"]:
            for header in part["headers"]:
                if header["name"].upper() == "CONTENT-TYPE":
                    emailEncoding = parseContentTypeHeaderForEncoding(header["value"])
            return base64.urlsafe_b64decode(part["body"]["data"]).decode(emailEncoding)

    if "parts" in messageObj["payload"].keys():
        for part in messageObj["payload"]["parts"]:
            r = frompart(part)
            if r:
                return r
    elif "body" in messageObj["payload"].keys():
        r = frompart(messageObj["payload"])
    return r


# unprocessed
news = g.search(
    "((from:tldrnewsletter.com) AND NOT label:auto/processed)", maxResults=20
)


def labelnews(msg):
    # msg.addLabel(lblTest)
    msg.addLabel(lblProcessed)


for t in news:
    # actually these are threads not messages
    for m in t.messages:
        bodyhtml = getHtml(m.messageObj)
        if not bodyhtml:
            ecerr(f"Couldn't extract html body of message {m.subject}")
            ecerr("Printing its messageObj:")
            ecerr(m.messageObj)
            ecerr("")
            ecerr("")
            labelnews(m)
            continue
        body = tempfile.NamedTemporaryFile(mode="w", suffix=".html")
        print(bodyhtml, file=body, flush=True)
        # cmd = f"dpan h2e 'TLDR | {m.subject}' {body.name}"
        # e, out, err = zsh[f"{cmd}"].run()
        
        s = BeautifulSoup(bodyhtml, features="lxml")
        items = s.find_all("div", {"class": "text-block"})
        try:
            tsend_cmd = ["--parse-mode", "html", "--link-preview", "https://t.me/tldrnewsletter", '']
            tsend_args = ts.parse_tsend(tsend_cmd)
            embed()
            for n in items[1:2] + items[4:-2]:
                for link in n.select('a'):
                    # print(link.__dict__)
                    link['href'] = z("urlfinalg {link['href']}") # (zsh["inargs urlfinalg"] << link['href'])()
                    # print(link['href'])
                tsend_args['<message>'] = n
                tsend(tsend_args)
        except:
            ecerr("")
            ecerr("Failed to send this item to Telegram:")
            ecerr("")
            ecerr(traceback.format_exc())
            ecerr("")
        if e == 0:
            labelnews(m)
            print(f"Processed {m.subject} ...")
        else:
            ecerr("")
            ecerr(f"h2e exited nonzero; cmd: {cmd}")
            ecerr("Out:")
            ecerr(out)
            ecerr("")
            ecerr("Err:")
            ecerr(err)
            ecerr("")
            ecerr("End of current report")
        body.close()  # This file is deleted immediately upon closing it.
# embed()
