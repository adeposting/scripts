#!/usr/bin/env python3
"""
Re CLI - A command-line wrapper for re module

This script provides CLI-friendly functions that wrap re module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import re
import sys
from typing import List, Optional, Union


def match(pattern: str, string: str, flags: int = 0) -> Optional[dict]:
    """Match pattern at beginning of string."""
    match_obj = re.match(pattern, string, flags)
    if match_obj:
        return {
            'group': match_obj.group(),
            'groups': match_obj.groups(),
            'start': match_obj.start(),
            'end': match_obj.end(),
            'span': match_obj.span()
        }
    return None


def search(pattern: str, string: str, flags: int = 0) -> Optional[dict]:
    """Search for pattern in string."""
    match_obj = re.search(pattern, string, flags)
    if match_obj:
        return {
            'group': match_obj.group(),
            'groups': match_obj.groups(),
            'start': match_obj.start(),
            'end': match_obj.end(),
            'span': match_obj.span()
        }
    return None


def findall(pattern: str, string: str, flags: int = 0) -> List[str]:
    """Find all non-overlapping matches."""
    return re.findall(pattern, string, flags)


def finditer(pattern: str, string: str, flags: int = 0) -> List[dict]:
    """Find all non-overlapping matches (iterator)."""
    matches = []
    for match_obj in re.finditer(pattern, string, flags):
        matches.append({
            'group': match_obj.group(),
            'groups': match_obj.groups(),
            'start': match_obj.start(),
            'end': match_obj.end(),
            'span': match_obj.span()
        })
    return matches


def sub(pattern: str, repl: str, string: str, count: int = 0, flags: int = 0) -> str:
    """Substitute pattern with replacement."""
    return re.sub(pattern, repl, string, count, flags)


def subn(pattern: str, repl: str, string: str, count: int = 0, flags: int = 0) -> tuple:
    """Substitute pattern with replacement, return (new_string, count)."""
    return re.subn(pattern, repl, string, count, flags)


def split(pattern: str, string: str, maxsplit: int = 0, flags: int = 0) -> List[str]:
    """Split string by pattern."""
    return re.split(pattern, string, maxsplit, flags)


def escape(string: str) -> str:
    """Escape special characters in string."""
    return re.escape(string)


def compile(pattern: str, flags: int = 0) -> str:
    """Compile pattern (returns pattern string for CLI)."""
    re.compile(pattern, flags)
    return pattern


def fullmatch(pattern: str, string: str, flags: int = 0) -> Optional[dict]:
    """Match pattern against entire string."""
    match_obj = re.fullmatch(pattern, string, flags)
    if match_obj:
        return {
            'group': match_obj.group(),
            'groups': match_obj.groups(),
            'start': match_obj.start(),
            'end': match_obj.end(),
            'span': match_obj.span()
        }
    return None


def main():
    parser = argparse.ArgumentParser(
        description="Re CLI - A command-line wrapper for re module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-re match "hello" "hello world"
  py-re search "world" "hello world"
  py-re findall "\\d+" "abc123def456"
  py-re sub "\\d+" "X" "abc123def456"
  py-re split "\\s+" "hello   world"
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--flags', type=int, default=0, help='Regex flags (IGNORECASE=1, MULTILINE=2, DOTALL=4, etc.)')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Pattern matching
    match_parser = subparsers.add_parser('match', help='Match pattern at beginning of string')
    match_parser.add_argument('pattern', help='Regex pattern')
    match_parser.add_argument('string', help='String to match')
    
    search_parser = subparsers.add_parser('search', help='Search for pattern in string')
    search_parser.add_argument('pattern', help='Regex pattern')
    search_parser.add_argument('string', help='String to search')
    
    fullmatch_parser = subparsers.add_parser('fullmatch', help='Match pattern against entire string')
    fullmatch_parser.add_argument('pattern', help='Regex pattern')
    fullmatch_parser.add_argument('string', help='String to match')
    
    # Finding matches
    findall_parser = subparsers.add_parser('findall', help='Find all non-overlapping matches')
    findall_parser.add_argument('pattern', help='Regex pattern')
    findall_parser.add_argument('string', help='String to search')
    
    finditer_parser = subparsers.add_parser('finditer', help='Find all non-overlapping matches (iterator)')
    finditer_parser.add_argument('pattern', help='Regex pattern')
    finditer_parser.add_argument('string', help='String to search')
    
    # Substitution
    sub_parser = subparsers.add_parser('sub', help='Substitute pattern with replacement')
    sub_parser.add_argument('pattern', help='Regex pattern')
    sub_parser.add_argument('repl', help='Replacement string')
    sub_parser.add_argument('string', help='String to substitute')
    sub_parser.add_argument('--count', type=int, default=0, help='Maximum number of substitutions')
    
    subn_parser = subparsers.add_parser('subn', help='Substitute pattern with replacement, return count')
    subn_parser.add_argument('pattern', help='Regex pattern')
    subn_parser.add_argument('repl', help='Replacement string')
    subn_parser.add_argument('string', help='String to substitute')
    subn_parser.add_argument('--count', type=int, default=0, help='Maximum number of substitutions')
    
    # Splitting
    split_parser = subparsers.add_parser('split', help='Split string by pattern')
    split_parser.add_argument('pattern', help='Regex pattern')
    split_parser.add_argument('string', help='String to split')
    split_parser.add_argument('--maxsplit', type=int, default=0, help='Maximum number of splits')
    
    # Utility
    escape_parser = subparsers.add_parser('escape', help='Escape special characters in string')
    escape_parser.add_argument('string', help='String to escape')
    
    compile_parser = subparsers.add_parser('compile', help='Compile pattern')
    compile_parser.add_argument('pattern', help='Regex pattern')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'match':
            result = match(args.pattern, args.string, args.flags)
        elif args.command == 'search':
            result = search(args.pattern, args.string, args.flags)
        elif args.command == 'fullmatch':
            result = fullmatch(args.pattern, args.string, args.flags)
        elif args.command == 'findall':
            result = findall(args.pattern, args.string, args.flags)
        elif args.command == 'finditer':
            result = finditer(args.pattern, args.string, args.flags)
        elif args.command == 'sub':
            if args.dry_run:
                print(f"Would substitute '{args.pattern}' with '{args.repl}' in '{args.string}'")
                return
            result = sub(args.pattern, args.repl, args.string, args.count, args.flags)
        elif args.command == 'subn':
            if args.dry_run:
                print(f"Would substitute '{args.pattern}' with '{args.repl}' in '{args.string}'")
                return
            new_string, count = subn(args.pattern, args.repl, args.string, args.count, args.flags)
            result = {'string': new_string, 'count': count}
        elif args.command == 'split':
            result = split(args.pattern, args.string, args.maxsplit, args.flags)
        elif args.command == 'escape':
            result = escape(args.string)
        elif args.command == 'compile':
            result = compile(args.pattern, args.flags)
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
        else:
            if args.json:
                print("null")
            else:
                print("No match")
                    
    except Exception as e:
        if args.verbose:
            import traceback
            traceback.print_exc()
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main() 