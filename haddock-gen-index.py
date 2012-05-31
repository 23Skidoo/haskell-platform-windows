#! /usr/bin/env python

import os.path
import subprocess

# Change this to the appropriate version.
GHC_DIR = "C:\\ghc\\ghc-7.4.1"
TOPDIR = GHC_DIR + "\\lib"
LIBRARIES_DIR = GHC_DIR + "\\doc\\html\\libraries"

def get_field(pkg, fld):
    ret = subprocess.check_output(["ghc-pkg", "field", pkg, fld])
    return ret.strip()[len(fld)+2:]

read_intf=""
pkgs = subprocess.check_output(["ghc-pkg", "list", "--simple-output"]).split()
for pkg in pkgs:
    html = os.path.abspath(get_field(pkg, "haddock-html")) 
    html = html.replace(TOPDIR, "..\\..\\..\\lib")
    html = html.replace(LIBRARIES_DIR, ".")
    intf = os.path.abspath(get_field(pkg, "haddock-interfaces"))

    valid = True

    if pkg.startswith("ghc-"):
        valid = False
    if pkg.startswith("ghc-prim-"):
        valid = True
    if pkg.startswith("rts-"):
        valid = False
    if not os.path.isfile(intf):
        valid = False
        print "Invalid interface: " + intf

    if valid:
        read_intf += (" --read-interface=" + html + ","+ intf)

cmd_line = ["haddock", "--gen-index", 
            "--gen-contents", "--title=Haskell Platform"] + read_intf.split()
subprocess.check_output(cmd_line)
