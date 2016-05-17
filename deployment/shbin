#!/bin/bash
mkdir -p $2
echo "$2 is output"
java -jar $KB_TOP/lib/jars/meme/meme.jar $@ 2> $2/error.log
tar cvfz $2.tgz $2
rm -rf $2
