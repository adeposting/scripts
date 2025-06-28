#!/usr/bin/env python3
"""
Hashlib CLI - A command-line wrapper for hashlib module

This script provides CLI-friendly functions that wrap hashlib module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import hashlib
import json
import sys
from typing import Any, Dict, List, Optional

# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def md5(data: str, encoding: str = 'utf-8') -> str:
    """Calculate MD5 hash of data."""
    return hashlib.md5(data.encode(encoding)).hexdigest()


def sha1(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA1 hash of data."""
    return hashlib.sha1(data.encode(encoding)).hexdigest()


def sha224(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA224 hash of data."""
    return hashlib.sha224(data.encode(encoding)).hexdigest()


def sha256(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA256 hash of data."""
    return hashlib.sha256(data.encode(encoding)).hexdigest()


def sha384(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA384 hash of data."""
    return hashlib.sha384(data.encode(encoding)).hexdigest()


def sha512(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA512 hash of data."""
    return hashlib.sha512(data.encode(encoding)).hexdigest()


def sha3_224(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA3-224 hash of data."""
    return hashlib.sha3_224(data.encode(encoding)).hexdigest()


def sha3_256(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA3-256 hash of data."""
    return hashlib.sha3_256(data.encode(encoding)).hexdigest()


def sha3_384(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA3-384 hash of data."""
    return hashlib.sha3_384(data.encode(encoding)).hexdigest()


def sha3_512(data: str, encoding: str = 'utf-8') -> str:
    """Calculate SHA3-512 hash of data."""
    return hashlib.sha3_512(data.encode(encoding)).hexdigest()


def blake2b(data: str, digest_size: int = 64, encoding: str = 'utf-8') -> str:
    """Calculate BLAKE2b hash of data."""
    return hashlib.blake2b(data.encode(encoding), digest_size=digest_size).hexdigest()


def blake2s(data: str, digest_size: int = 32, encoding: str = 'utf-8') -> str:
    """Calculate BLAKE2s hash of data."""
    return hashlib.blake2s(data.encode(encoding), digest_size=digest_size).hexdigest()


def shake_128(data: str, length: int = 16, encoding: str = 'utf-8') -> str:
    """Calculate SHAKE128 hash of data."""
    return hashlib.shake_128(data.encode(encoding)).hexdigest(length)


def shake_256(data: str, length: int = 32, encoding: str = 'utf-8') -> str:
    """Calculate SHAKE256 hash of data."""
    return hashlib.shake_256(data.encode(encoding)).hexdigest(length)


def file_hash(filename: str, algorithm: str = 'sha256') -> Dict[str, Any]:
    """Calculate hash of a file."""
    hash_func = getattr(hashlib, algorithm)
    hash_obj = hash_func()
    
    with open(filename, 'rb') as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_obj.update(chunk)
    
    return {
        'filename': filename,
        'algorithm': algorithm,
        'hash': hash_obj.hexdigest(),
        'size': hash_obj.digest_size
    }


def hash_file_md5(filename: str) -> str:
    """Calculate MD5 hash of a file."""
    return file_hash(filename, 'md5')['hash']


def hash_file_sha1(filename: str) -> str:
    """Calculate SHA1 hash of a file."""
    return file_hash(filename, 'sha1')['hash']


def hash_file_sha256(filename: str) -> str:
    """Calculate SHA256 hash of a file."""
    return file_hash(filename, 'sha256')['hash']


def hash_file_sha512(filename: str) -> str:
    """Calculate SHA512 hash of a file."""
    return file_hash(filename, 'sha512')['hash']


def hash_all_algorithms(data: str, encoding: str = 'utf-8') -> Dict[str, str]:
    """Calculate hash using all available algorithms."""
    algorithms = [
        'md5', 'sha1', 'sha224', 'sha256', 'sha384', 'sha512',
        'sha3_224', 'sha3_256', 'sha3_384', 'sha3_512'
    ]
    
    results = {}
    for algo in algorithms:
        try:
            hash_func = getattr(hashlib, algo)
            results[algo] = hash_func(data.encode(encoding)).hexdigest()
        except (AttributeError, TypeError):
            continue
    
    return results


def get_available_algorithms() -> List[str]:
    """Get list of available hash algorithms."""
    algorithms = []
    for attr_name in dir(hashlib):
        if not attr_name.startswith('_') and callable(getattr(hashlib, attr_name)):
            try:
                # Test if it's a hash algorithm
                hash_func = getattr(hashlib, attr_name)
                if hasattr(hash_func, 'hexdigest'):
                    algorithms.append(attr_name)
            except (AttributeError, TypeError):
                continue
    return sorted(algorithms)


def pbkdf2_hmac(password: str, salt: str, iterations: int = 100000, 
                algorithm: str = 'sha256', dklen: Optional[int] = None) -> str:
    """Generate PBKDF2 hash."""
    if dklen is None:
        dklen = getattr(hashlib, algorithm)().digest_size
    
    return hashlib.pbkdf2_hmac(
        algorithm, 
        password.encode('utf-8'), 
        salt.encode('utf-8'), 
        iterations, 
        dklen
    ).hex()


def scrypt(password: str, salt: str, n: int = 16384, r: int = 8, p: int = 1) -> str:
    """Generate scrypt hash."""
    return hashlib.scrypt(
        password.encode('utf-8'),
        salt=salt.encode('utf-8'),
        n=n, r=r, p=p
    ).hex()


def main():
    parser = argparse.ArgumentParser(
        description="Hashlib CLI - A command-line wrapper for hashlib module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-hashlib md5 "hello world"
  py-hashlib sha256 "hello world"
  py-hashlib file-hash test.txt --algorithm sha256
  py-hashlib pbkdf2-hmac "password" "salt" --iterations 100000 --key-length 32
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    parser.add_argument('--encoding', default='utf-8', help='String encoding')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Basic hash functions
    md5_parser = subparsers.add_parser('md5', help='Calculate MD5 hash')
    md5_parser.add_argument('data', help='Data to hash')
    
    sha1_parser = subparsers.add_parser('sha1', help='Calculate SHA1 hash')
    sha1_parser.add_argument('data', help='Data to hash')
    
    sha224_parser = subparsers.add_parser('sha224', help='Calculate SHA224 hash')
    sha224_parser.add_argument('data', help='Data to hash')
    
    sha256_parser = subparsers.add_parser('sha256', help='Calculate SHA256 hash')
    sha256_parser.add_argument('data', help='Data to hash')
    
    sha384_parser = subparsers.add_parser('sha384', help='Calculate SHA384 hash')
    sha384_parser.add_argument('data', help='Data to hash')
    
    sha512_parser = subparsers.add_parser('sha512', help='Calculate SHA512 hash')
    sha512_parser.add_argument('data', help='Data to hash')
    
    sha3_224_parser = subparsers.add_parser('sha3-224', help='Calculate SHA3-224 hash')
    sha3_224_parser.add_argument('data', help='Data to hash')
    
    sha3_256_parser = subparsers.add_parser('sha3-256', help='Calculate SHA3-256 hash')
    sha3_256_parser.add_argument('data', help='Data to hash')
    
    sha3_384_parser = subparsers.add_parser('sha3-384', help='Calculate SHA3-384 hash')
    sha3_384_parser.add_argument('data', help='Data to hash')
    
    sha3_512_parser = subparsers.add_parser('sha3-512', help='Calculate SHA3-512 hash')
    sha3_512_parser.add_argument('data', help='Data to hash')
    
    blake2b_parser = subparsers.add_parser('blake2b', help='Calculate BLAKE2b hash')
    blake2b_parser.add_argument('data', help='Data to hash')
    blake2b_parser.add_argument('--digest-size', type=int, default=64, help='Digest size')
    
    blake2s_parser = subparsers.add_parser('blake2s', help='Calculate BLAKE2s hash')
    blake2s_parser.add_argument('data', help='Data to hash')
    blake2s_parser.add_argument('--digest-size', type=int, default=32, help='Digest size')
    
    shake_128_parser = subparsers.add_parser('shake-128', help='Calculate SHAKE128 hash')
    shake_128_parser.add_argument('data', help='Data to hash')
    shake_128_parser.add_argument('--length', type=int, default=16, help='Output length')
    
    shake_256_parser = subparsers.add_parser('shake-256', help='Calculate SHAKE256 hash')
    shake_256_parser.add_argument('data', help='Data to hash')
    shake_256_parser.add_argument('--length', type=int, default=32, help='Output length')
    
    # File hash functions
    file_hash_parser = subparsers.add_parser('file-hash', help='Calculate hash of file')
    file_hash_parser.add_argument('filename', help='File to hash')
    file_hash_parser.add_argument('--algorithm', default='sha256', help='Hash algorithm')
    
    hash_file_md5_parser = subparsers.add_parser('hash-file-md5', help='Calculate MD5 hash of file')
    hash_file_md5_parser.add_argument('filename', help='File to hash')
    
    hash_file_sha1_parser = subparsers.add_parser('hash-file-sha1', help='Calculate SHA1 hash of file')
    hash_file_sha1_parser.add_argument('filename', help='File to hash')
    
    hash_file_sha256_parser = subparsers.add_parser('hash-file-sha256', help='Calculate SHA256 hash of file')
    hash_file_sha256_parser.add_argument('filename', help='File to hash')
    
    hash_file_sha512_parser = subparsers.add_parser('hash-file-sha512', help='Calculate SHA512 hash of file')
    hash_file_sha512_parser.add_argument('filename', help='File to hash')
    
    # Advanced functions
    hash_all_parser = subparsers.add_parser('hash-all', help='Calculate hash with all algorithms')
    hash_all_parser.add_argument('data', help='Data to hash')
    
    get_available_algorithms_parser = subparsers.add_parser('get-available-algorithms', help='List available algorithms')
    
    pbkdf2_hmac_parser = subparsers.add_parser('pbkdf2-hmac', help='Generate PBKDF2 hash')
    pbkdf2_hmac_parser.add_argument('password', help='Password')
    pbkdf2_hmac_parser.add_argument('salt', help='Salt')
    pbkdf2_hmac_parser.add_argument('--iterations', type=int, default=100000, help='Number of iterations')
    pbkdf2_hmac_parser.add_argument('--algorithm', default='sha256', help='Hash algorithm')
    pbkdf2_hmac_parser.add_argument('--dklen', type=int, help='Derived key length')
    
    scrypt_parser = subparsers.add_parser('scrypt', help='Generate scrypt hash')
    scrypt_parser.add_argument('password', help='Password')
    scrypt_parser.add_argument('salt', help='Salt')
    scrypt_parser.add_argument('--n', type=int, default=16384, help='CPU/memory cost')
    scrypt_parser.add_argument('--r', type=int, default=8, help='Block size')
    scrypt_parser.add_argument('--p', type=int, default=1, help='Parallelization')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'md5':
            if args.dry_run:
                print(f"Would calculate MD5 hash of: {args.data}")
                return
            result = md5(args.data, args.encoding)
        elif args.command == 'sha1':
            if args.dry_run:
                print(f"Would calculate SHA1 hash of: {args.data}")
                return
            result = sha1(args.data, args.encoding)
        elif args.command == 'sha224':
            if args.dry_run:
                print(f"Would calculate SHA224 hash of: {args.data}")
                return
            result = sha224(args.data, args.encoding)
        elif args.command == 'sha256':
            if args.dry_run:
                print(f"Would calculate SHA256 hash of: {args.data}")
                return
            result = sha256(args.data, args.encoding)
        elif args.command == 'sha384':
            if args.dry_run:
                print(f"Would calculate SHA384 hash of: {args.data}")
                return
            result = sha384(args.data, args.encoding)
        elif args.command == 'sha512':
            if args.dry_run:
                print(f"Would calculate SHA512 hash of: {args.data}")
                return
            result = sha512(args.data, args.encoding)
        elif args.command == 'sha3-224':
            if args.dry_run:
                print(f"Would calculate SHA3-224 hash of: {args.data}")
                return
            result = sha3_224(args.data, args.encoding)
        elif args.command == 'sha3-256':
            if args.dry_run:
                print(f"Would calculate SHA3-256 hash of: {args.data}")
                return
            result = sha3_256(args.data, args.encoding)
        elif args.command == 'sha3-384':
            if args.dry_run:
                print(f"Would calculate SHA3-384 hash of: {args.data}")
                return
            result = sha3_384(args.data, args.encoding)
        elif args.command == 'sha3-512':
            if args.dry_run:
                print(f"Would calculate SHA3-512 hash of: {args.data}")
                return
            result = sha3_512(args.data, args.encoding)
        elif args.command == 'blake2b':
            if args.dry_run:
                print(f"Would calculate BLAKE2b hash of: {args.data}")
                return
            result = blake2b(args.data, args.digest_size, args.encoding)
        elif args.command == 'blake2s':
            if args.dry_run:
                print(f"Would calculate BLAKE2s hash of: {args.data}")
                return
            result = blake2s(args.data, args.digest_size, args.encoding)
        elif args.command == 'shake-128':
            if args.dry_run:
                print(f"Would calculate SHAKE128 hash of: {args.data}")
                return
            result = shake_128(args.data, args.length, args.encoding)
        elif args.command == 'shake-256':
            if args.dry_run:
                print(f"Would calculate SHAKE256 hash of: {args.data}")
                return
            result = shake_256(args.data, args.length, args.encoding)
        elif args.command == 'file-hash':
            if args.dry_run:
                print(f"Would calculate {args.algorithm} hash of file: {args.filename}")
                return
            result = file_hash(args.filename, args.algorithm)
        elif args.command == 'hash-file-md5':
            if args.dry_run:
                print(f"Would calculate MD5 hash of file: {args.filename}")
                return
            result = hash_file_md5(args.filename)
        elif args.command == 'hash-file-sha1':
            if args.dry_run:
                print(f"Would calculate SHA1 hash of file: {args.filename}")
                return
            result = hash_file_sha1(args.filename)
        elif args.command == 'hash-file-sha256':
            if args.dry_run:
                print(f"Would calculate SHA256 hash of file: {args.filename}")
                return
            result = hash_file_sha256(args.filename)
        elif args.command == 'hash-file-sha512':
            if args.dry_run:
                print(f"Would calculate SHA512 hash of file: {args.filename}")
                return
            result = hash_file_sha512(args.filename)
        elif args.command == 'hash-all':
            if args.dry_run:
                print(f"Would calculate all hashes of: {args.data}")
                return
            result = hash_all_algorithms(args.data, args.encoding)
        elif args.command == 'get-available-algorithms':
            result = get_available_algorithms()
        elif args.command == 'pbkdf2-hmac':
            if args.dry_run:
                print(f"Would generate PBKDF2 hash for password with salt: {args.salt}")
                return
            result = pbkdf2_hmac(args.password, args.salt, args.iterations, args.algorithm, args.dklen)
        elif args.command == 'scrypt':
            if args.dry_run:
                print(f"Would generate scrypt hash for password with salt: {args.salt}")
                return
            result = scrypt(args.password, args.salt, args.n, args.r, args.p)
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