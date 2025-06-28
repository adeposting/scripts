#!/usr/bin/env python3
"""
CSV CLI - A command-line wrapper for csv module

This script provides CLI-friendly functions that wrap csv module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import csv
import json
import sys
from typing import Any, Dict, List, Optional


def reader(filename: str, delimiter: str = ',', quotechar: str = '"', 
          skipinitialspace: bool = False, dialect: Optional[str] = None) -> List[List[str]]:
    """Read CSV file and return rows."""
    rows = []
    with open(filename, 'r', newline='', encoding='utf-8') as file:
        csv_reader = csv.reader(file, delimiter=delimiter, quotechar=quotechar,
                              skipinitialspace=skipinitialspace, dialect=dialect)
        for row in csv_reader:
            rows.append(row)
    return rows


def writer(filename: str, rows: List[List[str]], delimiter: str = ',', 
          quotechar: str = '"', quoting: int = csv.QUOTE_MINIMAL,
          skipinitialspace: bool = False, dialect: Optional[str] = None) -> str:
    """Write rows to CSV file."""
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        csv_writer = csv.writer(file, delimiter=delimiter, quotechar=quotechar,
                              quoting=quoting, skipinitialspace=skipinitialspace, dialect=dialect)
        for row in rows:
            csv_writer.writerow(row)
    return filename


def dict_reader(filename: str, fieldnames: Optional[List[str]] = None,
               delimiter: str = ',', quotechar: str = '"',
               skipinitialspace: bool = False, dialect: Optional[str] = None) -> List[Dict[str, str]]:
    """Read CSV file as dictionary."""
    rows = []
    with open(filename, 'r', newline='', encoding='utf-8') as file:
        csv_reader = csv.DictReader(file, fieldnames=fieldnames, delimiter=delimiter,
                                  quotechar=quotechar, skipinitialspace=skipinitialspace, dialect=dialect)
        for row in csv_reader:
            rows.append(dict(row))
    return rows


def dict_writer(filename: str, fieldnames: List[str], rows: List[Dict[str, str]],
               delimiter: str = ',', quotechar: str = '"',
               quoting: int = csv.QUOTE_MINIMAL, skipinitialspace: bool = False,
               dialect: Optional[str] = None) -> str:
    """Write dictionary rows to CSV file."""
    with open(filename, 'w', newline='', encoding='utf-8') as file:
        csv_writer = csv.DictWriter(file, fieldnames=fieldnames, delimiter=delimiter,
                                  quotechar=quotechar, quoting=quoting,
                                  skipinitialspace=skipinitialspace, dialect=dialect)
        csv_writer.writeheader()
        for row in rows:
            csv_writer.writerow(row)
    return filename


def sniffer(filename: str, sample_size: int = 1024) -> Dict[str, Any]:
    """Detect CSV dialect from file."""
    with open(filename, 'r', newline='', encoding='utf-8') as file:
        sample = file.read(sample_size)
        sniffer_obj = csv.Sniffer()
        dialect = sniffer_obj.sniff(sample)
        has_header = sniffer_obj.has_header(sample)
        
        return {
            'delimiter': dialect.delimiter,
            'quotechar': dialect.quotechar,
            'doublequote': dialect.doublequote,
            'skipinitialspace': dialect.skipinitialspace,
            'lineterminator': dialect.lineterminator,
            'quoting': dialect.quoting,
            'has_header': has_header
        }


def list_dialects() -> List[str]:
    """List available CSV dialects."""
    return csv.list_dialects()


def register_dialect(name: str, delimiter: str = ',', quotechar: str = '"',
                    quoting: int = csv.QUOTE_MINIMAL, doublequote: bool = True,
                    skipinitialspace: bool = False, lineterminator: str = '\r\n') -> str:
    """Register a new CSV dialect."""
    csv.register_dialect(name, delimiter=delimiter, quotechar=quotechar,
                        quoting=quoting, doublequote=doublequote,
                        skipinitialspace=skipinitialspace, lineterminator=lineterminator)
    return f"Registered dialect: {name}"


def unregister_dialect(name: str) -> str:
    """Unregister a CSV dialect."""
    csv.unregister_dialect(name)
    return f"Unregistered dialect: {name}"


def get_dialect(name: str) -> Dict[str, Any]:
    """Get dialect information."""
    dialect = csv.get_dialect(name)
    return {
        'delimiter': dialect.delimiter,
        'quotechar': dialect.quotechar,
        'doublequote': dialect.doublequote,
        'skipinitialspace': dialect.skipinitialspace,
        'lineterminator': dialect.lineterminator,
        'quoting': dialect.quoting
    }


def main():
    parser = argparse.ArgumentParser(
        description="CSV CLI - A command-line wrapper for csv module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-csv reader data.csv
  py-csv writer output.csv --rows '["a","b","c"],["1","2","3"]'
  py-csv dict-reader data.csv
  py-csv sniffer data.csv
  py-csv list-dialects
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--delimiter', default=',', help='Field delimiter')
    parser.add_argument('--quotechar', default='"', help='Quote character')
    parser.add_argument('--quoting', type=int, default=csv.QUOTE_MINIMAL, help='Quoting mode')
    parser.add_argument('--skipinitialspace', action='store_true', help='Skip initial space')
    parser.add_argument('--dialect', help='CSV dialect name')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Reader commands
    reader_parser = subparsers.add_parser('reader', help='Read CSV file')
    reader_parser.add_argument('filename', help='CSV file to read')
    
    dict_reader_parser = subparsers.add_parser('dict-reader', help='Read CSV file as dictionary')
    dict_reader_parser.add_argument('filename', help='CSV file to read')
    dict_reader_parser.add_argument('--fieldnames', nargs='+', help='Field names')
    
    # Writer commands
    writer_parser = subparsers.add_parser('writer', help='Write CSV file')
    writer_parser.add_argument('filename', help='CSV file to write')
    writer_parser.add_argument('--rows', required=True, help='CSV rows as JSON array')
    
    dict_writer_parser = subparsers.add_parser('dict-writer', help='Write CSV file from dictionary')
    dict_writer_parser.add_argument('filename', help='CSV file to write')
    dict_writer_parser.add_argument('--fieldnames', nargs='+', required=True, help='Field names')
    dict_writer_parser.add_argument('--rows', required=True, help='CSV rows as JSON array of objects')
    
    # Sniffer commands
    sniffer_parser = subparsers.add_parser('sniffer', help='Detect CSV dialect')
    sniffer_parser.add_argument('filename', help='CSV file to analyze')
    sniffer_parser.add_argument('--sample-size', type=int, default=1024, help='Sample size for detection')
    
    # Dialect commands
    list_dialects_parser = subparsers.add_parser('list-dialects', help='List available dialects')
    
    register_dialect_parser = subparsers.add_parser('register-dialect', help='Register new dialect')
    register_dialect_parser.add_argument('name', help='Dialect name')
    register_dialect_parser.add_argument('--delimiter', default=',', help='Field delimiter')
    register_dialect_parser.add_argument('--quotechar', default='"', help='Quote character')
    register_dialect_parser.add_argument('--quoting', type=int, default=csv.QUOTE_MINIMAL, help='Quoting mode')
    register_dialect_parser.add_argument('--doublequote', action='store_true', default=True, help='Double quote')
    register_dialect_parser.add_argument('--skipinitialspace', action='store_true', help='Skip initial space')
    register_dialect_parser.add_argument('--lineterminator', default='\r\n', help='Line terminator')
    
    unregister_dialect_parser = subparsers.add_parser('unregister-dialect', help='Unregister dialect')
    unregister_dialect_parser.add_argument('name', help='Dialect name')
    
    get_dialect_parser = subparsers.add_parser('get-dialect', help='Get dialect information')
    get_dialect_parser.add_argument('name', help='Dialect name')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'reader':
            if args.dry_run:
                print(f"Would read CSV file: {args.filename}")
                return
            result = reader(args.filename, args.delimiter, args.quotechar, 
                          args.skipinitialspace, args.dialect)
        elif args.command == 'dict-reader':
            if args.dry_run:
                print(f"Would read CSV file as dictionary: {args.filename}")
                return
            result = dict_reader(args.filename, args.fieldnames, args.delimiter,
                               args.quotechar, args.skipinitialspace, args.dialect)
        elif args.command == 'writer':
            if args.dry_run:
                print(f"Would write CSV file: {args.filename}")
                return
            rows = json.loads(args.rows)
            result = writer(args.filename, rows, args.delimiter, args.quotechar,
                          args.quoting, args.skipinitialspace, args.dialect)
        elif args.command == 'dict-writer':
            if args.dry_run:
                print(f"Would write CSV file from dictionary: {args.filename}")
                return
            rows = json.loads(args.rows)
            result = dict_writer(args.filename, args.fieldnames, rows, args.delimiter,
                               args.quotechar, args.quoting, args.skipinitialspace, args.dialect)
        elif args.command == 'sniffer':
            if args.dry_run:
                print(f"Would detect CSV dialect: {args.filename}")
                return
            result = sniffer(args.filename, args.sample_size)
        elif args.command == 'list-dialects':
            result = list_dialects()
        elif args.command == 'register-dialect':
            if args.dry_run:
                print(f"Would register dialect: {args.name}")
                return
            result = register_dialect(args.name, args.delimiter, args.quotechar,
                                   args.quoting, args.doublequote, args.skipinitialspace,
                                   args.lineterminator)
        elif args.command == 'unregister-dialect':
            if args.dry_run:
                print(f"Would unregister dialect: {args.name}")
                return
            result = unregister_dialect(args.name)
        elif args.command == 'get-dialect':
            result = get_dialect(args.name)
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