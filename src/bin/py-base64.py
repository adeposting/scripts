#!/usr/bin/env python3
"""
Base64 CLI - A command-line wrapper for base64 module

This script provides CLI-friendly functions that wrap base64 module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import base64
import sys
from typing import Union


def b64encode(data: Union[str, bytes]) -> str:
    """Encode data to base64."""
    if isinstance(data, str):
        data = data.encode('utf-8')
    return base64.b64encode(data).decode('utf-8')


def b64decode(data: str) -> str:
    """Decode base64 data."""
    return base64.b64decode(data).decode('utf-8')


def b32encode(data: Union[str, bytes]) -> str:
    """Encode data to base32."""
    if isinstance(data, str):
        data = data.encode('utf-8')
    return base64.b32encode(data).decode('utf-8')


def b32decode(data: str) -> str:
    """Decode base32 data."""
    return base64.b32decode(data).decode('utf-8')


def b16encode(data: Union[str, bytes]) -> str:
    """Encode data to base16."""
    if isinstance(data, str):
        data = data.encode('utf-8')
    return base64.b16encode(data).decode('utf-8')


def b16decode(data: str) -> str:
    """Decode base16 data."""
    return base64.b16decode(data).decode('utf-8')


def urlsafe_b64encode(data: Union[str, bytes]) -> str:
    """Encode data to URL-safe base64."""
    if isinstance(data, str):
        data = data.encode('utf-8')
    return base64.urlsafe_b64encode(data).decode('utf-8')


def urlsafe_b64decode(data: str) -> str:
    """Decode URL-safe base64 data."""
    return base64.urlsafe_b64decode(data).decode('utf-8')


def encode_file(file_path: str, encoding: str = 'b64') -> str:
    """Encode file content."""
    with open(file_path, 'rb') as f:
        data = f.read()
    
    if encoding == 'b64':
        return b64encode(data)
    elif encoding == 'b32':
        return b32encode(data)
    elif encoding == 'b16':
        return b16encode(data)
    elif encoding == 'urlsafe':
        return urlsafe_b64encode(data)
    else:
        raise ValueError(f"Unknown encoding: {encoding}")


def decode_file(file_path: str, encoding: str = 'b64') -> str:
    """Decode file content."""
    with open(file_path, 'r') as f:
        data = f.read().strip()
    
    if encoding == 'b64':
        return b64decode(data)
    elif encoding == 'b32':
        return b32decode(data)
    elif encoding == 'b16':
        return b16decode(data)
    elif encoding == 'urlsafe':
        return urlsafe_b64decode(data)
    else:
        raise ValueError(f"Unknown encoding: {encoding}")


def main():
    parser = argparse.ArgumentParser(
        description="Base64 CLI - A command-line wrapper for base64 module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-base64 b64encode "Hello, World!"
  py-base64 b64decode "SGVsbG8sIFdvcmxkIQ=="
  py-base64 encode-file data.txt --encoding b64
  py-base64 decode-file encoded.txt --encoding b64
  py-base64 urlsafe-b64encode "Hello, World!"
        """
    )
    
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Base64 commands
    b64encode_parser = subparsers.add_parser('b64encode', help='Encode data to base64')
    b64encode_parser.add_argument('data', help='Data to encode')
    
    b64decode_parser = subparsers.add_parser('b64decode', help='Decode base64 data')
    b64decode_parser.add_argument('data', help='Base64 data to decode')
    
    # Base32 commands
    b32encode_parser = subparsers.add_parser('b32encode', help='Encode data to base32')
    b32encode_parser.add_argument('data', help='Data to encode')
    
    b32decode_parser = subparsers.add_parser('b32decode', help='Decode base32 data')
    b32decode_parser.add_argument('data', help='Base32 data to decode')
    
    # Base16 commands
    b16encode_parser = subparsers.add_parser('b16encode', help='Encode data to base16')
    b16encode_parser.add_argument('data', help='Data to encode')
    
    b16decode_parser = subparsers.add_parser('b16decode', help='Decode base16 data')
    b16decode_parser.add_argument('data', help='Base16 data to decode')
    
    # URL-safe base64 commands
    urlsafe_b64encode_parser = subparsers.add_parser('urlsafe-b64encode', help='Encode data to URL-safe base64')
    urlsafe_b64encode_parser.add_argument('data', help='Data to encode')
    
    urlsafe_b64decode_parser = subparsers.add_parser('urlsafe-b64decode', help='Decode URL-safe base64 data')
    urlsafe_b64decode_parser.add_argument('data', help='URL-safe base64 data to decode')
    
    # File commands
    encode_file_parser = subparsers.add_parser('encode-file', help='Encode file content')
    encode_file_parser.add_argument('file_path', help='File to encode')
    encode_file_parser.add_argument('--encoding', choices=['b64', 'b32', 'b16', 'urlsafe'], 
                                   default='b64', help='Encoding type')
    
    decode_file_parser = subparsers.add_parser('decode-file', help='Decode file content')
    decode_file_parser.add_argument('file_path', help='File to decode')
    decode_file_parser.add_argument('--encoding', choices=['b64', 'b32', 'b16', 'urlsafe'], 
                                   default='b64', help='Encoding type')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'b64encode':
            result = b64encode(args.data)
        elif args.command == 'b64decode':
            result = b64decode(args.data)
        elif args.command == 'b32encode':
            result = b32encode(args.data)
        elif args.command == 'b32decode':
            result = b32decode(args.data)
        elif args.command == 'b16encode':
            result = b16encode(args.data)
        elif args.command == 'b16decode':
            result = b16decode(args.data)
        elif args.command == 'urlsafe-b64encode':
            result = urlsafe_b64encode(args.data)
        elif args.command == 'urlsafe-b64decode':
            result = urlsafe_b64decode(args.data)
        elif args.command == 'encode-file':
            if args.dry_run:
                print(f"Would encode file: {args.file_path} using {args.encoding}")
                return
            result = encode_file(args.file_path, args.encoding)
        elif args.command == 'decode-file':
            if args.dry_run:
                print(f"Would decode file: {args.file_path} using {args.encoding}")
                return
            result = decode_file(args.file_path, args.encoding)
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
            print(result)
                
    except Exception as e:
        if args.verbose:
            import traceback
            traceback.print_exc()
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main() 