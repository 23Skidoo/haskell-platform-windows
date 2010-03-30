#! /usr/bin/env python

import os
import os.path
import fileinput

DIR = "E:\\ghc\\ghc-6.12.1\\lib\\package.conf.d"
FILES = [os.path.join(DIR, f) for f in os.listdir(DIR) if f.endswith("conf")]

for line in fileinput.FileInput(FILES, inplace=1):
    print line.replace("E:\\\\Program Files (x86)\\\\Haskell", "$topdir\\\\extralibs"),
