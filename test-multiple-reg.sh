#!/bin/bash

(sleep 1; echo hello) | nc -l localhost 7777 &

./TestMultipleReg

