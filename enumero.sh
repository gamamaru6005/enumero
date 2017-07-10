#!/bin/bash

RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

usage() { 
    cat<<EOF
    Usage: $0 <Options>
    
    This script does stuff...
    
    OPTIONS:
        -h..................Get help
        -i <IP>.............IP Address
        -d <Directory>......Work Directory
        -e <Interface>......Interface
EOF
    exit 1
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
            mkdir -p ${WORK_DIRECTORY}/raw
            ;;
        e)
            INTERFACE=${OPTARG}
            ;;
        ?) 
            echo -e "${RED}    ERROR: Invalid option: -${OPTARG}\n${NC}" >&2
            usage
            exit
            ;;
    esac
done
shift "$((OPTIND-1))"

# Check that required flags are there
if [[ -z ${IP_ADDRESS} ]] || [[ -z ${WORK_DIRECTORY} ]] || [[ -z ${INTERFACE} ]]
then
    usage
    exit 1
fi

# Check for root (some tools require root for certain activities):
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}    ERROR: This script must be run as root${NC}"
    exit 1
fi

echo -e "${BLUE}\n*** nmap -n -sn ${IP_ADDRESS} -oA ${WORK_DIRECTORY}/raw/nmap_ping_sweep__${IP_ADDRESS/\//_} ***\n${NC}"
nmap -n -sn ${IP_ADDRESS} -oA ${WORK_DIRECTORY}/raw/nmap_ping_sweep__${IP_ADDRESS/\//_}

echo -e "${BLUE}\n*** unicornscan -i ${INTERFACE} -Iv -mT -r7500 ${IP_ADDRESS}:0-65535 | tee ${WORK_DIRECTORY}/raw/unicornscan_tcp_port_sweep__${IP_ADDRESS/\//_} ***\n${NC}"
# For a list of IP addresses, need to do unicornscan [IP]:0-65535 [IP]:0-65535 etc.
unicornscan -i ${INTERFACE} -Iv -mT -r7500 ${IP_ADDRESS}:0-65535 | tee ${WORK_DIRECTORY}/raw/unicornscan_tcp_port_sweep__${IP_ADDRESS/\//_}

awk '/^scaning/{flag=1;next}/^sender/{flag=0}flag' ${WORK_DIRECTORY}/raw/unicornscan_port_sweep__${IP_ADDRESS/\//_} | awk '/.+/ {print $3}' | sort -t: -nk2 | gawk -F: '
    /.+/{
            if (!($1 in arr)) { key[++i] = $1; }
            arr[$1] = arr[$1] $2 ",";
        }
    END {
        for (j = 1; j <= i; j++) {
            printf("%s:%s%s",  key[j], arr[key[j]], (j == i) ? "" : "\n");
        }
    }' | sed 's/,$//' | sort -t: -nk1 > ${WORK_DIRECTORY}/discovered_hosts.txt
