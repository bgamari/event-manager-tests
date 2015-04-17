#!/bin/bash

mkfifo test
echo "hello world" > test &
./TestMultishot
rm test

