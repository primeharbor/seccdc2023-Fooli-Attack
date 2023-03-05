#!/usr/bin/env python3
"""
Very simple HTTP server in python for logging requests
Usage::
    ./server.py [<port>]
"""
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging
from requests_toolbelt.multipart import decoder
from cgi import parse_header, parse_multipart
import datetime as dt



class HandlerClass(BaseHTTPRequestHandler):

    def _set_response(self):
        url = f"http://169.254.169.254/latest/meta-data/{args.imds_path}"
        self.send_response(301)
        self.send_header('Location', url)
        logger.info(f"Redirecting to {url}")
        self.end_headers()

    def do_GET(self):
        logger.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))
        self._set_response()
        self.wfile.write("GET request for {}".format(self.path).encode('utf-8'))

    def do_POST(self):

        ctype, pdict = parse_header(self.headers.get('Content-Type'))
        pdict['boundary'] = bytes(pdict['boundary'], "utf-8")
        if ctype == 'multipart/form-data':
            postvars = parse_multipart(self.rfile, pdict, encoding='utf-8')
        elif ctype == 'application/x-www-form-urlencoded':
            length = int(self.headers['content-length'])
            postvars = parse_qs(
                    self.rfile.read(length),
                    keep_blank_values=1)
        else:
            postvars = {}

        print(f"-------- {dt.datetime.now()} ---------")
        for k in postvars.keys():
            print(f"export {k}={postvars[k][0]}")
            # self.wfile.write(f"export {k}={postvars[k][0]}".encode('utf-8'))


def main(args, logger):
    server_address = ('', args.port)

    httpd = HTTPServer(server_address, HandlerClass)
    logger.info('Starting httpd...\n')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logger.info('Stopping httpd...\n')


def do_args():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--debug", help="print debugging info", action='store_true')
    parser.add_argument("--error", help="print error info only", action='store_true')
    parser.add_argument("--timestamp", help="Output log with timestamp and toolname", action='store_true')

    parser.add_argument("--port", help="Listen on this port", required=True, type=int)
    parser.add_argument("--imds-path", help="metadata path", required=True)


    args = parser.parse_args()

    return(args)

if __name__ == '__main__':

    global args
    args = do_args()

    # Logging idea stolen from: https://docs.python.org/3/howto/logging.html#configuring-logging
    # create console handler and set level to debug
    global logger
    logger = logging.getLogger('enable-vpc-flowlogs')
    ch = logging.StreamHandler()
    if args.debug:
        logger.setLevel(logging.DEBUG)
    elif args.error:
        logger.setLevel(logging.ERROR)
    else:
        logger.setLevel(logging.INFO)

    # Silence Boto3 & Friends
    logging.getLogger('botocore').setLevel(logging.WARNING)
    logging.getLogger('boto3').setLevel(logging.WARNING)
    logging.getLogger('urllib3').setLevel(logging.WARNING)

    # create formatter
    if args.timestamp:
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    else:
        formatter = logging.Formatter('%(levelname)s - %(message)s')

    # add formatter to ch (console handler)
    ch.setFormatter(formatter)
    # add ch to logger
    logger.addHandler(ch)

    try:
        main(args, logger)
    except KeyboardInterrupt:
        exit(1)