#!/usr/bin/env python3
"""
Shutil CLI - A command-line wrapper for shutil module

This script provides CLI-friendly functions that wrap shutil module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import shutil
import sys
from typing import Any, Dict, List, Optional


def copy(src: str, dst: str) -> str:
    """Copy file."""
    return shutil.copy(src, dst)


def copy2(src: str, dst: str) -> str:
    """Copy file with metadata."""
    return shutil.copy2(src, dst)


def copyfile(src: str, dst: str, follow_symlinks: bool = True) -> str:
    """Copy file content."""
    shutil.copyfile(src, dst, follow_symlinks=follow_symlinks)
    return dst


def copytree(src: str, dst: str, symlinks: bool = False, ignore: Optional[callable] = None,
             copy_function: callable = shutil.copy2, ignore_dangling_symlinks: bool = False,
             dirs_exist_ok: bool = False) -> str:
    """Copy directory tree."""
    shutil.copytree(src, dst, symlinks=symlinks, ignore=ignore, copy_function=copy_function,
                   ignore_dangling_symlinks=ignore_dangling_symlinks, dirs_exist_ok=dirs_exist_ok)
    return dst


def move(src: str, dst: str) -> str:
    """Move file or directory."""
    return shutil.move(src, dst)


def rmtree(path: str, ignore_errors: bool = False, onerror: Optional[callable] = None) -> None:
    """Remove directory tree."""
    shutil.rmtree(path, ignore_errors=ignore_errors, onerror=onerror)


def make_archive(base_name: str, format: str, root_dir: Optional[str] = None,
                base_dir: Optional[str] = None, verbose: bool = False,
                dry_run: bool = False, logger: Optional[callable] = None) -> str:
    """Create archive."""
    return shutil.make_archive(base_name, format, root_dir, base_dir, verbose, dry_run, logger)


def unpack_archive(filename: str, extract_dir: Optional[str] = None, format: Optional[str] = None) -> str:
    """Unpack archive."""
    shutil.unpack_archive(filename, extract_dir, format)
    return extract_dir or "."


def disk_usage(path: str) -> Dict[str, int]:
    """Get disk usage."""
    usage = shutil.disk_usage(path)
    return {
        'total': usage.total,
        'used': usage.used,
        'free': usage.free
    }


def which(cmd: str, mode: int = 0, path: Optional[str] = None) -> Optional[str]:
    """Find executable in PATH."""
    return shutil.which(cmd, mode, path)


def chown(path: str, user: Optional[str] = None, group: Optional[str] = None) -> None:
    """Change owner of file."""
    shutil.chown(path, user, group)


def get_terminal_size(fallback: tuple = (80, 24)) -> Dict[str, int]:
    """Get terminal size."""
    size = shutil.get_terminal_size(fallback)
    return {
        'columns': size.columns,
        'lines': size.lines
    }


def main():
    parser = argparse.ArgumentParser(
        description="Shutil CLI - A command-line wrapper for shutil module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-shutil copy src.txt dst.txt
  py-shutil copytree src_dir dst_dir --dirs-exist-ok
  py-shutil move old.txt new.txt
  py-shutil rmtree /path/to/dir
  py-shutil make-archive backup zip /path/to/source
  py-shutil disk-usage /path
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # File operations
    copy_parser = subparsers.add_parser('copy', help='Copy file')
    copy_parser.add_argument('src', help='Source file')
    copy_parser.add_argument('dst', help='Destination file')
    
    copy2_parser = subparsers.add_parser('copy2', help='Copy file with metadata')
    copy2_parser.add_argument('src', help='Source file')
    copy2_parser.add_argument('dst', help='Destination file')
    
    copyfile_parser = subparsers.add_parser('copyfile', help='Copy file content')
    copyfile_parser.add_argument('src', help='Source file')
    copyfile_parser.add_argument('dst', help='Destination file')
    copyfile_parser.add_argument('--no-follow-symlinks', action='store_true', help='Don\'t follow symlinks')
    
    # Directory operations
    copytree_parser = subparsers.add_parser('copytree', help='Copy directory tree')
    copytree_parser.add_argument('src', help='Source directory')
    copytree_parser.add_argument('dst', help='Destination directory')
    copytree_parser.add_argument('--symlinks', action='store_true', help='Copy symlinks as symlinks')
    copytree_parser.add_argument('--dirs-exist-ok', action='store_true', help='Don\'t error if destination exists')
    copytree_parser.add_argument('--ignore-dangling-symlinks', action='store_true', help='Ignore dangling symlinks')
    
    move_parser = subparsers.add_parser('move', help='Move file or directory')
    move_parser.add_argument('src', help='Source path')
    move_parser.add_argument('dst', help='Destination path')
    
    rmtree_parser = subparsers.add_parser('rmtree', help='Remove directory tree')
    rmtree_parser.add_argument('path', help='Directory path to remove')
    rmtree_parser.add_argument('--ignore-errors', action='store_true', help='Ignore errors')
    
    # Archive operations
    make_archive_parser = subparsers.add_parser('make-archive', help='Create archive')
    make_archive_parser.add_argument('base_name', help='Base name for archive')
    make_archive_parser.add_argument('format', help='Archive format (zip, tar, gztar, bztar, xztar)')
    make_archive_parser.add_argument('--root-dir', help='Root directory to archive')
    make_archive_parser.add_argument('--base-dir', help='Base directory within root')
    make_archive_parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    unpack_archive_parser = subparsers.add_parser('unpack-archive', help='Unpack archive')
    unpack_archive_parser.add_argument('filename', help='Archive file')
    unpack_archive_parser.add_argument('--extract-dir', help='Extraction directory')
    unpack_archive_parser.add_argument('--format', help='Archive format')
    
    # System operations
    disk_usage_parser = subparsers.add_parser('disk-usage', help='Get disk usage')
    disk_usage_parser.add_argument('path', help='Path to check')
    
    which_parser = subparsers.add_parser('which', help='Find executable in PATH')
    which_parser.add_argument('cmd', help='Command to find')
    which_parser.add_argument('--mode', type=int, default=0, help='Mode')
    which_parser.add_argument('--path', help='PATH to search')
    
    chown_parser = subparsers.add_parser('chown', help='Change owner of file')
    chown_parser.add_argument('path', help='File path')
    chown_parser.add_argument('--user', help='User')
    chown_parser.add_argument('--group', help='Group')
    
    get_terminal_size_parser = subparsers.add_parser('get-terminal-size', help='Get terminal size')
    get_terminal_size_parser.add_argument('--fallback-columns', type=int, default=80, help='Fallback columns')
    get_terminal_size_parser.add_argument('--fallback-lines', type=int, default=24, help='Fallback lines')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'copy':
            if args.dry_run:
                print(f"Would copy {args.src} to {args.dst}")
                return
            result = copy(args.src, args.dst)
        elif args.command == 'copy2':
            if args.dry_run:
                print(f"Would copy {args.src} to {args.dst} with metadata")
                return
            result = copy2(args.src, args.dst)
        elif args.command == 'copyfile':
            if args.dry_run:
                print(f"Would copy file content from {args.src} to {args.dst}")
                return
            result = copyfile(args.src, args.dst, not args.no_follow_symlinks)
        elif args.command == 'copytree':
            if args.dry_run:
                print(f"Would copy directory tree from {args.src} to {args.dst}")
                return
            result = copytree(args.src, args.dst, args.symlinks, None, shutil.copy2, 
                            args.ignore_dangling_symlinks, args.dirs_exist_ok)
        elif args.command == 'move':
            if args.dry_run:
                print(f"Would move {args.src} to {args.dst}")
                return
            result = move(args.src, args.dst)
        elif args.command == 'rmtree':
            if args.dry_run:
                print(f"Would remove directory tree: {args.path}")
                return
            rmtree(args.path, args.ignore_errors)
            result = f"Removed directory tree: {args.path}"
        elif args.command == 'make-archive':
            if args.dry_run:
                print(f"Would create archive {args.base_name}.{args.format}")
                return
            result = make_archive(args.base_name, args.format, args.root_dir, args.base_dir, 
                                args.verbose, False, None)
        elif args.command == 'unpack-archive':
            if args.dry_run:
                print(f"Would unpack archive: {args.filename}")
                return
            result = unpack_archive(args.filename, args.extract_dir, args.format)
        elif args.command == 'disk-usage':
            result = disk_usage(args.path)
        elif args.command == 'which':
            result = which(args.cmd, args.mode, args.path)
        elif args.command == 'chown':
            if args.dry_run:
                print(f"Would change owner of {args.path}")
                return
            chown(args.path, args.user, args.group)
            result = f"Changed owner of {args.path}"
        elif args.command == 'get-terminal-size':
            result = get_terminal_size((args.fallback_columns, args.fallback_lines))
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