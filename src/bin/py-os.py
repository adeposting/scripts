#!/usr/bin/env python3
"""
OS CLI - A command-line wrapper for os module

This script provides CLI-friendly functions that wrap os module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import os
import sys
from typing import Any, Dict, List, Optional, Union


def environ_get(key: str, default: Optional[str] = None) -> str:
    """Get environment variable."""
    return os.environ.get(key, default or "")


def environ_set(key: str, value: str) -> None:
    """Set environment variable."""
    os.environ[key] = value


def environ_unset(key: str) -> None:
    """Unset environment variable."""
    os.environ.pop(key, None)


def getcwd() -> str:
    """Get current working directory."""
    return os.getcwd()


def listdir(path: str = ".") -> List[str]:
    """List directory contents."""
    return os.listdir(path)


def makedirs(path: str, mode: int = 0o777, exist_ok: bool = False) -> str:
    """Create directories recursively."""
    os.makedirs(path, mode=mode, exist_ok=exist_ok)
    return path


def remove(path: str) -> None:
    """Remove file."""
    os.remove(path)


def rmdir(path: str) -> None:
    """Remove empty directory."""
    os.rmdir(path)


def rename(src: str, dst: str) -> None:
    """Rename file or directory."""
    os.rename(src, dst)


def stat(path: str) -> Dict[str, Any]:
    """Get file stats."""
    stat_info = os.stat(path)
    return {
        'st_mode': stat_info.st_mode,
        'st_ino': stat_info.st_ino,
        'st_dev': stat_info.st_dev,
        'st_nlink': stat_info.st_nlink,
        'st_uid': stat_info.st_uid,
        'st_gid': stat_info.st_gid,
        'st_size': stat_info.st_size,
        'st_atime': stat_info.st_atime,
        'st_mtime': stat_info.st_mtime,
        'st_ctime': stat_info.st_ctime
    }


def system(command: str) -> int:
    """Execute shell command."""
    return os.system(command)


def walk(top: str, topdown: bool = True, onerror: Optional[callable] = None, 
         followlinks: bool = False) -> List[Dict[str, Any]]:
    """Walk directory tree."""
    result = []
    for root, dirs, files in os.walk(top, topdown=topdown, onerror=onerror, 
                                   followlinks=followlinks):
        result.append({
            'root': root,
            'dirs': dirs,
            'files': files
        })
    return result


def chdir(path: str) -> str:
    """Change current directory."""
    os.chdir(path)
    return os.getcwd()


def getlogin() -> str:
    """Get current user login name."""
    return os.getlogin()


def cpu_count() -> int:
    """Get CPU count."""
    return os.cpu_count()


def getpid() -> int:
    """Get current process ID."""
    return os.getpid()


def kill(pid: int, sig: int) -> None:
    """Send signal to process."""
    os.kill(pid, sig)


def execvp(file: str, args: List[str]) -> None:
    """Execute program with PATH search."""
    os.execvp(file, args)


def startfile(path: str) -> None:
    """Start file with default application."""
    os.startfile(path)


# os.path functions
def path_join(*paths: str) -> str:
    """Join path components."""
    return os.path.join(*paths)


def path_split(path: str) -> tuple:
    """Split path into head and tail."""
    return os.path.split(path)


def path_splitext(path: str) -> tuple:
    """Split path into root and extension."""
    return os.path.splitext(path)


def path_basename(path: str) -> str:
    """Get basename of path."""
    return os.path.basename(path)


def path_dirname(path: str) -> str:
    """Get dirname of path."""
    return os.path.dirname(path)


def path_abspath(path: str) -> str:
    """Get absolute path."""
    return os.path.abspath(path)


def path_realpath(path: str) -> str:
    """Get real path (resolve symlinks)."""
    return os.path.realpath(path)


def path_normpath(path: str) -> str:
    """Normalize path."""
    return os.path.normpath(path)


def path_exists(path: str) -> bool:
    """Check if path exists."""
    return os.path.exists(path)


def path_isfile(path: str) -> bool:
    """Check if path is a file."""
    return os.path.isfile(path)


def path_isdir(path: str) -> bool:
    """Check if path is a directory."""
    return os.path.isdir(path)


def path_islink(path: str) -> bool:
    """Check if path is a symlink."""
    return os.path.islink(path)


def path_ismount(path: str) -> bool:
    """Check if path is a mount point."""
    return os.path.ismount(path)


def path_getsize(path: str) -> int:
    """Get file size."""
    return os.path.getsize(path)


def path_getmtime(path: str) -> float:
    """Get file modification time."""
    return os.path.getmtime(path)


def path_getctime(path: str) -> float:
    """Get file creation time."""
    return os.path.getctime(path)


def path_getatime(path: str) -> float:
    """Get file access time."""
    return os.path.getatime(path)


def path_expanduser(path: str) -> str:
    """Expand user home directory."""
    return os.path.expanduser(path)


def path_expandvars(path: str) -> str:
    """Expand environment variables."""
    return os.path.expandvars(path)


def path_commonpath(paths: List[str]) -> str:
    """Get common path prefix."""
    return os.path.commonpath(paths)


def path_commonprefix(paths: List[str]) -> str:
    """Get common path prefix (string)."""
    return os.path.commonprefix(paths)


def path_relpath(path: str, start: str = ".") -> str:
    """Get relative path."""
    return os.path.relpath(path, start)


def path_samefile(path1: str, path2: str) -> bool:
    """Check if paths refer to same file."""
    return os.path.samefile(path1, path2)


def path_sameopenfile(fp1: int, fp2: int) -> bool:
    """Check if file descriptors refer to same file."""
    return os.path.sameopenfile(fp1, fp2)


def path_samestat(stat1: tuple, stat2: tuple) -> bool:
    """Check if stat tuples refer to same file."""
    return os.path.samestat(stat1, stat2)


def main():
    parser = argparse.ArgumentParser(
        description="OS CLI - A command-line wrapper for os module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-os getcwd
  py-os listdir /path/to/dir
  py-os makedirs /path/to/dir --exist-ok
  py-os environ-get HOME
  py-os path-join /path /to /file
  py-os stat /path/to/file --json
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Environment commands
    env_get_parser = subparsers.add_parser('environ-get', help='Get environment variable')
    env_get_parser.add_argument('key', help='Environment variable name')
    env_get_parser.add_argument('--default', help='Default value if not set')
    
    env_set_parser = subparsers.add_parser('environ-set', help='Set environment variable')
    env_set_parser.add_argument('key', help='Environment variable name')
    env_set_parser.add_argument('value', help='Environment variable value')
    
    env_unset_parser = subparsers.add_parser('environ-unset', help='Unset environment variable')
    env_unset_parser.add_argument('key', help='Environment variable name')
    
    # Directory and file operations
    getcwd_parser = subparsers.add_parser('getcwd', help='Get current working directory')
    
    listdir_parser = subparsers.add_parser('listdir', help='List directory contents')
    listdir_parser.add_argument('path', nargs='?', default='.', help='Directory path')
    
    makedirs_parser = subparsers.add_parser('makedirs', help='Create directories recursively')
    makedirs_parser.add_argument('path', help='Directory path to create')
    makedirs_parser.add_argument('--mode', type=int, default=0o777, help='Directory mode')
    makedirs_parser.add_argument('--exist-ok', action='store_true', help='Don\'t error if directory exists')
    
    remove_parser = subparsers.add_parser('remove', help='Remove file')
    remove_parser.add_argument('path', help='File path to remove')
    
    rmdir_parser = subparsers.add_parser('rmdir', help='Remove empty directory')
    rmdir_parser.add_argument('path', help='Directory path to remove')
    
    rename_parser = subparsers.add_parser('rename', help='Rename file or directory')
    rename_parser.add_argument('src', help='Source path')
    rename_parser.add_argument('dst', help='Destination path')
    
    stat_parser = subparsers.add_parser('stat', help='Get file stats')
    stat_parser.add_argument('path', help='File path')
    
    system_parser = subparsers.add_parser('system', help='Execute shell command')
    system_parser.add_argument('command', help='Command to execute')
    
    walk_parser = subparsers.add_parser('walk', help='Walk directory tree')
    walk_parser.add_argument('top', help='Top directory path')
    walk_parser.add_argument('--no-topdown', action='store_true', help='Walk bottom-up')
    walk_parser.add_argument('--follow-links', action='store_true', help='Follow symlinks')
    
    chdir_parser = subparsers.add_parser('chdir', help='Change current directory')
    chdir_parser.add_argument('path', help='Directory path')
    
    # Process and system info
    getlogin_parser = subparsers.add_parser('getlogin', help='Get current user login name')
    
    cpu_count_parser = subparsers.add_parser('cpu-count', help='Get CPU count')
    
    getpid_parser = subparsers.add_parser('getpid', help='Get current process ID')
    
    kill_parser = subparsers.add_parser('kill', help='Send signal to process')
    kill_parser.add_argument('pid', type=int, help='Process ID')
    kill_parser.add_argument('sig', type=int, help='Signal number')
    
    execvp_parser = subparsers.add_parser('execvp', help='Execute program with PATH search')
    execvp_parser.add_argument('file', help='Program name')
    execvp_parser.add_argument('args', nargs='+', help='Program arguments')
    
    startfile_parser = subparsers.add_parser('startfile', help='Start file with default application')
    startfile_parser.add_argument('path', help='File path')
    
    # os.path commands
    path_join_parser = subparsers.add_parser('path-join', help='Join path components')
    path_join_parser.add_argument('paths', nargs='+', help='Path components')
    
    path_split_parser = subparsers.add_parser('path-split', help='Split path into head and tail')
    path_split_parser.add_argument('path', help='Path to split')
    
    path_splitext_parser = subparsers.add_parser('path-splitext', help='Split path into root and extension')
    path_splitext_parser.add_argument('path', help='Path to split')
    
    path_basename_parser = subparsers.add_parser('path-basename', help='Get basename of path')
    path_basename_parser.add_argument('path', help='Path')
    
    path_dirname_parser = subparsers.add_parser('path-dirname', help='Get dirname of path')
    path_dirname_parser.add_argument('path', help='Path')
    
    path_abspath_parser = subparsers.add_parser('path-abspath', help='Get absolute path')
    path_abspath_parser.add_argument('path', help='Path')
    
    path_realpath_parser = subparsers.add_parser('path-realpath', help='Get real path (resolve symlinks)')
    path_realpath_parser.add_argument('path', help='Path')
    
    path_normpath_parser = subparsers.add_parser('path-normpath', help='Normalize path')
    path_normpath_parser.add_argument('path', help='Path')
    
    path_exists_parser = subparsers.add_parser('path-exists', help='Check if path exists')
    path_exists_parser.add_argument('path', help='Path')
    
    path_isfile_parser = subparsers.add_parser('path-isfile', help='Check if path is a file')
    path_isfile_parser.add_argument('path', help='Path')
    
    path_isdir_parser = subparsers.add_parser('path-isdir', help='Check if path is a directory')
    path_isdir_parser.add_argument('path', help='Path')
    
    path_islink_parser = subparsers.add_parser('path-islink', help='Check if path is a symlink')
    path_islink_parser.add_argument('path', help='Path')
    
    path_ismount_parser = subparsers.add_parser('path-ismount', help='Check if path is a mount point')
    path_ismount_parser.add_argument('path', help='Path')
    
    path_getsize_parser = subparsers.add_parser('path-getsize', help='Get file size')
    path_getsize_parser.add_argument('path', help='Path')
    
    path_getmtime_parser = subparsers.add_parser('path-getmtime', help='Get file modification time')
    path_getmtime_parser.add_argument('path', help='Path')
    
    path_getctime_parser = subparsers.add_parser('path-getctime', help='Get file creation time')
    path_getctime_parser.add_argument('path', help='Path')
    
    path_getatime_parser = subparsers.add_parser('path-getatime', help='Get file access time')
    path_getatime_parser.add_argument('path', help='Path')
    
    path_expanduser_parser = subparsers.add_parser('path-expanduser', help='Expand user home directory')
    path_expanduser_parser.add_argument('path', help='Path')
    
    path_expandvars_parser = subparsers.add_parser('path-expandvars', help='Expand environment variables')
    path_expandvars_parser.add_argument('path', help='Path')
    
    path_commonpath_parser = subparsers.add_parser('path-commonpath', help='Get common path prefix')
    path_commonpath_parser.add_argument('paths', nargs='+', help='Paths')
    
    path_commonprefix_parser = subparsers.add_parser('path-commonprefix', help='Get common path prefix (string)')
    path_commonprefix_parser.add_argument('paths', nargs='+', help='Paths')
    
    path_relpath_parser = subparsers.add_parser('path-relpath', help='Get relative path')
    path_relpath_parser.add_argument('path', help='Path')
    path_relpath_parser.add_argument('--start', default='.', help='Start directory')
    
    path_samefile_parser = subparsers.add_parser('path-samefile', help='Check if paths refer to same file')
    path_samefile_parser.add_argument('path1', help='First path')
    path_samefile_parser.add_argument('path2', help='Second path')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'environ-get':
            result = environ_get(args.key, args.default)
        elif args.command == 'environ-set':
            if args.dry_run:
                print(f"Would set {args.key}={args.value}")
                return
            environ_set(args.key, args.value)
            result = f"Set {args.key}={args.value}"
        elif args.command == 'environ-unset':
            if args.dry_run:
                print(f"Would unset {args.key}")
                return
            environ_unset(args.key)
            result = f"Unset {args.key}"
        elif args.command == 'getcwd':
            result = getcwd()
        elif args.command == 'listdir':
            result = listdir(args.path)
        elif args.command == 'makedirs':
            if args.dry_run:
                print(f"Would create directory: {args.path}")
                return
            result = makedirs(args.path, args.mode, args.exist_ok)
        elif args.command == 'remove':
            if args.dry_run:
                print(f"Would remove file: {args.path}")
                return
            remove(args.path)
            result = f"Removed {args.path}"
        elif args.command == 'rmdir':
            if args.dry_run:
                print(f"Would remove directory: {args.path}")
                return
            rmdir(args.path)
            result = f"Removed directory {args.path}"
        elif args.command == 'rename':
            if args.dry_run:
                print(f"Would rename {args.src} to {args.dst}")
                return
            rename(args.src, args.dst)
            result = f"Renamed {args.src} to {args.dst}"
        elif args.command == 'stat':
            result = stat(args.path)
        elif args.command == 'system':
            if args.dry_run:
                print(f"Would execute: {args.command}")
                return
            result = system(args.command)
        elif args.command == 'walk':
            result = walk(args.top, not args.no_topdown, None, args.follow_links)
        elif args.command == 'chdir':
            if args.dry_run:
                print(f"Would change directory to: {args.path}")
                return
            result = chdir(args.path)
        elif args.command == 'getlogin':
            result = getlogin()
        elif args.command == 'cpu-count':
            result = cpu_count()
        elif args.command == 'getpid':
            result = getpid()
        elif args.command == 'kill':
            if args.dry_run:
                print(f"Would send signal {args.sig} to process {args.pid}")
                return
            kill(args.pid, args.sig)
            result = f"Sent signal {args.sig} to process {args.pid}"
        elif args.command == 'execvp':
            if args.dry_run:
                print(f"Would execute: {args.file} {' '.join(args.args)}")
                return
            execvp(args.file, args.args)
        elif args.command == 'startfile':
            if args.dry_run:
                print(f"Would start file: {args.path}")
                return
            startfile(args.path)
            result = f"Started {args.path}"
        elif args.command == 'path-join':
            result = path_join(*args.paths)
        elif args.command == 'path-split':
            head, tail = path_split(args.path)
            result = {'head': head, 'tail': tail}
        elif args.command == 'path-splitext':
            root, ext = path_splitext(args.path)
            result = {'root': root, 'ext': ext}
        elif args.command == 'path-basename':
            result = path_basename(args.path)
        elif args.command == 'path-dirname':
            result = path_dirname(args.path)
        elif args.command == 'path-abspath':
            result = path_abspath(args.path)
        elif args.command == 'path-realpath':
            result = path_realpath(args.path)
        elif args.command == 'path-normpath':
            result = path_normpath(args.path)
        elif args.command == 'path-exists':
            result = path_exists(args.path)
        elif args.command == 'path-isfile':
            result = path_isfile(args.path)
        elif args.command == 'path-isdir':
            result = path_isdir(args.path)
        elif args.command == 'path-islink':
            result = path_islink(args.path)
        elif args.command == 'path-ismount':
            result = path_ismount(args.path)
        elif args.command == 'path-getsize':
            result = path_getsize(args.path)
        elif args.command == 'path-getmtime':
            result = path_getmtime(args.path)
        elif args.command == 'path-getctime':
            result = path_getctime(args.path)
        elif args.command == 'path-getatime':
            result = path_getatime(args.path)
        elif args.command == 'path-expanduser':
            result = path_expanduser(args.path)
        elif args.command == 'path-expandvars':
            result = path_expandvars(args.path)
        elif args.command == 'path-commonpath':
            result = path_commonpath(args.paths)
        elif args.command == 'path-commonprefix':
            result = path_commonprefix(args.paths)
        elif args.command == 'path-relpath':
            result = path_relpath(args.path, args.start)
        elif args.command == 'path-samefile':
            result = path_samefile(args.path1, args.path2)
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
            if args.json:
                print(json.dumps(result, indent=2))
            else:
                if isinstance(result, (list, dict)):
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