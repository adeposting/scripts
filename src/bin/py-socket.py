#!/usr/bin/env python3
"""
Socket CLI - A command-line wrapper for socket module

This script provides CLI-friendly functions that wrap socket module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import socket
import sys
from typing import Any, Dict, List, Optional


def gethostbyname(hostname: str) -> str:
    """Get IP address from hostname."""
    return socket.gethostbyname(hostname)


def gethostbyaddr(ip_address: str) -> Dict[str, Any]:
    """Get hostname and aliases from IP address."""
    hostname, aliases, addresses = socket.gethostbyaddr(ip_address)
    return {
        'hostname': hostname,
        'aliases': aliases,
        'addresses': addresses
    }


def getfqdn(hostname: str = '') -> str:
    """Get fully qualified domain name."""
    return socket.getfqdn(hostname)


def getservbyname(service: str, protocol: str = 'tcp') -> int:
    """Get port number from service name."""
    return socket.getservbyname(service, protocol)


def getservbyport(port: int, protocol: str = 'tcp') -> str:
    """Get service name from port number."""
    return socket.getservbyport(port, protocol)


def getaddrinfo(host: str, port: Optional[int] = None, family: int = 0, 
               type: int = 0, proto: int = 0, flags: int = 0) -> List[tuple]:
    """Get address information."""
    return socket.getaddrinfo(host, port, family, type, proto, flags)


def getnameinfo(sockaddr: tuple, flags: int = 0) -> tuple:
    """Get name information from socket address."""
    return socket.getnameinfo(sockaddr, flags)


def get_constants() -> Dict[str, Any]:
    """Get all socket constants dynamically."""
    constants = {}
    for attr_name in dir(socket):
        if attr_name.isupper() and not attr_name.startswith('_'):
            try:
                value = getattr(socket, attr_name)
                constants[attr_name] = value
            except (AttributeError, TypeError):
                continue
    return constants


def get_family_constants() -> Dict[str, int]:
    """Get socket family constants."""
    return {name: value for name, value in get_constants().items() 
            if name.startswith('AF_')}


def get_type_constants() -> Dict[str, int]:
    """Get socket type constants."""
    return {name: value for name, value in get_constants().items() 
            if name.startswith('SOCK_')}


def get_protocol_constants() -> Dict[str, int]:
    """Get protocol constants."""
    return {name: value for name, value in get_constants().items() 
            if name.startswith('IPPROTO_')}


def get_flag_constants() -> Dict[str, int]:
    """Get flag constants."""
    return {name: value for name, value in get_constants().items() 
            if name.startswith('MSG_') or name.startswith('SOL_')}


def create_socket(family: int = socket.AF_INET, type: int = socket.SOCK_STREAM, 
                 proto: int = 0) -> Dict[str, Any]:
    """Create a socket and return its properties."""
    sock = socket.socket(family, type, proto)
    return {
        'family': family,
        'type': type,
        'protocol': proto,
        'fileno': sock.fileno(),
        'timeout': sock.gettimeout()
    }


def socket_info(family: int = socket.AF_INET, type: int = socket.SOCK_STREAM) -> Dict[str, Any]:
    """Get socket information without creating it."""
    return {
        'family': family,
        'type': type,
        'family_name': socket.AddressFamily(family).name,
        'type_name': socket.SocketKind(type).name
    }


def main():
    parser = argparse.ArgumentParser(
        description="Socket CLI - A command-line wrapper for socket module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-socket gethostbyname google.com
  py-socket gethostbyaddr 8.8.8.8
  py-socket getfqdn
  py-socket getservbyname http
  py-socket get-constants
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Host and address commands
    gethostbyname_parser = subparsers.add_parser('gethostbyname', help='Get IP address from hostname')
    gethostbyname_parser.add_argument('hostname', help='Hostname to resolve')
    
    gethostbyaddr_parser = subparsers.add_parser('gethostbyaddr', help='Get hostname from IP address')
    gethostbyaddr_parser.add_argument('ip_address', help='IP address to resolve')
    
    getfqdn_parser = subparsers.add_parser('getfqdn', help='Get fully qualified domain name')
    getfqdn_parser.add_argument('hostname', nargs='?', default='', help='Hostname (optional)')
    
    # Service commands
    getservbyname_parser = subparsers.add_parser('getservbyname', help='Get port from service name')
    getservbyname_parser.add_argument('service', help='Service name')
    getservbyname_parser.add_argument('--protocol', default='tcp', help='Protocol (tcp/udp)')
    
    getservbyport_parser = subparsers.add_parser('getservbyport', help='Get service name from port')
    getservbyport_parser.add_argument('port', type=int, help='Port number')
    getservbyport_parser.add_argument('--protocol', default='tcp', help='Protocol (tcp/udp)')
    
    # Address info commands
    getaddrinfo_parser = subparsers.add_parser('getaddrinfo', help='Get address information')
    getaddrinfo_parser.add_argument('host', help='Hostname')
    getaddrinfo_parser.add_argument('port', nargs='?', type=int, help='Port number (optional)')
    getaddrinfo_parser.add_argument('--family', type=int, default=0, help='Address family')
    getaddrinfo_parser.add_argument('--type', type=int, default=0, help='Socket type')
    getaddrinfo_parser.add_argument('--proto', type=int, default=0, help='Protocol')
    getaddrinfo_parser.add_argument('--flags', type=int, default=0, help='Flags')
    
    getnameinfo_parser = subparsers.add_parser('getnameinfo', help='Get name information')
    getnameinfo_parser.add_argument('host', help='Hostname or IP')
    getnameinfo_parser.add_argument('port', type=int, help='Port number')
    getnameinfo_parser.add_argument('--flags', type=int, default=0, help='Flags')
    
    # Constant commands
    subparsers.add_parser('get-constants', help='Get all socket constants')
    subparsers.add_parser('get-family-constants', help='Get socket family constants')
    subparsers.add_parser('get-type-constants', help='Get socket type constants')
    subparsers.add_parser('get-protocol-constants', help='Get protocol constants')
    subparsers.add_parser('get-flag-constants', help='Get flag constants')
    
    # Socket creation commands
    create_socket_parser = subparsers.add_parser('create-socket', help='Create a socket')
    create_socket_parser.add_argument('--family', type=int, default=socket.AF_INET, help='Address family')
    create_socket_parser.add_argument('--type', type=int, default=socket.SOCK_STREAM, help='Socket type')
    create_socket_parser.add_argument('--proto', type=int, default=0, help='Protocol')
    
    socket_info_parser = subparsers.add_parser('socket-info', help='Get socket information')
    socket_info_parser.add_argument('--family', type=int, default=socket.AF_INET, help='Address family')
    socket_info_parser.add_argument('--type', type=int, default=socket.SOCK_STREAM, help='Socket type')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'gethostbyname':
            if args.dry_run:
                print(f"Would resolve hostname: {args.hostname}")
                return
            result = gethostbyname(args.hostname)
        elif args.command == 'gethostbyaddr':
            if args.dry_run:
                print(f"Would resolve IP address: {args.ip_address}")
                return
            result = gethostbyaddr(args.ip_address)
        elif args.command == 'getfqdn':
            if args.dry_run:
                print(f"Would get FQDN for: {args.hostname or 'current host'}")
                return
            result = getfqdn(args.hostname)
        elif args.command == 'getservbyname':
            if args.dry_run:
                print(f"Would get port for service: {args.service} ({args.protocol})")
                return
            result = getservbyname(args.service, args.protocol)
        elif args.command == 'getservbyport':
            if args.dry_run:
                print(f"Would get service for port: {args.port} ({args.protocol})")
                return
            result = getservbyport(args.port, args.protocol)
        elif args.command == 'getaddrinfo':
            if args.dry_run:
                print(f"Would get address info for: {args.host}:{args.port}")
                return
            result = getaddrinfo(args.host, args.port, args.family, args.type, args.proto, args.flags)
        elif args.command == 'getnameinfo':
            if args.dry_run:
                print(f"Would get name info for: {args.host}:{args.port}")
                return
            sockaddr = (args.host, args.port)
            result = getnameinfo(sockaddr, args.flags)
        elif args.command == 'get-constants':
            result = get_constants()
        elif args.command == 'get-family-constants':
            result = get_family_constants()
        elif args.command == 'get-type-constants':
            result = get_type_constants()
        elif args.command == 'get-protocol-constants':
            result = get_protocol_constants()
        elif args.command == 'get-flag-constants':
            result = get_flag_constants()
        elif args.command == 'create-socket':
            if args.dry_run:
                print(f"Would create socket: family={args.family}, type={args.type}, proto={args.proto}")
                return
            result = create_socket(args.family, args.type, args.proto)
        elif args.command == 'socket-info':
            result = socket_info(args.family, args.type)
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                if isinstance(result, (dict, list)):
                    print(json.dumps(result, indent=2))
                else:
                    print(result)
                    
    except Exception as e:
        if args.verbose:
            import traceback
            traceback.print_exc()
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main() 