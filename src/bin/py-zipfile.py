#!/usr/bin/env python3
"""
Zipfile CLI - A command-line wrapper for zipfile module

This script provides CLI-friendly functions that wrap zipfile module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import os
import zipfile
import sys
from typing import Any, Dict, List, Optional
from pathlib import Path

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def open_zip(filename: str, mode: str = 'r') -> Dict[str, Any]:
    """Open a zip file and return information about it."""
    with zipfile.ZipFile(filename, mode) as zf:
        return {
            'filename': filename,
            'mode': mode,
            'member_count': len(zf.namelist()),
            'members': zf.namelist(),
            'comment': zf.comment.decode('utf-8') if zf.comment else ''
        }


def list_members(filename: str) -> List[Dict[str, Any]]:
    """List all members in a zip file."""
    members = []
    with zipfile.ZipFile(filename, 'r') as zf:
        for info in zf.infolist():
            members.append({
                'filename': info.filename,
                'size': info.file_size,
                'compressed_size': info.compress_size,
                'date_time': info.date_time,
                'comment': info.comment.decode('utf-8') if info.comment else '',
                'is_dir': info.filename.endswith('/'),
                'compression': info.compress_type
            })
    return members


def extract_member(filename: str, member_name: str, path: str = '.') -> str:
    """Extract a specific member from zip file."""
    with zipfile.ZipFile(filename, 'r') as zf:
        zf.extract(member_name, path)
    return os.path.join(path, member_name)


def extract_all(filename: str, path: str = '.') -> str:
    """Extract all members from zip file."""
    with zipfile.ZipFile(filename, 'r') as zf:
        zf.extractall(path)
    return path


def add_file(filename: str, file_to_add: str, arcname: Optional[str] = None,
             compression: int = zipfile.ZIP_DEFLATED) -> str:
    """Add a file to zip archive."""
    with zipfile.ZipFile(filename, 'a', compression=compression) as zf:
        zf.write(file_to_add, arcname=arcname)
    return filename


def add_directory(filename: str, directory: str, arcname: Optional[str] = None,
                 compression: int = zipfile.ZIP_DEFLATED) -> str:
    """Add a directory to zip archive."""
    with zipfile.ZipFile(filename, 'a', compression=compression) as zf:
        for root, dirs, files in os.walk(directory):
            for file in files:
                file_path = os.path.join(root, file)
                if arcname:
                    archive_path = os.path.join(arcname, os.path.relpath(file_path, directory))
                else:
                    archive_path = os.path.relpath(file_path, directory)
                zf.write(file_path, archive_path)
    return filename


def create_archive(filename: str, files: List[str], 
                  compression: int = zipfile.ZIP_DEFLATED) -> str:
    """Create a new zip archive with files."""
    with zipfile.ZipFile(filename, 'w', compression=compression) as zf:
        for file_path in files:
            zf.write(file_path)
    return filename


def get_member_info(filename: str, member_name: str) -> Dict[str, Any]:
    """Get detailed information about a specific member."""
    with zipfile.ZipFile(filename, 'r') as zf:
        info = zf.getinfo(member_name)
        return {
            'filename': info.filename,
            'size': info.file_size,
            'compressed_size': info.compress_size,
            'date_time': info.date_time,
            'comment': info.comment.decode('utf-8') if info.comment else '',
            'is_dir': info.filename.endswith('/'),
            'compression': info.compress_type,
            'crc': info.CRC
        }


def get_archive_info(filename: str) -> Dict[str, Any]:
    """Get comprehensive information about zip archive."""
    with zipfile.ZipFile(filename, 'r') as zf:
        members = zf.infolist()
        total_size = sum(info.file_size for info in members)
        total_compressed_size = sum(info.compress_size for info in members)
        
        return {
            'filename': filename,
            'member_count': len(members),
            'total_size': total_size,
            'total_compressed_size': total_compressed_size,
            'compression_ratio': (1 - total_compressed_size / total_size) * 100 if total_size > 0 else 0,
            'file_count': sum(1 for info in members if not info.filename.endswith('/')),
            'dir_count': sum(1 for info in members if info.filename.endswith('/')),
            'comment': zf.comment.decode('utf-8') if zf.comment else '',
            'members': [info.filename for info in members]
        }


def test_zip(filename: str) -> Dict[str, Any]:
    """Test the integrity of a zip file."""
    with zipfile.ZipFile(filename, 'r') as zf:
        result = zf.testzip()
        return {
            'filename': filename,
            'is_valid': result is None,
            'first_bad_file': result
        }


def read_member(filename: str, member_name: str) -> str:
    """Read the contents of a member from zip file."""
    with zipfile.ZipFile(filename, 'r') as zf:
        return zf.read(member_name).decode('utf-8')


def set_comment(filename: str, comment: str) -> str:
    """Set the comment for a zip file."""
    with zipfile.ZipFile(filename, 'a') as zf:
        zf.comment = comment.encode('utf-8')
    return filename


def get_comment(filename: str) -> str:
    """Get the comment from a zip file."""
    with zipfile.ZipFile(filename, 'r') as zf:
        return zf.comment.decode('utf-8') if zf.comment else ''


def list_compression_methods() -> Dict[str, int]:
    """List available compression methods."""
    return {
        'ZIP_STORED': zipfile.ZIP_STORED,
        'ZIP_DEFLATED': zipfile.ZIP_DEFLATED,
        'ZIP_BZIP2': zipfile.ZIP_BZIP2,
        'ZIP_LZMA': zipfile.ZIP_LZMA
    }


def main():
    parser = argparse.ArgumentParser(
        description="Zipfile CLI - A command-line wrapper for zipfile module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-zipfile open-zip archive.zip
  py-zipfile list-members archive.zip
  py-zipfile extract-all archive.zip --output-dir /tmp/extract
  py-zipfile create-archive archive.zip --files file1.txt file2.txt
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--compression', type=int, default=zipfile.ZIP_DEFLATED, 
                       help='Compression method (0=STORED, 8=DEFLATED, 12=BZIP2, 14=LZMA)')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Archive operations
    open_zip_parser = subparsers.add_parser('open-zip', help='Open a zip file')
    open_zip_parser.add_argument('filename', help='Zip file to open')
    open_zip_parser.add_argument('--mode', default='r', help='Open mode')
    
    list_members_parser = subparsers.add_parser('list-members', help='List all members in zip file')
    list_members_parser.add_argument('filename', help='Zip file to list')
    
    extract_member_parser = subparsers.add_parser('extract-member', help='Extract specific member')
    extract_member_parser.add_argument('filename', help='Zip file')
    extract_member_parser.add_argument('member_name', help='Member name to extract')
    extract_member_parser.add_argument('--path', default='.', help='Extraction path')
    
    extract_all_parser = subparsers.add_parser('extract-all', help='Extract all members')
    extract_all_parser.add_argument('filename', help='Zip file to extract')
    extract_all_parser.add_argument('--path', default='.', help='Extraction path')
    
    add_file_parser = subparsers.add_parser('add-file', help='Add file to zip archive')
    add_file_parser.add_argument('filename', help='Zip file')
    add_file_parser.add_argument('file_to_add', help='File to add')
    add_file_parser.add_argument('--arcname', help='Archive name for file')
    
    add_directory_parser = subparsers.add_parser('add-directory', help='Add directory to zip archive')
    add_directory_parser.add_argument('filename', help='Zip file')
    add_directory_parser.add_argument('directory', help='Directory to add')
    add_directory_parser.add_argument('--arcname', help='Archive name for directory')
    
    create_archive_parser = subparsers.add_parser('create-archive', help='Create new zip archive')
    create_archive_parser.add_argument('filename', help='Zip file to create')
    create_archive_parser.add_argument('files', nargs='+', help='Files to add')
    
    get_member_info_parser = subparsers.add_parser('get-member-info', help='Get member information')
    get_member_info_parser.add_argument('filename', help='Zip file')
    get_member_info_parser.add_argument('member_name', help='Member name')
    
    get_archive_info_parser = subparsers.add_parser('get-archive-info', help='Get archive information')
    get_archive_info_parser.add_argument('filename', help='Zip file')
    
    test_zip_parser = subparsers.add_parser('test-zip', help='Test zip file integrity')
    test_zip_parser.add_argument('filename', help='Zip file to test')
    
    read_member_parser = subparsers.add_parser('read-member', help='Read member contents')
    read_member_parser.add_argument('filename', help='Zip file')
    read_member_parser.add_argument('member_name', help='Member name')
    
    set_comment_parser = subparsers.add_parser('set-comment', help='Set zip file comment')
    set_comment_parser.add_argument('filename', help='Zip file')
    set_comment_parser.add_argument('comment', help='Comment text')
    
    get_comment_parser = subparsers.add_parser('get-comment', help='Get zip file comment')
    get_comment_parser.add_argument('filename', help='Zip file')
    
    # Format information
    subparsers.add_parser('list-compression-methods', help='List available compression methods')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'open-zip':
            if args.dry_run:
                print(f"Would open zip file: {args.filename}")
                return
            result = open_zip(args.filename, args.mode)
        elif args.command == 'list-members':
            if args.dry_run:
                print(f"Would list members in: {args.filename}")
                return
            result = list_members(args.filename)
        elif args.command == 'extract-member':
            if args.dry_run:
                print(f"Would extract member {args.member_name} from {args.filename}")
                return
            result = extract_member(args.filename, args.member_name, args.path)
        elif args.command == 'extract-all':
            if args.dry_run:
                print(f"Would extract all from {args.filename} to {args.path}")
                return
            result = extract_all(args.filename, args.path)
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
            result = get_member_info(args.filename, args.member_name)
        elif args.command == 'get-archive-info':
            if args.dry_run:
                print(f"Would get archive info for: {args.filename}")
                return
            result = get_archive_info(args.filename)
        elif args.command == 'test-zip':
            if args.dry_run:
                print(f"Would test zip file: {args.filename}")
                return
            result = test_zip(args.filename)
        elif args.command == 'read-member':
            if args.dry_run:
                print(f"Would read member {args.member_name} from {args.filename}")
                return
            result = read_member(args.filename, args.member_name)
        elif args.command == 'set-comment':
            if args.dry_run:
                print(f"Would set comment for {args.filename}: {args.comment}")
                return
            result = set_comment(args.filename, args.comment)
        elif args.command == 'get-comment':
            if args.dry_run:
                print(f"Would get comment from {args.filename}")
                return
            result = get_comment(args.filename)
        elif args.command == 'list-compression-methods':
            result = list_compression_methods()
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