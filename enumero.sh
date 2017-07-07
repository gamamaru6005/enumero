#!/bin/bash

usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }

while getopts ":i:d:e:" option
do
    case "${option}" in
        i)
            IP_ADDRESS=${OPTARG}
            ;;
        d)
            WORK_DIRECTORY=${OPTARG}
            ;;
        e)
            INTERFACE=${OPTARG}
            ;;
        *) 
            usage
    esac
done
shift "$((OPTIND-1))"
