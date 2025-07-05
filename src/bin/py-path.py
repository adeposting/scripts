#!/usr/bin/env python3
"""
Path CLI - A command-line wrapper for pathlib.Path

This script provides CLI-friendly functions that wrap pathlib.Path functionality
for use in shell scripts and Makefiles.
"""

import argparse
import os
import sys
from pathlib import Path
from typing import List, Optional, Union

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def resolve_path(path_str: str) -> Path:
    """Resolve a path string to an absolute Path object."""
    return Path(path_str).resolve()


def absolute_path(path_str: str) -> str:
    """Get absolute path as string."""
    return str(resolve_path(path_str))


def relative_path(path_str: str, base: Optional[str] = None) -> str:
    """Get relative path as string."""
    path = Path(path_str)
    if base:
        base_path = Path(base)
        return str(path.relative_to(base_path))
    return str(path)


def exists(path_str: str) -> bool:
    """Check if path exists."""
    return Path(path_str).exists()


def is_file(path_str: str) -> bool:
    """Check if path is a file."""
    return Path(path_str).is_file()


def is_dir(path_str: str) -> bool:
    """Check if path is a directory."""
    return Path(path_str).is_dir()


def is_symlink(path_str: str) -> bool:
    """Check if path is a symlink."""
    return Path(path_str).is_symlink()


def parent(path_str: str) -> str:
    """Get parent directory."""
    return str(Path(path_str).parent)


def name(path_str: str) -> str:
    """Get filename."""
    return Path(path_str).name


def stem(path_str: str) -> str:
    """Get filename without extension."""
    return Path(path_str).stem


def suffix(path_str: str) -> str:
    """Get file extension."""
    return Path(path_str).suffix


def suffixes(path_str: str) -> List[str]:
    """Get all file extensions."""
    return Path(path_str).suffixes


def parts(path_str: str) -> List[str]:
    """Get path parts."""
    return list(Path(path_str).parts)


def join(*paths: str) -> str:
    """Join paths."""
    return str(Path(*paths))


def glob(pattern: str, path_str: str = ".") -> List[str]:
    """Glob pattern matching."""
    return [str(p) for p in Path(path_str).glob(pattern)]


def rglob(pattern: str, path_str: str = ".") -> List[str]:
    """Recursive glob pattern matching."""
    return [str(p) for p in Path(path_str).rglob(pattern)]


def mkdir(path_str: str, parents: bool = False, exist_ok: bool = False) -> str:
    """Create directory."""
    path = Path(path_str)
    path.mkdir(parents=parents, exist_ok=exist_ok)
    return str(path)


def touch(path_str: str, exist_ok: bool = True) -> str:
    """Create file (touch)."""
    path = Path(path_str)
    path.touch(exist_ok=exist_ok)
    return str(path)


def unlink(path_str: str, missing_ok: bool = False) -> None:
    """Remove file or symlink."""
    Path(path_str).unlink(missing_ok=missing_ok)


def rmdir(path_str: str) -> None:
    """Remove empty directory."""
    Path(path_str).rmdir()


def rmtree(path_str: str) -> None:
    """Remove directory tree."""
    import shutil
    shutil.rmtree(path_str)


def copy(src: str, dst: str, overwrite: bool = False) -> str:
    """Copy file or directory."""
    import shutil
    src_path = Path(src)
    dst_path = Path(dst)
    
    if src_path.is_file():
        if dst_path.exists() and not overwrite:
            raise FileExistsError(f"Destination exists: {dst}")
        shutil.copy2(src_path, dst_path)
    elif src_path.is_dir():
        if dst_path.exists() and not overwrite:
            raise FileExistsError(f"Destination exists: {dst}")
        shutil.copytree(src_path, dst_path, dirs_exist_ok=overwrite)
    else:
        raise FileNotFoundError(f"Source not found: {src}")
    
    return str(dst_path)


def move(src: str, dst: str, overwrite: bool = False) -> str:
    """Move file or directory."""
    import shutil
    src_path = Path(src)
    dst_path = Path(dst)
    
    if dst_path.exists() and not overwrite:
        raise FileExistsError(f"Destination exists: {dst}")
    
    shutil.move(str(src_path), str(dst_path))
    return str(dst_path)


def symlink(src: str, dst: str, target_is_directory: bool = False) -> str:
    """Create symlink."""
    src_path = Path(src)
    dst_path = Path(dst)
    dst_path.symlink_to(src_path, target_is_directory=target_is_directory)
    return str(dst_path)


def readlink(path_str: str) -> str:
    """Read symlink target."""
    return str(Path(path_str).readlink())


def stat(path_str: str, format_str: str = "size") -> str:
    """Get file stats."""
    stat_info = Path(path_str).stat()
    
    if format_str == "size":
        return str(stat_info.st_size)
    elif format_str == "mtime":
        return str(stat_info.st_mtime)
    elif format_str == "ctime":
        return str(stat_info.st_ctime)
    elif format_str == "atime":
        return str(stat_info.st_atime)
    elif format_str == "mode":
        return str(stat_info.st_mode)
    elif format_str == "uid":
        return str(stat_info.st_uid)
    elif format_str == "gid":
        return str(stat_info.st_gid)
    else:
        return str(stat_info)


def samefile(path1: str, path2: str) -> bool:
    """Check if two paths refer to the same file."""
    return Path(path1).samefile(Path(path2))


def with_name(path_str: str, name: str) -> str:
    """Replace filename in path."""
    return str(Path(path_str).with_name(name))


def with_suffix(path_str: str, suffix: str) -> str:
    """Replace file extension in path."""
    return str(Path(path_str).with_suffix(suffix))


def relative_to(path_str: str, base: str) -> str:
    """Get relative path from base."""
    return str(Path(path_str).relative_to(Path(base)))


def home() -> str:
    """Get home directory."""
    return str(Path.home())


def cwd() -> str:
    """Get current working directory."""
    return str(Path.cwd())





def chmod(path_str: str, mode: int) -> None:
    """Change file permissions."""
    Path(path_str).chmod(mode)


def chown(path_str: str, owner: str) -> None:
    """Change file owner."""
    import pwd
    import os
    uid = pwd.getpwnam(owner).pw_uid
    os.chown(path_str, uid, -1)




def expanduser(path_str: str) -> str:
    """Expand user home directory."""
    return str(Path(path_str).expanduser())


def expandvars(path_str: str) -> str:
    """Expand environment variables."""
    return os.path.expandvars(path_str)


def normpath(path_str: str) -> str:
    """Normalize path."""
    return os.path.normpath(path_str)


def realpath(path_str: str) -> str:
    """Get real path (resolve symlinks)."""
    return os.path.realpath(path_str)


def abspath(path_str: str) -> str:
    """Get absolute path."""
    return os.path.abspath(path_str)


def commonpath(paths: List[str]) -> str:
    """Get common path prefix."""
    return os.path.commonpath([Path(p) for p in paths])


def commonprefix(paths: List[str]) -> str:
    """Get common path prefix (string)."""
    return os.path.commonprefix([str(Path(p)) for p in paths])


def split(path_str: str) -> tuple:
    """Split path into head and tail."""
    head, tail = os.path.split(path_str)
    return head, tail


def splitext(path_str: str) -> tuple:
    """Split path into root and extension."""
    root, ext = os.path.splitext(path_str)
    return root, ext


def basename(path_str: str) -> str:
    """Get basename."""
    return os.path.basename(path_str)


def dirname(path_str: str) -> str:
    """Get dirname."""
    return os.path.dirname(path_str)


def main():
    parser = argparse.ArgumentParser(
        description="Path CLI - A command-line wrapper for pathlib.Path",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  path absolute /path/to/file
  path exists /path/to/file && echo "File exists"
  path mkdir /path/to/dir --parents
  path glob "*.py" /path/to/dir
  path join /path /to /file
  path copy src dst --overwrite
  path stat /path/to/file --format size
        """
    )
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Absolute path command
    abs_parser = subparsers.add_parser('absolute', help='Get absolute path')
    abs_parser.add_argument('path', help='Path to resolve')
    
    # Relative path command
    rel_parser = subparsers.add_parser('relative', help='Get relative path')
    rel_parser.add_argument('path', help='Path to make relative')
    rel_parser.add_argument('--base', help='Base directory for relative path')
    
    # Exists command
    exists_parser = subparsers.add_parser('exists', help='Check if path exists')
    exists_parser.add_argument('path', help='Path to check')
    
    # File type commands
    is_file_parser = subparsers.add_parser('isfile', help='Check if path is a file')
    is_file_parser.add_argument('path', help='Path to check')
    
    is_dir_parser = subparsers.add_parser('isdir', help='Check if path is a directory')
    is_dir_parser.add_argument('path', help='Path to check')
    
    is_symlink_parser = subparsers.add_parser('issymlink', help='Check if path is a symlink')
    is_symlink_parser.add_argument('path', help='Path to check')
    
    # Path component commands
    parent_parser = subparsers.add_parser('parent', help='Get parent directory')
    parent_parser.add_argument('path', help='Path to get parent of')
    
    name_parser = subparsers.add_parser('name', help='Get filename')
    name_parser.add_argument('path', help='Path to get name of')
    
    stem_parser = subparsers.add_parser('stem', help='Get filename without extension')
    stem_parser.add_argument('path', help='Path to get stem of')
    
    suffix_parser = subparsers.add_parser('suffix', help='Get file extension')
    suffix_parser.add_argument('path', help='Path to get suffix of')
    
    suffixes_parser = subparsers.add_parser('suffixes', help='Get all file extensions')
    suffixes_parser.add_argument('path', help='Path to get suffixes of')
    
    parts_parser = subparsers.add_parser('parts', help='Get path parts')
    parts_parser.add_argument('path', help='Path to get parts of')
    
    # Join command
    join_parser = subparsers.add_parser('join', help='Join paths')
    join_parser.add_argument('paths', nargs='+', help='Paths to join')
    
    # Glob commands
    glob_parser = subparsers.add_parser('glob', help='Glob pattern matching')
    glob_parser.add_argument('pattern', help='Glob pattern')
    glob_parser.add_argument('--path', default='.', help='Base path for glob')
    
    rglob_parser = subparsers.add_parser('rglob', help='Recursive glob pattern matching')
    rglob_parser.add_argument('pattern', help='Glob pattern')
    rglob_parser.add_argument('--path', default='.', help='Base path for glob')
    
    # Directory operations
    mkdir_parser = subparsers.add_parser('mkdir', help='Create directory')
    mkdir_parser.add_argument('path', help='Directory to create')
    mkdir_parser.add_argument('--parents', action='store_true', help='Create parent directories')
    mkdir_parser.add_argument('--exist-ok', action='store_true', help='Don\'t error if directory exists')
    
    # File operations
    touch_parser = subparsers.add_parser('touch', help='Create file (touch)')
    touch_parser.add_argument('path', help='File to create')
    touch_parser.add_argument('--exist-ok', action='store_true', help='Don\'t error if file exists')
    
    # Remove operations
    unlink_parser = subparsers.add_parser('unlink', help='Remove file or symlink')
    unlink_parser.add_argument('path', help='File to remove')
    unlink_parser.add_argument('--missing-ok', action='store_true', help='Don\'t error if file doesn\'t exist')
    
    rmdir_parser = subparsers.add_parser('rmdir', help='Remove empty directory')
    rmdir_parser.add_argument('path', help='Directory to remove')
    
    rmtree_parser = subparsers.add_parser('rmtree', help='Remove directory tree')
    rmtree_parser.add_argument('path', help='Directory tree to remove')
    
    # Copy and move operations
    copy_parser = subparsers.add_parser('copy', help='Copy file or directory')
    copy_parser.add_argument('src', help='Source path')
    copy_parser.add_argument('dst', help='Destination path')
    copy_parser.add_argument('--overwrite', action='store_true', help='Overwrite existing files')
    
    move_parser = subparsers.add_parser('move', help='Move file or directory')
    move_parser.add_argument('src', help='Source path')
    move_parser.add_argument('dst', help='Destination path')
    move_parser.add_argument('--overwrite', action='store_true', help='Overwrite existing files')
    
    # Symlink operations
    symlink_parser = subparsers.add_parser('symlink', help='Create symlink')
    symlink_parser.add_argument('src', help='Source path')
    symlink_parser.add_argument('dst', help='Destination path')
    symlink_parser.add_argument('--target-is-directory', action='store_true', help='Target is a directory')
    
    readlink_parser = subparsers.add_parser('readlink', help='Read symlink target')
    readlink_parser.add_argument('path', help='Symlink to read')
    
    # Stat command
    stat_parser = subparsers.add_parser('stat', help='Get file stats')
    stat_parser.add_argument('path', help='Path to get stats for')
    stat_parser.add_argument('--format', choices=['size', 'mtime', 'ctime', 'atime', 'mode', 'uid', 'gid'], 
                           default='size', help='Stat field to return')
    
    # Samefile command
    samefile_parser = subparsers.add_parser('samefile', help='Check if two paths refer to the same file')
    samefile_parser.add_argument('path1', help='First path to compare')
    samefile_parser.add_argument('path2', help='Second path to compare')
    
    # Path manipulation commands
    with_name_parser = subparsers.add_parser('with-name', help='Replace filename in path')
    with_name_parser.add_argument('path', help='Original path')
    with_name_parser.add_argument('name', help='New filename')
    
    with_suffix_parser = subparsers.add_parser('with-suffix', help='Replace file extension in path')
    with_suffix_parser.add_argument('path', help='Original path')
    with_suffix_parser.add_argument('suffix', help='New extension')
    
    relative_to_parser = subparsers.add_parser('relative-to', help='Get relative path from base')
    relative_to_parser.add_argument('base', help='Base path')
    relative_to_parser.add_argument('path', help='Path to make relative')
    
    home_parser = subparsers.add_parser('home', help='Get home directory')
    
    cwd_parser = subparsers.add_parser('cwd', help='Get current working directory')
    
    # Permission operations
    chmod_parser = subparsers.add_parser('chmod', help='Change file permissions')
    chmod_parser.add_argument('path', help='Path to change permissions for')
    chmod_parser.add_argument('mode', type=int, help='Permission mode (octal)')
    
    chown_parser = subparsers.add_parser('chown', help='Change file owner')
    chown_parser.add_argument('path', help='Path to change owner for')
    chown_parser.add_argument('owner', help='New owner')    

    
    # Path expansion commands
    expanduser_parser = subparsers.add_parser('expanduser', help='Expand user home directory')
    expanduser_parser.add_argument('path', help='Path to expand')
    
    expandvars_parser = subparsers.add_parser('expandvars', help='Expand environment variables')
    expandvars_parser.add_argument('path', help='Path to expand')
    
    # Path normalization commands
    normpath_parser = subparsers.add_parser('normpath', help='Normalize path')
    normpath_parser.add_argument('path', help='Path to normalize')
    
    realpath_parser = subparsers.add_parser('realpath', help='Get real path (resolve symlinks)')
    realpath_parser.add_argument('path', help='Path to resolve')
    
    abspath_parser = subparsers.add_parser('abspath', help='Get absolute path')
    abspath_parser.add_argument('path', help='Path to make absolute')
    
    # Common path commands
    commonpath_parser = subparsers.add_parser('commonpath', help='Get common path prefix')
    commonpath_parser.add_argument('paths', nargs='+', help='Paths to find common prefix for')
    
    commonprefix_parser = subparsers.add_parser('commonprefix', help='Get common path prefix (string)')
    commonprefix_parser.add_argument('paths', nargs='+', help='Paths to find common prefix for')
    
    # Split commands
    split_parser = subparsers.add_parser('split', help='Split path into head and tail')
    split_parser.add_argument('path', help='Path to split')
    
    splitext_parser = subparsers.add_parser('splitext', help='Split path into root and extension')
    splitext_parser.add_argument('path', help='Path to split')
    
    basename_parser = subparsers.add_parser('basename', help='Get basename')
    basename_parser.add_argument('path', help='Path to get basename of')
    
    dirname_parser = subparsers.add_parser('dirname', help='Get dirname')
    dirname_parser.add_argument('path', help='Path to get dirname of')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        if args.command == 'absolute':
            print(absolute_path(args.path))
        elif args.command == 'relative':
            print(relative_path(args.path, args.base))
        elif args.command == 'exists':
            print(exists(args.path))
        elif args.command == 'isfile':
            print(is_file(args.path))
        elif args.command == 'isdir':
            print(is_dir(args.path))
        elif args.command == 'issymlink':
            print(is_symlink(args.path))
        elif args.command == 'parent':
            print(parent(args.path))
        elif args.command == 'name':
            print(name(args.path))
        elif args.command == 'stem':
            print(stem(args.path))
        elif args.command == 'suffix':
            print(suffix(args.path))
        elif args.command == 'suffixes':
            print(' '.join(suffixes(args.path)))
        elif args.command == 'parts':
            print(' '.join(parts(args.path)))
        elif args.command == 'join':
            print(join(*args.paths))
        elif args.command == 'glob':
            print(' '.join(glob(args.pattern, args.path)))
        elif args.command == 'rglob':
            print(' '.join(rglob(args.pattern, args.path)))
        elif args.command == 'mkdir':
            print(mkdir(args.path, args.parents, args.exist_ok))
        elif args.command == 'touch':
            print(touch(args.path, args.exist_ok))
        elif args.command == 'unlink':
            unlink(args.path, args.missing_ok)
        elif args.command == 'rmdir':
            rmdir(args.path)
        elif args.command == 'rmtree':
            rmtree(args.path)
        elif args.command == 'copy':
            print(copy(args.src, args.dst, args.overwrite))
        elif args.command == 'move':
            print(move(args.src, args.dst, args.overwrite))
        elif args.command == 'symlink':
            print(symlink(args.src, args.dst, args.target_is_directory))
        elif args.command == 'readlink':
            print(readlink(args.path))
        elif args.command == 'stat':
            print(stat(args.path, args.format))
        elif args.command == 'samefile':
            print(samefile(args.path1, args.path2))
        elif args.command == 'with-name':
            print(with_name(args.path, args.name))
        elif args.command == 'with-suffix':
            print(with_suffix(args.path, args.suffix))
        elif args.command == 'relative-to':
            print(relative_to(args.path, args.base))
        elif args.command == 'home':
            print(home())
        elif args.command == 'cwd':
            print(cwd())
        elif args.command == 'chmod':
            chmod(args.path, args.mode)
        elif args.command == 'chown':
            chown(args.path, args.owner)
        elif args.command == 'expanduser':
            print(expanduser(args.path))
        elif args.command == 'expandvars':
            print(expandvars(args.path))
        elif args.command == 'normpath':
            print(normpath(args.path))
        elif args.command == 'realpath':
            print(realpath(args.path))
        elif args.command == 'abspath':
            print(abspath(args.path))
        elif args.command == 'commonpath':
            print(commonpath(args.paths))
        elif args.command == 'commonprefix':
            print(commonprefix(args.paths))
        elif args.command == 'split':
            head, tail = split(args.path)
            print(f"{head}\t{tail}")
        elif args.command == 'splitext':
            root, ext = splitext(args.path)
            print(f"{root}\t{ext}")
        elif args.command == 'basename':
            print(basename(args.path))
        elif args.command == 'dirname':
            print(dirname(args.path))
        else:
            parser.print_help()
            sys.exit(1)
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main() 