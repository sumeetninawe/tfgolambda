#!/bin/bash

# Script required to build the lambda function code to binary.
# Append this script as more functions are added.

cd ./aws/functionOne/
if [ -f "func_one" ] 
then
    rm func_one
fi
pwd
cd ./code/
if [ -f "main" ] 
then
    rm main
fi
go mod tidy
GOOS=linux go build main.go
