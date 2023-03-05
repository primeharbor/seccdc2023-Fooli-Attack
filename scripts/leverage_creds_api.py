#!/usr/bin/env python3
# Copyright 2022 - Chris Farris (chrisf@primeharbor.com) - All Rights Reserved
#
# NOTE: This code artifact is NOT licensed under an OpenSource license. You have access to it via an existing
# arrangement for training purposes only, but it may not be distributed further without violating Copyright Law.

from os import path
from typing import Dict
import json
import jwt
import os
import time
import urllib3
import datetime as dt


# This code mostly adapted from https://testdriven.io/blog/fastapi-jwt-auth/
# and the corresponding repo https://github.com/testdrivenio/fastapi-jwt


def main(args):
    http = urllib3.PoolManager()
    auth_token_payload = {"clear_text_password": args.password}
    r = http.request('POST', f"https://{args.url}/auth/{args.username}", body=json.dumps(auth_token_payload))
    if r.status != 200:
        print(f"Error getting creds: {r.data} - {r.status}")
        exit(1)

    token = json.loads(r.data.decode('utf-8'))['access_token']

    print(f"# JWT {token}")

    # exit(1)
    print (f"# Timestamp for timeline: {dt.datetime.now()}")

    if type(token) == str:
        headers = {
            "accept": "application/json",
            "Authorization": f"Bearer {token}"
        }
    else:
        headers = {
            "accept": "application/json",
            "Authorization": f"Bearer {token.decode('utf-8')}"
        }

    # print(json.dumps(headers))

    r = http.request('GET', f"https://{args.url}/debug/", headers=headers)

    if r.status != 200:
        print(f"Error getting creds: {r.data} - {r.status}")
        exit(1)

    creds = json.loads(r.data.decode('utf-8'))
    output = f"""
export AWS_DEFAULT_REGION=us-east-1
export AWS_SECRET_ACCESS_KEY={creds['SecretAccessKey']}
export AWS_ACCESS_KEY_ID={creds['AccessKeyId']}
export AWS_SESSION_TOKEN={creds['Token']}
"""
    print(output)



# curl -X 'GET' \
# >   'https://fooli-api.dev1.fooli.media/creds/' \
# >   -H 'accept: application/json' \
# >   -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZnJhbmsiLCJleHBpcmVzIjoxNjU4MTQ4NDcwLjc4NjQwMzJ9.NdNpWwQoBOu60f7jMtNYrT2oJlsgL-oOq8Hn5GDDT_Y'


def do_args():
    import argparse
    parser = argparse.ArgumentParser()
    # parser.add_argument("--jwt-secret", help="JWT Secret", required=True)
    # parser.add_argument("--jwt-algorithm", help="JWT algorithm",  default="HS256")
    # parser.add_argument("--jwt-expires", help="JWT expires",  default=3600)
    parser.add_argument("--username")
    parser.add_argument("--password")

    parser.add_argument("--url", help="URL To hit", required=True)

    args = parser.parse_args()

    return(args)

if __name__ == '__main__':

    args = do_args()
    try:
        main(args)
    except KeyboardInterrupt:
        exit(1)









