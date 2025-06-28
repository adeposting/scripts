#!/usr/bin/env python3
"""
Glob CLI - A command-line wrapper for glob module

This script provides CLI-friendly functions that wrap glob module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import glob
import json
import sys
from typing import List


def glob_pattern(pattern: str, recursive: bool = False) -> List[str]:
    """Find files matching pattern."""
    return glob.glob(pattern, recursive=recursive)


def iglob_pattern(pattern: str, recursive: bool = False) -> List[str]:
    """Find files matching pattern (iterator)."""
    return list(glob.iglob(pattern, recursive=recursive))


def escape(pathname: str) -> str:
    """Escape special characters in pathname."""
    return glob.escape(pathname)


def main():
    parser = argparse.ArgumentParser(
        description="Glob CLI - A command-line wrapper for glob module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-glob glob "*.py"
  py-glob glob "**/*.py" --recursive
  py-glob escape "file[1].txt"
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Pattern matching
    glob_parser = subparsers.add_parser('glob', help='Find files matching pattern')
    glob_parser.add_argument('pattern', help='Glob pattern')
    glob_parser.add_argument('--recursive', action='store_true', help='Recursive search')
    
    iglob_parser = subparsers.add_parser('iglob', help='Find files matching pattern (iterator)')
    iglob_parser.add_argument('pattern', help='Glob pattern')
    iglob_parser.add_argument('--recursive', action='store_true', help='Recursive search')
    
    escape_parser = subparsers.add_parser('escape', help='Escape special characters in pathname')
    escape_parser.add_argument('pathname', help='Pathname to escape')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'glob':
            if args.dry_run:
                print(f"Would search for files matching: {args.pattern}")
                return
            result = glob_pattern(args.pattern, args.recursive)
        elif args.command == 'iglob':
            if args.dry_run:
                print(f"Would search for files matching: {args.pattern}")
                return
            result = iglob_pattern(args.pattern, args.recursive)
        elif args.command == 'escape':
            result = escape(args.pathname)
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                if isinstance(result, list):
                    for item in result:
                        print(item)
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