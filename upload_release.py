#!/usr/bin/python2.7

from github import Github
import argparse
import collections
import getpass
import glob
import json
import mimetypes
import os

parser = argparse.ArgumentParser(description='Patch in a section of the Arduino tools JSON')
parser.add_argument('--user', help="Github username", type=str, required=True)
parser.add_argument('--pw', help="Github password", type=str)
parser.add_argument('--tag', help="Release tag", type=str, required=True)
parser.add_argument('--name', help="Release name", type=str, required=True)
parser.add_argument('--msg', help="Release message", type=str, required=True)
parser.add_argument('files', nargs=argparse.REMAINDER)
args = parser.parse_args()

if len(args.files) == 0:
    print "ERROR:  No files specified"
    quit()

password = args.pw
if password is None:
    password = getpass.getpass("Github password:")

gh = Github(args.user, password)
repo = gh.get_repo(args.user + "/esp-quick-toolchain")
release = repo.create_git_release(args.tag, args.name, args.msg, draft=True)
for fn in args.files:
    print "Uploading file: " + fn
    release.upload_asset(fn)
