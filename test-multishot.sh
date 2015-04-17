#!/bin/bash

mkfifo test
echo "hello world this looks good" > test &
./TestMultishot
rm test

