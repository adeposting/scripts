#!/usr/bin/env python3
"""
Datetime CLI - A command-line wrapper for datetime module

This script provides CLI-friendly functions that wrap datetime module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import sys
from datetime import datetime, date, time, timedelta, timezone
from typing import Optional


def now(timezone_name: Optional[str] = None) -> str:
    """Get current datetime."""
    if timezone_name:
        tz = timezone.utc if timezone_name.upper() == 'UTC' else None
        dt = datetime.now(tz)
    else:
        dt = datetime.now()
    return dt.isoformat()


def today() -> str:
    """Get current date."""
    return date.today().isoformat()


def utcnow() -> str:
    """Get current UTC datetime."""
    return datetime.utcnow().isoformat()


def fromisoformat(iso_string: str) -> dict:
    """Parse ISO format string."""
    dt = datetime.fromisoformat(iso_string)
    return {
        'year': dt.year,
        'month': dt.month,
        'day': dt.day,
        'hour': dt.hour,
        'minute': dt.minute,
        'second': dt.second,
        'microsecond': dt.microsecond,
        'tzinfo': str(dt.tzinfo) if dt.tzinfo else None,
        'isoformat': dt.isoformat()
    }


def strptime(date_string: str, format_string: str) -> dict:
    """Parse date string with format."""
    dt = datetime.strptime(date_string, format_string)
    return {
        'year': dt.year,
        'month': dt.month,
        'day': dt.day,
        'hour': dt.hour,
        'minute': dt.minute,
        'second': dt.second,
        'microsecond': dt.microsecond,
        'tzinfo': str(dt.tzinfo) if dt.tzinfo else None,
        'isoformat': dt.isoformat()
    }


def strftime(dt_string: str, format_string: str) -> str:
    """Format datetime string."""
    dt = datetime.fromisoformat(dt_string)
    return dt.strftime(format_string)


def add_days(dt_string: str, days: int) -> str:
    """Add days to datetime."""
    dt = datetime.fromisoformat(dt_string)
    new_dt = dt + timedelta(days=days)
    return new_dt.isoformat()


def add_hours(dt_string: str, hours: int) -> str:
    """Add hours to datetime."""
    dt = datetime.fromisoformat(dt_string)
    new_dt = dt + timedelta(hours=hours)
    return new_dt.isoformat()


def add_minutes(dt_string: str, minutes: int) -> str:
    """Add minutes to datetime."""
    dt = datetime.fromisoformat(dt_string)
    new_dt = dt + timedelta(minutes=minutes)
    return new_dt.isoformat()


def add_seconds(dt_string: str, seconds: int) -> str:
    """Add seconds to datetime."""
    dt = datetime.fromisoformat(dt_string)
    new_dt = dt + timedelta(seconds=seconds)
    return new_dt.isoformat()


def diff_days(dt1_string: str, dt2_string: str) -> int:
    """Get difference in days between two datetimes."""
    dt1 = datetime.fromisoformat(dt1_string)
    dt2 = datetime.fromisoformat(dt2_string)
    diff = dt2 - dt1
    return diff.days


def diff_seconds(dt1_string: str, dt2_string: str) -> int:
    """Get difference in seconds between two datetimes."""
    dt1 = datetime.fromisoformat(dt1_string)
    dt2 = datetime.fromisoformat(dt2_string)
    diff = dt2 - dt1
    return int(diff.total_seconds())


def weekday(dt_string: str) -> int:
    """Get weekday (0=Monday, 6=Sunday)."""
    dt = datetime.fromisoformat(dt_string)
    return dt.weekday()


def isoweekday(dt_string: str) -> int:
    """Get ISO weekday (1=Monday, 7=Sunday)."""
    dt = datetime.fromisoformat(dt_string)
    return dt.isoweekday()


def isocalendar(dt_string: str) -> dict:
    """Get ISO calendar tuple (year, week, weekday)."""
    dt = datetime.fromisoformat(dt_string)
    year, week, weekday = dt.isocalendar()
    return {'year': year, 'week': week, 'weekday': weekday}


def timestamp(dt_string: str) -> int:
    """Get timestamp."""
    dt = datetime.fromisoformat(dt_string)
    return int(dt.timestamp())


def fromtimestamp(timestamp_value: float) -> str:
    """Create datetime from timestamp."""
    dt = datetime.fromtimestamp(timestamp_value)
    return dt.isoformat()


def utcfromtimestamp(timestamp_value: float) -> str:
    """Create UTC datetime from timestamp."""
    dt = datetime.utcfromtimestamp(timestamp_value)
    return dt.isoformat()


def replace(dt_string: str, **kwargs) -> str:
    """Replace datetime components."""
    dt = datetime.fromisoformat(dt_string)
    new_dt = dt.replace(**kwargs)
    return new_dt.isoformat()


def main():
    parser = argparse.ArgumentParser(
        description="Datetime CLI - A command-line wrapper for datetime module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-datetime now
  py-datetime today
  py-datetime fromisoformat "2023-12-25T10:30:00"
  py-datetime strptime "2023-12-25 10:30:00" "%Y-%m-%d %H:%M:%S"
  py-datetime add-days "2023-12-25T10:30:00" 7
  py-datetime diff-days "2023-12-25T10:30:00" "2024-01-01T10:30:00"
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Current time/date
    now_parser = subparsers.add_parser('now', help='Get current datetime')
    now_parser.add_argument('--timezone', help='Timezone (e.g., UTC)')
    
    today_parser = subparsers.add_parser('today', help='Get current date')
    
    utcnow_parser = subparsers.add_parser('utcnow', help='Get current UTC datetime')
    
    # Parsing
    fromisoformat_parser = subparsers.add_parser('fromisoformat', help='Parse ISO format string')
    fromisoformat_parser.add_argument('iso_string', help='ISO format string')
    
    strptime_parser = subparsers.add_parser('strptime', help='Parse date string with format')
    strptime_parser.add_argument('date_string', help='Date string')
    strptime_parser.add_argument('format_string', help='Format string')
    
    strftime_parser = subparsers.add_parser('strftime', help='Format datetime string')
    strftime_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    strftime_parser.add_argument('format_string', help='Format string')
    
    # Arithmetic
    add_days_parser = subparsers.add_parser('add-days', help='Add days to datetime')
    add_days_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    add_days_parser.add_argument('days', type=int, help='Number of days')
    
    add_hours_parser = subparsers.add_parser('add-hours', help='Add hours to datetime')
    add_hours_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    add_hours_parser.add_argument('hours', type=int, help='Number of hours')
    
    add_minutes_parser = subparsers.add_parser('add-minutes', help='Add minutes to datetime')
    add_minutes_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    add_minutes_parser.add_argument('minutes', type=int, help='Number of minutes')
    
    add_seconds_parser = subparsers.add_parser('add-seconds', help='Add seconds to datetime')
    add_seconds_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    add_seconds_parser.add_argument('seconds', type=int, help='Number of seconds')
    
    # Differences
    diff_days_parser = subparsers.add_parser('diff-days', help='Get difference in days between two datetimes')
    diff_days_parser.add_argument('dt1_string', help='First datetime string (ISO format)')
    diff_days_parser.add_argument('dt2_string', help='Second datetime string (ISO format)')
    
    diff_seconds_parser = subparsers.add_parser('diff-seconds', help='Get difference in seconds between two datetimes')
    diff_seconds_parser.add_argument('dt1_string', help='First datetime string (ISO format)')
    diff_seconds_parser.add_argument('dt2_string', help='Second datetime string (ISO format)')
    
    # Calendar
    weekday_parser = subparsers.add_parser('weekday', help='Get weekday (0=Monday, 6=Sunday)')
    weekday_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    
    isoweekday_parser = subparsers.add_parser('isoweekday', help='Get ISO weekday (1=Monday, 7=Sunday)')
    isoweekday_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    
    isocalendar_parser = subparsers.add_parser('isocalendar', help='Get ISO calendar tuple')
    isocalendar_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    
    # Timestamps
    timestamp_parser = subparsers.add_parser('timestamp', help='Get timestamp')
    timestamp_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    
    fromtimestamp_parser = subparsers.add_parser('fromtimestamp', help='Create datetime from timestamp')
    fromtimestamp_parser.add_argument('timestamp_value', type=float, help='Timestamp')
    
    utcfromtimestamp_parser = subparsers.add_parser('utcfromtimestamp', help='Create UTC datetime from timestamp')
    utcfromtimestamp_parser.add_argument('timestamp_value', type=float, help='Timestamp')
    
    # Replacement
    replace_parser = subparsers.add_parser('replace', help='Replace datetime components')
    replace_parser.add_argument('dt_string', help='Datetime string (ISO format)')
    replace_parser.add_argument('--year', type=int, help='Year')
    replace_parser.add_argument('--month', type=int, help='Month')
    replace_parser.add_argument('--day', type=int, help='Day')
    replace_parser.add_argument('--hour', type=int, help='Hour')
    replace_parser.add_argument('--minute', type=int, help='Minute')
    replace_parser.add_argument('--second', type=int, help='Second')
    replace_parser.add_argument('--microsecond', type=int, help='Microsecond')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'now':
            result = now(args.timezone)
        elif args.command == 'today':
            result = today()
        elif args.command == 'utcnow':
            result = utcnow()
        elif args.command == 'fromisoformat':
            result = fromisoformat(args.iso_string)
        elif args.command == 'strptime':
            result = strptime(args.date_string, args.format_string)
        elif args.command == 'strftime':
            result = strftime(args.dt_string, args.format_string)
        elif args.command == 'add-days':
            result = add_days(args.dt_string, args.days)
        elif args.command == 'add-hours':
            result = add_hours(args.dt_string, args.hours)
        elif args.command == 'add-minutes':
            result = add_minutes(args.dt_string, args.minutes)
        elif args.command == 'add-seconds':
            result = add_seconds(args.dt_string, args.seconds)
        elif args.command == 'diff-days':
            result = diff_days(args.dt1_string, args.dt2_string)
        elif args.command == 'diff-seconds':
            result = diff_seconds(args.dt1_string, args.dt2_string)
        elif args.command == 'weekday':
            result = weekday(args.dt_string)
        elif args.command == 'isoweekday':
            result = isoweekday(args.dt_string)
        elif args.command == 'isocalendar':
            result = isocalendar(args.dt_string)
        elif args.command == 'timestamp':
            result = timestamp(args.dt_string)
        elif args.command == 'fromtimestamp':
            result = fromtimestamp(args.timestamp_value)
        elif args.command == 'utcfromtimestamp':
            result = utcfromtimestamp(args.timestamp_value)
        elif args.command == 'replace':
            kwargs = {}
            if args.year is not None:
                kwargs['year'] = args.year
            if args.month is not None:
                kwargs['month'] = args.month
            if args.day is not None:
                kwargs['day'] = args.day
            if args.hour is not None:
                kwargs['hour'] = args.hour
            if args.minute is not None:
                kwargs['minute'] = args.minute
            if args.second is not None:
                kwargs['second'] = args.second
            if args.microsecond is not None:
                kwargs['microsecond'] = args.microsecond
            result = replace(args.dt_string, **kwargs)
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