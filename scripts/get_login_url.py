#!/usr/bin/env python3

import datetime
import json
import sys
import time
import urllib.parse
# import boto3
import requests
import os

def construct_federated_url(args):
    """
    Constructs a URL that gives federated users direct access to the AWS Management
    Console.

    Function adapted from https://docs.aws.amazon.com/IAM/latest/UserGuide/example_sts_Scenario_ConstructFederatedUrl_section.html

    1. Pulls session creds from environment
    2. Uses the temporary credentials to request a sign-in token from the
       AWS federation endpoint.
    3. Builds a URL that can be used in a browser to navigate to the AWS federation
       endpoint, includes the sign-in token for authentication, and redirects to
       the AWS Management Console with permissions defined by the role that was
       specified in step 1.

    """

    session_data = {
        'sessionId': os.environ['AWS_ACCESS_KEY_ID'],
        'sessionKey': os.environ['AWS_SECRET_ACCESS_KEY'],
        'sessionToken': os.environ['AWS_SESSION_TOKEN']
    }
    aws_federated_signin_endpoint = 'https://signin.aws.amazon.com/federation'
    # aws_federated_signin_endpoint = 'https://us-east-1.signin.aws.amazon.com/federation'


    # Make a request to the AWS federation endpoint to get a sign-in token.
    # The requests.get function URL-encodes the parameters and builds the query string
    # before making the request.
    response = requests.get(
        aws_federated_signin_endpoint,
        params={
            'Action': 'getSigninToken',
            # 'SessionDuration': str(datetime.timedelta(hours=12).seconds),
            'Session': json.dumps(session_data)
        })
    if response.status_code != 200:
        print(f"Error ({response.status_code}) Getting Sign In Token")
        exit(0)

    signin_token = json.loads(response.text)
    print(f"Got a sign-in token from the AWS sign-in federation endpoint.")

    # Make a federated URL that can be used to sign into the AWS Management Console.
    query_string = urllib.parse.urlencode({
        'Action': 'login',
        'Issuer': args.issuer,
        'Destination': 'https://us-east-1.console.aws.amazon.com/',
        'SigninToken': signin_token['SigninToken']
    })
    print(f'{aws_federated_signin_endpoint}?{query_string}')



def do_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--issuer", help="Issuer (shows up in logs)", default="aws-console")

    args = parser.parse_args()

    return(args)

if __name__ == '__main__':

    args = do_args()
    try:
        construct_federated_url(args)
    except KeyboardInterrupt:
        exit(1)
