#!/usr/bin/env python3
"""
JSON CLI - A command-line wrapper for json module

This script provides CLI-friendly functions that wrap json module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import sys
from typing import Any, Dict, List, Optional

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def dumps(obj: Any, indent: Optional[int] = None, separators: Optional[tuple] = None,
          sort_keys: bool = False, ensure_ascii: bool = True) -> str:
    """Serialize object to JSON string."""
    return json.dumps(obj, indent=indent, separators=separators, 
                     sort_keys=sort_keys, ensure_ascii=ensure_ascii)


def loads(s: str) -> Any:
    """Deserialize JSON string to object."""
    return json.loads(s)


def dump(obj: Any, file_path: str, indent: Optional[int] = None, 
         separators: Optional[tuple] = None, sort_keys: bool = False, 
         ensure_ascii: bool = True) -> None:
    """Serialize object to JSON file."""
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, indent=indent, separators=separators,
                 sort_keys=sort_keys, ensure_ascii=ensure_ascii)


def load(file_path: str) -> Any:
    """Deserialize JSON file to object."""
    with open(file_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def validate(json_str: str) -> bool:
    """Validate JSON string."""
    try:
        json.loads(json_str)
        return True
    except json.JSONDecodeError:
        return False


def format_json(json_str: str, indent: int = 2, sort_keys: bool = False) -> str:
    """Format JSON string with indentation."""
    obj = json.loads(json_str)
    return json.dumps(obj, indent=indent, sort_keys=sort_keys)


def minify(json_str: str) -> str:
    """Minify JSON string."""
    obj = json.loads(json_str)
    return json.dumps(obj, separators=(',', ':'))


def main():
    parser = argparse.ArgumentParser(
        description="JSON CLI - A command-line wrapper for json module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-json dumps '{"key": "value"}' --indent 2
  py-json loads '{"key": "value"}'
  py-json dump data.json '{"key": "value"}' --indent 2
  py-json load data.json
  py-json validate '{"key": "value"}'
  py-json format '{"key":"value"}' --indent 2
        """
    )
    
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # dumps command
    dumps_parser = subparsers.add_parser('dumps', help='Serialize object to JSON string')
    dumps_parser.add_argument('data', help='JSON data (will be evaluated as Python)')
    dumps_parser.add_argument('--indent', type=int, help='Indentation level')
    dumps_parser.add_argument('--separators', help='Separators as "item,key"')
    dumps_parser.add_argument('--sort-keys', action='store_true', help='Sort dictionary keys')
    dumps_parser.add_argument('--no-ensure-ascii', action='store_true', help='Allow non-ASCII characters')
    
    # loads command
    loads_parser = subparsers.add_parser('loads', help='Deserialize JSON string to object')
    loads_parser.add_argument('json_str', help='JSON string')
    
    # dump command
    dump_parser = subparsers.add_parser('dump', help='Serialize object to JSON file')
    dump_parser.add_argument('file_path', help='Output file path')
    dump_parser.add_argument('data', help='JSON data (will be evaluated as Python)')
    dump_parser.add_argument('--indent', type=int, help='Indentation level')
    dump_parser.add_argument('--separators', help='Separators as "item,key"')
    dump_parser.add_argument('--sort-keys', action='store_true', help='Sort dictionary keys')
    dump_parser.add_argument('--no-ensure-ascii', action='store_true', help='Allow non-ASCII characters')
    
    # load command
    load_parser = subparsers.add_parser('load', help='Deserialize JSON file to object')
    load_parser.add_argument('file_path', help='Input file path')
    
    # validate command
    validate_parser = subparsers.add_parser('validate', help='Validate JSON string')
    validate_parser.add_argument('json_str', help='JSON string to validate')
    
    # format command
    format_parser = subparsers.add_parser('format', help='Format JSON string')
    format_parser.add_argument('json_str', help='JSON string to format')
    format_parser.add_argument('--indent', type=int, default=2, help='Indentation level')
    format_parser.add_argument('--sort-keys', action='store_true', help='Sort dictionary keys')
    
    # minify command
    minify_parser = subparsers.add_parser('minify', help='Minify JSON string')
    minify_parser.add_argument('json_str', help='JSON string to minify')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'dumps':
            # Evaluate the data as Python expression
            data = eval(args.data)
            separators = None
            if args.separators:
                item_sep, key_sep = args.separators.split(',')
                separators = (item_sep, key_sep)
            result = dumps(data, args.indent, separators, args.sort_keys, not args.no_ensure_ascii)
            
        elif args.command == 'loads':
            result = loads(args.json_str)
            
        elif args.command == 'dump':
            if args.dry_run:
                print(f"Would write JSON data to: {args.file_path}")
                return
            data = eval(args.data)
            separators = None
            if args.separators:
                item_sep, key_sep = args.separators.split(',')
                separators = (item_sep, key_sep)
            dump(data, args.file_path, args.indent, separators, args.sort_keys, not args.no_ensure_ascii)
            result = f"Wrote JSON to {args.file_path}"
            
        elif args.command == 'load':
            result = load(args.file_path)
            
        elif args.command == 'validate':
            result = validate(args.json_str)
            
        elif args.command == 'format':
            result = format_json(args.json_str, args.indent, args.sort_keys)
            
        elif args.command == 'minify':
            result = minify(args.json_str)
            
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
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