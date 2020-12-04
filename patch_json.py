#!/usr/bin/env python3

import argparse
import collections
import glob
import json
import os

parser = argparse.ArgumentParser(description='Patch in a section of the Arduino tools JSON')
parser.add_argument('--pkgfile', help="Arduino JSON file to update", type=str, required=True)
parser.add_argument('--tool', help="Name of tool to update", type=str, required=True)
parser.add_argument('--ver', help="Version of tool to update", type=str, required=True)
parser.add_argument('--glob', help="Glob to match for tool", type=str, required=True)
args = parser.parse_args()

# Load the JSON
with open(args.pkgfile) as f:
    data = json.load(f, object_pairs_hook=collections.OrderedDict)

for i in range(0, len(data["packages"][0]["platforms"][0]["toolsDependencies"])):
    if data["packages"][0]["platforms"][0]["toolsDependencies"][i]["name"] == args.tool:
        data["packages"][0]["platforms"][0]["toolsDependencies"][i]["version"] = args.ver

for i in range(0, len(data["packages"][0]["tools"])):
    if data["packages"][0]["tools"][i]["name"] == args.tool:
        print("Patching tool: " + args.tool + " to ver: " + args.ver)
        data["packages"][0]["tools"][i]["version"] = args.ver
        data["packages"][0]["tools"][i]["systems"] = []
        bins = glob.glob(args.glob)
        for j in sorted(glob.glob(args.glob)):
            with open(j) as s:
                print("Adding: " + j)
                part = json.load(s, object_pairs_hook=collections.OrderedDict)
                data["packages"][0]["tools"][i]["systems"].append(part)

print("Writing new file " + args.pkgfile)
with open(args.pkgfile, "w") as f:
    f.write(json.dumps(data, indent=3, separators=(',',': ')))
