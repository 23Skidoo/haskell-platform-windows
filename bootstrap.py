#! /usr/bin/env python

# Bootstrap script for the Haskell Platform Windows installer. Written in
# Python cause I can't depend on necessary Haskell libs being installed.

# TODO
# * Move the lib dir to $GHC_DIR/extralibs
# * Modify $GHC_DIR/package.conf
# * Copy $GHC_DIR to $PWD/files
# * Add icons

extrallibs = [("network", "2.2.1.4"),
              ("HTTP", "4000.0.6"),
              ("zlib", "0.5.0.0"),
              ("time", "1.1.2.4"),
              ("cgi", "3001.1.7.1"),
              ("fgl", "5.4.2.2"),
              ("GLUT", "2.1.1.2"),
              ("OpenGL", "2.2.1.1")]

extratools = [("alex", "2.3.1"),
              ("happy", "1.18.4"),
              ("cabal-install", "0.6.2")]

def install(lib):
    name, version = lib

def main():
    for lib in (extralibs + extratools):
        install(lib)

if __name__ == "__main__":
    main()
