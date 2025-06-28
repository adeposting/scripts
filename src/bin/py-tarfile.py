#!/usr/bin/env python3
"""
Tarfile CLI - A command-line wrapper for tarfile module

This script provides CLI-friendly functions that wrap tarfile module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import os
import tarfile
import sys
from typing import Any, Dict, List, Optional
from pathlib import Path

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def open_tar(filename: str, mode: str = 'r', compression: str = '') -> Dict[str, Any]:
    """Open a tar file and return information about it."""
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        return {
            'filename': filename,
            'mode': mode,
            'compression': compression,
            'member_count': len(tar.getmembers()),
            'members': [member.name for member in tar.getmembers()]
        }


def list_members(filename: str, compression: str = '') -> List[Dict[str, Any]]:
    """List all members in a tar file."""
    mode = 'r'
    if compression:
        mode = f"{mode}:{compression}"
    
    members = []
    with tarfile.open(filename, mode) as tar:
        for member in tar.getmembers():
            members.append({
                'name': member.name,
                'size': member.size,
                'mtime': member.mtime,
                'mode': member.mode,
                'type': member.type,
                'linkname': member.linkname,
                'uid': member.uid,
                'gid': member.gid,
                'uname': member.uname,
                'gname': member.gname
            })
    return members


def extract_member(filename: str, member_name: str, path: str = '.', 
                  compression: str = '') -> str:
    """Extract a specific member from tar file."""
    mode = 'r'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        tar.extract(member_name, path)
    return os.path.join(path, member_name)


def extract_all(filename: str, path: str = '.', compression: str = '') -> str:
    """Extract all members from tar file."""
    mode = 'r'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        tar.extractall(path)
    return path


def add_file(filename: str, file_to_add: str, arcname: Optional[str] = None,
             compression: str = '') -> str:
    """Add a file to tar archive."""
    mode = 'a'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        tar.add(file_to_add, arcname=arcname)
    return filename


def add_directory(filename: str, directory: str, arcname: Optional[str] = None,
                 compression: str = '') -> str:
    """Add a directory to tar archive."""
    mode = 'a'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        tar.add(directory, arcname=arcname, recursive=True)
    return filename


def create_archive(filename: str, files: List[str], compression: str = '') -> str:
    """Create a new tar archive with files."""
    mode = 'w'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        for file_path in files:
            tar.add(file_path)
    return filename


def get_member_info(filename: str, member_name: str, compression: str = '') -> Dict[str, Any]:
    """Get detailed information about a specific member."""
    mode = 'r'
    if compression:
        mode = f"{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        member = tar.getmember(member_name)
        return {
            'name': member.name,
            'size': member.size,
            'mtime': member.mtime,
            'mode': member.mode,
            'type': member.type,
            'linkname': member.linkname,
            'uid': member.uid,
            'gid': member.gid,
            'uname': member.uname,
            'gname': member.gname,
            'isfile': member.isfile(),
            'isdir': member.isdir(),
            'islnk': member.islnk(),
            'issym': member.issym()
        }


def get_archive_info(filename: str, compression: str = '') -> Dict[str, Any]:
    """Get comprehensive information about tar archive."""
    mode = 'r'
    if compression:
        mode = f"{mode}:{mode}:{compression}"
    
    with tarfile.open(filename, mode) as tar:
        members = tar.getmembers()
        total_size = sum(member.size for member in members if member.isfile())
        
        return {
            'filename': filename,
            'mode': mode,
            'compression': compression,
            'member_count': len(members),
            'total_size': total_size,
            'file_count': sum(1 for member in members if member.isfile()),
            'dir_count': sum(1 for member in members if member.isdir()),
            'link_count': sum(1 for member in members if member.islnk()),
            'symlink_count': sum(1 for member in members if member.issym()),
            'members': [member.name for member in members]
        }


def list_formats() -> List[str]:
    """List available tar formats."""
    return list(tarfile.TarFile.FORMATS.keys())


def list_compression_formats() -> List[str]:
    """List available compression formats."""
    return list(tarfile.TarFile.OPEN_METH.keys())


def main():
    parser = argparse.ArgumentParser(
        description="Tarfile CLI - A command-line wrapper for tarfile module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-tarfile open-tar archive.tar.gz
  py-tarfile list-members archive.tar.gz
  py-tarfile extract-all archive.tar.gz --output-dir /tmp/extract
  py-tarfile create-archive archive.tar.gz --files file1.txt file2.txt
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--compression', default='', help='Compression format (gz, bz2, xz)')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Archive operations
    open_tar_parser = subparsers.add_parser('open-tar', help='Open a tar file')
    open_tar_parser.add_argument('filename', help='Tar file to open')
    open_tar_parser.add_argument('--mode', default='r', help='Open mode')
    
    list_members_parser = subparsers.add_parser('list-members', help='List all members in tar file')
    list_members_parser.add_argument('filename', help='Tar file to list')
    
    extract_member_parser = subparsers.add_parser('extract-member', help='Extract specific member')
    extract_member_parser.add_argument('filename', help='Tar file')
    extract_member_parser.add_argument('member_name', help='Member name to extract')
    extract_member_parser.add_argument('--path', default='.', help='Extraction path')
    
    extract_all_parser = subparsers.add_parser('extract-all', help='Extract all members')
    extract_all_parser.add_argument('filename', help='Tar file to extract')
    extract_all_parser.add_argument('--path', default='.', help='Extraction path')
    
    add_file_parser = subparsers.add_parser('add-file', help='Add file to tar archive')
    add_file_parser.add_argument('filename', help='Tar file')
    add_file_parser.add_argument('file_to_add', help='File to add')
    add_file_parser.add_argument('--arcname', help='Archive name for file')
    
    add_directory_parser = subparsers.add_parser('add-directory', help='Add directory to tar archive')
    add_directory_parser.add_argument('filename', help='Tar file')
    add_directory_parser.add_argument('directory', help='Directory to add')
    add_directory_parser.add_argument('--arcname', help='Archive name for directory')
    
    create_archive_parser = subparsers.add_parser('create-archive', help='Create new tar archive')
    create_archive_parser.add_argument('filename', help='Tar file to create')
    create_archive_parser.add_argument('files', nargs='+', help='Files to add')
    
    get_member_info_parser = subparsers.add_parser('get-member-info', help='Get member information')
    get_member_info_parser.add_argument('filename', help='Tar file')
    get_member_info_parser.add_argument('member_name', help='Member name')
    
    get_archive_info_parser = subparsers.add_parser('get-archive-info', help='Get archive information')
    get_archive_info_parser.add_argument('filename', help='Tar file')
    
    # Format information
    subparsers.add_parser('list-formats', help='List available tar formats')
    subparsers.add_parser('list-compression-formats', help='List available compression formats')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'open-tar':
            if args.dry_run:
                print(f"Would open tar file: {args.filename}")
                return
            result = open_tar(args.filename, args.mode, args.compression)
        elif args.command == 'list-members':
            if args.dry_run:
                print(f"Would list members in: {args.filename}")
                return
            result = list_members(args.filename, args.compression)
        elif args.command == 'extract-member':
            if args.dry_run:
                print(f"Would extract member {args.member_name} from {args.filename}")
                return
            result = extract_member(args.filename, args.member_name, args.path, args.compression)
        elif args.command == 'extract-all':
            if args.dry_run:
                print(f"Would extract all from {args.filename} to {args.path}")
                return
            result = extract_all(args.filename, args.path, args.compression)
        elif args.command == 'add-file':
            if args.dry_run:
                print(f"Would add file {args.file_to_add} to {args.filename}")
                return
            result = add_file(args.filename, args.file_to_add, args.arcname, args.compression)
        elif args.command == 'add-directory':
            if args.dry_run:
                print(f"Would add directory {args.directory} to {args.filename}")
                return
            result = add_directory(args.filename, args.directory, args.arcname, args.compression)
        elif args.command == 'create-archive':
            if args.dry_run:
                print(f"Would create archive {args.filename} with files: {args.files}")
                return
            result = create_archive(args.filename, args.files, args.compression)
        elif args.command == 'get-member-info':
            if args.dry_run:
                print(f"Would get info for member {args.member_name} in {args.filename}")
                return
            result = get_member_info(args.filename, args.member_name, args.compression)
        elif args.command == 'get-archive-info':
            if args.dry_run:
                print(f"Would get archive info for: {args.filename}")
                return
            result = get_archive_info(args.filename, args.compression)
        elif args.command == 'list-formats':
            result = list_formats()
        elif args.command == 'list-compression-formats':
            result = list_compression_formats()
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