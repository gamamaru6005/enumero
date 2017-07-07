#!/usr/bin/env python3

import os
import subprocess
import sys
import time

global ip_addresses
global work_directory
global interface
global header
ip_addresses = "10.11.1.1/24"
work_directory = "/root/OSCP/Labs"
interface = "tap0"
header = """                                                                               
   ___ _ __  _   _ _ __ ___   ___ _ __ ___  
  / _ \ '_ \| | | | '_ ` _ \ / _ \ '__/ _ \ 
 |  __/ | | | |_| | | | | | |  __/ | | (_) |
  \___|_| |_|\__,_|_| |_| |_|\___|_|  \___/ 
                                                                        
"""

def host_discovery():
    subprocess.run('clear')
    print("""
 {}                                
    """.format(header))
    # Run command and put output in file
    with open("{}/arp_scan".format(work_directory), "w+") as f:
        output = subprocess.run(["arp-scan", ip_addresses, "-I", interface], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        f.write("{}: arp-scan {} -I {}\n\n".format(time.ctime(), ip_addresses, interface))
        f.write(output.stdout.decode("utf-8"))

    # Process file and add output into report
    with open("{}/arp_scan".format(work_directory), "r") as f:
        print(f)

def main_menu():
    subprocess.run('clear')
    option = True
    while option:
        print("""
 {}

 IP Addresses = {}
 Work Directory = {}


    1. Complete enumeration
    2. Configure
    3. Exit

        """.format(header, ip_addresses, work_directory))
        option = input(" Select option: ")
        if option == "1":
            host_discovery()
        elif option == "2":
            configure()
        elif option == "3":
            exit()
        elif option != "":
            print("\n Error: Please select a valid option")


def configure():
    subprocess.run('clear')
    option = True
    while option:
        print("""
 {}

 IP Addresses = {}
 Work Directory = {}


    1. Set IP Addresses
    2. Set Working Directory
    3. Go back

        """.format(header, ip_addresses, work_directory))
        option = input(" Select option: ")
        if option == "1":
            global ip_addresses
            ip_addresses = input("\n IP addresses: ")
            configure()
        elif option == "2":
            global work_directory
            work_directory = input("\n Work directory: ")
            work_directory = "/root/OSCP/Labs/"
            configure()
        elif option == "3":
            main_menu()
        elif option != "":
            print("\n Error: Please select a valid option")

def exit():
    subprocess.run('clear')
    print("""                                             
 {}

 Goodbye!


    """.format(header))
    sys.exit()

if __name__ == "__main__":
    main_menu()
