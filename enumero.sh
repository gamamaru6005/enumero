#!/bin/bash

usage() { 
    #echo "Usage: $0 -i <IP> -d <Work Directory> -e <Interface>]" 1>&2; exit 1; 
cat<<EOF
    Usage: $0 <Options>
    
    This script does stuff...
    
    OPTIONS:
        -h              Get help
        -i <IP>         IP Address
        -d <Directory>  Work Directory
        -e <Interface>  Interface
EOF
}

while getopts ":i:d:e:" option
do
    case "${option}" in
        h)
            usage
            exit 1
            ;;
        i)
            IP_ADDRESS=${OPTARG}
            ;;
        d)
            WORK_DIRECTORY=${OPTARG}
            ;;
        e)
            INTERFACE=${OPTARG}
            ;;
        ?) 
            echo -e "   ERROR: Invalid option: -$OPTARG\n" >&2
            usage
            exit
            ;;
    esac
done
shift "$((OPTIND-1))"

if [[ -z $IP_ADDRESS ]] || [[ -z $WORK_DIRECTORY ]] || [[ -z $INTERFACE ]]
then
    usage
    exit 1
fi

# Change colour
echo "nmap -n -sn $IP_ADDRESS -oA $WORK_DIRECTORY/raw/nmap_ping_sweep"
# Need to do escaping on the IP_ADDRESS
nmap -n -sn $IP_ADDRESS -oA "$WORK_DIRECTORY/raw/nmap_ping_sweep"

# Change colour
echo "unicornscan -i $INTERFACE -Iv -mT -r7500 $IP_ADDRESS:0-65535 | tee $WORK_DIRECTORY/unicornscan_port_sweep"
# Need to do escaping on IP_ADDRESS
unicornscan -i $INTERFACE -Iv -mT -r7500 $IP_ADDRESS:0-65535 | tee $WORK_DIRECTORY/unicornscan_port_sweep
