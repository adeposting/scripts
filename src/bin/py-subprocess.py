#!/usr/bin/env python3
"""
Subprocess CLI - A command-line wrapper for subprocess module

This script provides CLI-friendly functions that wrap subprocess module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import subprocess
import sys
from typing import List, Optional, Union

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def run(args: List[str], capture_output: bool = False, text: bool = True,
        timeout: Optional[int] = None, check: bool = False, shell: bool = False,
        cwd: Optional[str] = None, env: Optional[dict] = None) -> dict:
    """Run command and return result."""
    try:
        result = subprocess.run(args, capture_output=capture_output, text=text,
                              timeout=timeout, check=check, shell=shell,
                              cwd=cwd, env=env)
        return {
            'returncode': result.returncode,
            'stdout': result.stdout,
            'stderr': result.stderr,
            'args': result.args
        }
    except subprocess.TimeoutExpired as e:
        return {
            'returncode': -1,
            'stdout': e.stdout,
            'stderr': e.stderr,
            'args': e.args,
            'timeout': e.timeout,
            'error': 'TimeoutExpired'
        }
    except subprocess.CalledProcessError as e:
        return {
            'returncode': e.returncode,
            'stdout': e.stdout,
            'stderr': e.stderr,
            'args': e.args,
            'error': 'CalledProcessError'
        }


def call(args: List[str], timeout: Optional[int] = None, shell: bool = False,
         cwd: Optional[str] = None, env: Optional[dict] = None) -> int:
    """Run command and return return code."""
    return subprocess.call(args, timeout=timeout, shell=shell, cwd=cwd, env=env)


def check_call(args: List[str], timeout: Optional[int] = None, shell: bool = False,
               cwd: Optional[str] = None, env: Optional[dict] = None) -> int:
    """Run command and check return code."""
    return subprocess.check_call(args, timeout=timeout, shell=shell, cwd=cwd, env=env)


def check_output(args: List[str], timeout: Optional[int] = None, shell: bool = False,
                cwd: Optional[str] = None, env: Optional[dict] = None,
                text: bool = True) -> str:
    """Run command and return output."""
    return subprocess.check_output(args, timeout=timeout, shell=shell, cwd=cwd, env=env, text=text)


def popen(args: List[str], mode: str = 'r', bufsize: int = -1, shell: bool = False,
          cwd: Optional[str] = None, env: Optional[dict] = None) -> dict:
    """Create Popen object and return info."""
    process = subprocess.Popen(args, mode=mode, bufsize=bufsize, shell=shell, cwd=cwd, env=env)
    return {
        'pid': process.pid,
        'args': process.args,
        'returncode': process.returncode
    }


def getoutput(cmd: str) -> str:
    """Get command output as string."""
    return subprocess.getoutput(cmd)


def getstatusoutput(cmd: str) -> tuple:
    """Get command status and output."""
    return subprocess.getstatusoutput(cmd)


def main():
    parser = argparse.ArgumentParser(
        description="Subprocess CLI - A command-line wrapper for subprocess module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-subprocess run "ls -la"
  py-subprocess call "echo hello"
  py-subprocess check-call "which python"
  py-subprocess check-output "date"
  py-subprocess get-output "pwd"
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--capture-output', action='store_true', help='Capture output')
    parser.add_argument('--text', action='store_true', default=True, help='Text mode (default)')
    parser.add_argument('--timeout', type=int, help='Timeout in seconds')
    parser.add_argument('--check', action='store_true', help='Check return code')
    parser.add_argument('--shell', action='store_true', help='Use shell')
    parser.add_argument('--cwd', help='Working directory')
    parser.add_argument('--env', help='Environment variables (JSON)')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Command execution
    run_parser = subparsers.add_parser('run', help='Run command and return result')
    run_parser.add_argument('args', nargs='+', help='Command and arguments')
    
    call_parser = subparsers.add_parser('call', help='Run command and return return code')
    call_parser.add_argument('args', nargs='+', help='Command and arguments')
    
    check_call_parser = subparsers.add_parser('check-call', help='Run command and check return code')
    check_call_parser.add_argument('args', nargs='+', help='Command and arguments')
    
    check_output_parser = subparsers.add_parser('check-output', help='Run command and return output')
    check_output_parser.add_argument('args', nargs='+', help='Command and arguments')
    
    popen_parser = subparsers.add_parser('popen', help='Create Popen object')
    popen_parser.add_argument('args', nargs='+', help='Command and arguments')
    popen_parser.add_argument('--mode', default='r', help='Mode')
    popen_parser.add_argument('--bufsize', type=int, default=-1, help='Buffer size')
    
    getoutput_parser = subparsers.add_parser('get-output', help='Get command output as string')
    getoutput_parser.add_argument('cmd', help='Command')
    
    getstatusoutput_parser = subparsers.add_parser('get-status-output', help='Get command status and output')
    getstatusoutput_parser.add_argument('cmd', help='Command')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        env_dict = None
        
        if args.env:
            try:
                env_dict = json.loads(args.env)
            except json.JSONDecodeError:
                print("Error: Invalid JSON in --env argument", file=sys.stderr)
                sys.exit(1)
        
        if args.command == 'run':
            if args.dry_run:
                print(f"Would run: {' '.join(args.args)}")
                return
            result = run(args.args, args.capture_output, args.text, args.timeout, 
                        args.check, args.shell, args.cwd, env_dict)
        elif args.command == 'call':
            if args.dry_run:
                print(f"Would call: {' '.join(args.args)}")
                return
            result = call(args.args, args.timeout, args.shell, args.cwd, env_dict)
        elif args.command == 'check-call':
            if args.dry_run:
                print(f"Would check-call: {' '.join(args.args)}")
                return
            result = check_call(args.args, args.timeout, args.shell, args.cwd, env_dict)
        elif args.command == 'check-output':
            if args.dry_run:
                print(f"Would check-output: {' '.join(args.args)}")
                return
            result = check_output(args.args, args.timeout, args.shell, args.cwd, env_dict, args.text)
        elif args.command == 'popen':
            if args.dry_run:
                print(f"Would popen: {' '.join(args.args)}")
                return
            result = popen(args.args, args.mode, args.bufsize, args.shell, args.cwd, env_dict)
        elif args.command == 'get-output':
            if args.dry_run:
                print(f"Would get-output: {args.cmd}")
                return
            result = getoutput(args.cmd)
        elif args.command == 'get-status-output':
            if args.dry_run:
                print(f"Would get-status-output: {args.cmd}")
                return
            status, output = getstatusoutput(args.cmd)
            result = {'status': status, 'output': output}
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