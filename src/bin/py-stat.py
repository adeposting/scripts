#!/usr/bin/env python3
"""
Stat CLI - A command-line wrapper for stat module

This script provides CLI-friendly functions that wrap stat module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import os
import stat
import sys
from typing import Any, Dict, Optional


def s_isdir(mode: int) -> bool:
    """Check if mode indicates a directory."""
    return stat.S_ISDIR(mode)


def s_isreg(mode: int) -> bool:
    """Check if mode indicates a regular file."""
    return stat.S_ISREG(mode)


def s_islnk(mode: int) -> bool:
    """Check if mode indicates a symbolic link."""
    return stat.S_ISLNK(mode)


def s_imode(mode: int) -> int:
    """Get the file permission bits from mode."""
    return stat.S_IMODE(mode)


def s_ifmt(mode: int) -> int:
    """Get the file type bits from mode."""
    return stat.S_IFMT(mode)


def filemode(mode: int) -> str:
    """Convert mode to file mode string."""
    return stat.filemode(mode)


def s_ischr(mode: int) -> bool:
    """Check if mode indicates a character device."""
    return stat.S_ISCHR(mode)


def s_isblk(mode: int) -> bool:
    """Check if mode indicates a block device."""
    return stat.S_ISBLK(mode)


def s_isfifo(mode: int) -> bool:
    """Check if mode indicates a FIFO."""
    return stat.S_ISFIFO(mode)


def s_issock(mode: int) -> bool:
    """Check if mode indicates a socket."""
    return stat.S_ISSOCK(mode)


def s_isuid(mode: int) -> bool:
    """Check if mode has set-user-ID bit."""
    return bool(mode & stat.S_ISUID)


def s_isgid(mode: int) -> bool:
    """Check if mode has set-group-ID bit."""
    return bool(mode & stat.S_ISGID)


def s_isvtx(mode: int) -> bool:
    """Check if mode has sticky bit."""
    return bool(mode & stat.S_ISVTX)


def stat_file(path: str) -> Dict[str, Any]:
    """Get file stats and return detailed information."""
    stat_info = os.stat(path)
    return {
        'st_mode': stat_info.st_mode,
        'st_ino': stat_info.st_ino,
        'st_dev': stat_info.st_dev,
        'st_nlink': stat_info.st_nlink,
        'st_uid': stat_info.st_uid,
        'st_gid': stat_info.st_gid,
        'st_size': stat_info.st_size,
        'st_atime': stat_info.st_atime,
        'st_mtime': stat_info.st_mtime,
        'st_ctime': stat_info.st_ctime,
        'filemode': stat.filemode(stat_info.st_mode),
        'is_dir': stat.S_ISDIR(stat_info.st_mode),
        'is_file': stat.S_ISREG(stat_info.st_mode),
        'is_link': stat.S_ISLNK(stat_info.st_mode),
        'is_char': stat.S_ISCHR(stat_info.st_mode),
        'is_block': stat.S_ISBLK(stat_info.st_mode),
        'is_fifo': stat.S_ISFIFO(stat_info.st_mode),
        'is_socket': stat.S_ISSOCK(stat_info.st_mode),
        'permissions': stat.S_IMODE(stat_info.st_mode),
        'file_type': stat.S_IFMT(stat_info.st_mode)
    }


def main():
    parser = argparse.ArgumentParser(
        description="Stat CLI - A command-line wrapper for stat module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-stat s-isdir 16877
  py-stat filemode 16877
  py-stat stat-file /path/to/file
  py-stat s-isreg 33188
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Mode checking functions
    s_isdir_parser = subparsers.add_parser('s-isdir', help='Check if mode indicates a directory')
    s_isdir_parser.add_argument('mode', type=int, help='File mode')
    
    s_isreg_parser = subparsers.add_parser('s-isreg', help='Check if mode indicates a regular file')
    s_isreg_parser.add_argument('mode', type=int, help='File mode')
    
    s_islnk_parser = subparsers.add_parser('s-islnk', help='Check if mode indicates a symbolic link')
    s_islnk_parser.add_argument('mode', type=int, help='File mode')
    
    s_ischr_parser = subparsers.add_parser('s-ischr', help='Check if mode indicates a character device')
    s_ischr_parser.add_argument('mode', type=int, help='File mode')
    
    s_isblk_parser = subparsers.add_parser('s-isblk', help='Check if mode indicates a block device')
    s_isblk_parser.add_argument('mode', type=int, help='File mode')
    
    s_isfifo_parser = subparsers.add_parser('s-isfifo', help='Check if mode indicates a FIFO')
    s_isfifo_parser.add_argument('mode', type=int, help='File mode')
    
    s_issock_parser = subparsers.add_parser('s-issock', help='Check if mode indicates a socket')
    s_issock_parser.add_argument('mode', type=int, help='File mode')
    
    s_isuid_parser = subparsers.add_parser('s-isuid', help='Check if mode has set-user-ID bit')
    s_isuid_parser.add_argument('mode', type=int, help='File mode')
    
    s_isgid_parser = subparsers.add_parser('s-isgid', help='Check if mode has set-group-ID bit')
    s_isgid_parser.add_argument('mode', type=int, help='File mode')
    
    s_isvtx_parser = subparsers.add_parser('s-isvtx', help='Check if mode has sticky bit')
    s_isvtx_parser.add_argument('mode', type=int, help='File mode')
    
    # Mode manipulation functions
    s_imode_parser = subparsers.add_parser('s-imode', help='Get file permission bits from mode')
    s_imode_parser.add_argument('mode', type=int, help='File mode')
    
    s_ifmt_parser = subparsers.add_parser('s-ifmt', help='Get file type bits from mode')
    s_ifmt_parser.add_argument('mode', type=int, help='File mode')
    
    filemode_parser = subparsers.add_parser('filemode', help='Convert mode to file mode string')
    filemode_parser.add_argument('mode', type=int, help='File mode')
    
    # File stat function
    stat_file_parser = subparsers.add_parser('stat-file', help='Get detailed file stats')
    stat_file_parser.add_argument('path', help='File path')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 's-isdir':
            result = s_isdir(args.mode)
        elif args.command == 's-isreg':
            result = s_isreg(args.mode)
        elif args.command == 's-islnk':
            result = s_islnk(args.mode)
        elif args.command == 's-ischr':
            result = s_ischr(args.mode)
        elif args.command == 's-isblk':
            result = s_isblk(args.mode)
        elif args.command == 's-isfifo':
            result = s_isfifo(args.mode)
        elif args.command == 's-issock':
            result = s_issock(args.mode)
        elif args.command == 's-isuid':
            result = s_isuid(args.mode)
        elif args.command == 's-isgid':
            result = s_isgid(args.mode)
        elif args.command == 's-isvtx':
            result = s_isvtx(args.mode)
        elif args.command == 's-imode':
            result = s_imode(args.mode)
        elif args.command == 's-ifmt':
            result = s_ifmt(args.mode)
        elif args.command == 'filemode':
            result = filemode(args.mode)
        elif args.command == 'stat-file':
            if args.dry_run:
                print(f"Would get stats for: {args.path}")
                return
            result = stat_file(args.path)
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