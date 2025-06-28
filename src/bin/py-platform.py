#!/usr/bin/env python3
"""
Platform CLI - A command-line wrapper for platform module

This script provides CLI-friendly functions that wrap platform module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import platform
import sys
from typing import Any, Dict, Optional

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def system() -> str:
    """Get the system/OS name."""
    return platform.system()


def machine() -> str:
    """Get the machine type."""
    return platform.machine()


def processor() -> str:
    """Get the processor name."""
    return platform.processor()


def node() -> str:
    """Get the network name of the machine."""
    return platform.node()


def release() -> str:
    """Get the system release."""
    return platform.release()


def version() -> str:
    """Get the system version."""
    return platform.version()


def architecture() -> tuple:
    """Get the architecture tuple."""
    return platform.architecture()


def uname() -> Dict[str, str]:
    """Get system information as uname tuple."""
    uname_info = platform.uname()
    return {
        'system': uname_info.system,
        'node': uname_info.node,
        'release': uname_info.release,
        'version': uname_info.version,
        'machine': uname_info.machine,
        'processor': uname_info.processor
    }


def platform_info() -> str:
    """Get platform information."""
    return platform.platform()


def python_implementation() -> str:
    """Get Python implementation name."""
    return platform.python_implementation()


def python_version() -> str:
    """Get Python version."""
    return platform.python_version()


def python_version_tuple() -> tuple:
    """Get Python version as tuple."""
    return platform.python_version_tuple()


def python_build() -> tuple:
    """Get Python build information."""
    return platform.python_build()


def python_compiler() -> str:
    """Get Python compiler information."""
    return platform.python_compiler()


def python_branch() -> str:
    """Get Python branch information."""
    return platform.python_branch()


def python_revision() -> str:
    """Get Python revision information."""
    return platform.python_revision()


def libc_ver() -> tuple:
    """Get libc version information."""
    return platform.libc_ver()


def win32_ver() -> tuple:
    """Get Windows version information."""
    return platform.win32_ver()


def mac_ver() -> tuple:
    """Get macOS version information."""
    return platform.mac_ver()


def java_ver() -> tuple:
    """Get Java version information."""
    return platform.java_ver()


def dist() -> tuple:
    """Get Linux distribution information."""
    return platform.dist()


def linux_distribution() -> tuple:
    """Get Linux distribution information."""
    return platform.linux_distribution()


def system_alias() -> tuple:
    """Get system alias information."""
    return platform.system_alias()


def machine_alias() -> tuple:
    """Get machine alias information."""
    return platform.machine_alias()


def processor_alias() -> tuple:
    """Get processor alias information."""
    return platform.processor_alias()


def all_info() -> Dict[str, Any]:
    """Get all platform information."""
    return {
        'system': system(),
        'machine': machine(),
        'processor': processor(),
        'node': node(),
        'release': release(),
        'version': version(),
        'architecture': architecture(),
        'uname': uname(),
        'platform': platform_info(),
        'python_implementation': python_implementation(),
        'python_version': python_version(),
        'python_version_tuple': python_version_tuple(),
        'python_build': python_build(),
        'python_compiler': python_compiler(),
        'python_branch': python_branch(),
        'python_revision': python_revision(),
        'libc_ver': libc_ver(),
        'win32_ver': win32_ver(),
        'mac_ver': mac_ver(),
        'java_ver': java_ver(),
        'dist': dist(),
        'linux_distribution': linux_distribution(),
        'system_alias': system_alias(),
        'machine_alias': machine_alias(),
        'processor_alias': processor_alias()
    }


def main():
    parser = argparse.ArgumentParser(
        description="Platform CLI - A command-line wrapper for platform module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-platform system
  py-platform machine
  py-platform processor
  py-platform node
  py-platform release
  py-platform version
  py-platform all-info
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # System information commands
    subparsers.add_parser('system', help='Get the system/OS name')
    subparsers.add_parser('machine', help='Get the machine type')
    subparsers.add_parser('processor', help='Get the processor name')
    subparsers.add_parser('node', help='Get the network name of the machine')
    subparsers.add_parser('release', help='Get the system release')
    subparsers.add_parser('version', help='Get the system version')
    subparsers.add_parser('architecture', help='Get the architecture tuple')
    subparsers.add_parser('uname', help='Get system information as uname tuple')
    subparsers.add_parser('platform-info', help='Get platform information')
    
    # Python information commands
    subparsers.add_parser('python-implementation', help='Get Python implementation name')
    subparsers.add_parser('python-version', help='Get Python version')
    subparsers.add_parser('python-version-tuple', help='Get Python version as tuple')
    subparsers.add_parser('python-build', help='Get Python build information')
    subparsers.add_parser('python-compiler', help='Get Python compiler information')
    subparsers.add_parser('python-branch', help='Get Python branch information')
    subparsers.add_parser('python-revision', help='Get Python revision information')
    
    # Library information commands
    subparsers.add_parser('libc-ver', help='Get libc version information')
    subparsers.add_parser('win32-ver', help='Get Windows version information')
    subparsers.add_parser('mac-ver', help='Get macOS version information')
    subparsers.add_parser('java-ver', help='Get Java version information')
    subparsers.add_parser('dist', help='Get Linux distribution information')
    subparsers.add_parser('linux-distribution', help='Get Linux distribution information')
    
    # Alias commands
    subparsers.add_parser('system-alias', help='Get system alias information')
    subparsers.add_parser('machine-alias', help='Get machine alias information')
    subparsers.add_parser('processor-alias', help='Get processor alias information')
    
    # All information command
    subparsers.add_parser('all-info', help='Get all platform information')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'system':
            result = system()
        elif args.command == 'machine':
            result = machine()
        elif args.command == 'processor':
            result = processor()
        elif args.command == 'node':
            result = node()
        elif args.command == 'release':
            result = release()
        elif args.command == 'version':
            result = version()
        elif args.command == 'architecture':
            result = architecture()
        elif args.command == 'uname':
            result = uname()
        elif args.command == 'platform-info':
            result = platform_info()
        elif args.command == 'python-implementation':
            result = python_implementation()
        elif args.command == 'python-version':
            result = python_version()
        elif args.command == 'python-version-tuple':
            result = python_version_tuple()
        elif args.command == 'python-build':
            result = python_build()
        elif args.command == 'python-compiler':
            result = python_compiler()
        elif args.command == 'python-branch':
            result = python_branch()
        elif args.command == 'python-revision':
            result = python_revision()
        elif args.command == 'libc-ver':
            result = libc_ver()
        elif args.command == 'win32-ver':
            result = win32_ver()
        elif args.command == 'mac-ver':
            result = mac_ver()
        elif args.command == 'java-ver':
            result = java_ver()
        elif args.command == 'dist':
            result = dist()
        elif args.command == 'linux-distribution':
            result = linux_distribution()
        elif args.command == 'system-alias':
            result = system_alias()
        elif args.command == 'machine-alias':
            result = machine_alias()
        elif args.command == 'processor-alias':
            result = processor_alias()
        elif args.command == 'all-info':
            result = all_info()
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