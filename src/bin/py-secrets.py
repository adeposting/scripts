#!/usr/bin/env python3
"""
Secrets CLI - A command-line wrapper for secrets module

This script provides CLI-friendly functions that wrap secrets module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import secrets
import string
import sys
from typing import Any, Dict, List, Optional


def token_bytes(nbytes: int = 32) -> str:
    """Generate a random byte string."""
    return secrets.token_bytes(nbytes).hex()


def token_hex(nbytes: int = 32) -> str:
    """Generate a random hex string."""
    return secrets.token_hex(nbytes)


def token_urlsafe(nbytes: int = 32) -> str:
    """Generate a random URL-safe text string."""
    return secrets.token_urlsafe(nbytes)


def choice(sequence: List[str]) -> str:
    """Choose a random element from a sequence."""
    return secrets.choice(sequence)


def randbelow(n: int) -> int:
    """Return a random int in the range [0, n)."""
    return secrets.randbelow(n)


def randbits(k: int) -> int:
    """Generate an int with k random bits."""
    return secrets.randbits(k)


def generate_password(length: int = 16, 
                     use_letters: bool = True,
                     use_digits: bool = True,
                     use_symbols: bool = True,
                     use_uppercase: bool = True,
                     use_lowercase: bool = True) -> str:
    """Generate a secure random password."""
    chars = ""
    
    if use_letters:
        if use_uppercase:
            chars += string.ascii_uppercase
        if use_lowercase:
            chars += string.ascii_lowercase
    if use_digits:
        chars += string.digits
    if use_symbols:
        chars += string.punctuation
    
    if not chars:
        chars = string.ascii_letters + string.digits
    
    return ''.join(secrets.choice(chars) for _ in range(length))


def generate_hex_password(length: int = 16) -> str:
    """Generate a hex password."""
    return secrets.token_hex(length // 2 + length % 2)[:length]


def generate_urlsafe_password(length: int = 16) -> str:
    """Generate a URL-safe password."""
    return secrets.token_urlsafe(length)


def generate_pin(length: int = 6) -> str:
    """Generate a numeric PIN."""
    return ''.join(secrets.choice(string.digits) for _ in range(length))


def compare_digest(a: str, b: str) -> bool:
    """Compare two strings in constant time."""
    return secrets.compare_digest(a, b)


def generate_secure_token(token_type: str = 'hex', length: int = 32) -> Dict[str, Any]:
    """Generate a secure token with metadata."""
    if token_type == 'bytes':
        token = secrets.token_bytes(length).hex()
    elif token_type == 'hex':
        token = secrets.token_hex(length)
    elif token_type == 'urlsafe':
        token = secrets.token_urlsafe(length)
    else:
        raise ValueError(f"Unknown token type: {token_type}")
    
    return {
        'token': token,
        'type': token_type,
        'length': len(token),
        'entropy_bits': length * 8 if token_type == 'bytes' else length * 4
    }


def generate_multiple_tokens(count: int = 5, token_type: str = 'hex', length: int = 32) -> List[str]:
    """Generate multiple secure tokens."""
    tokens = []
    for _ in range(count):
        if token_type == 'bytes':
            tokens.append(secrets.token_bytes(length).hex())
        elif token_type == 'hex':
            tokens.append(secrets.token_hex(length))
        elif token_type == 'urlsafe':
            tokens.append(secrets.token_urlsafe(length))
        else:
            raise ValueError(f"Unknown token type: {token_type}")
    return tokens


def generate_crypto_key(length: int = 32) -> str:
    """Generate a cryptographic key."""
    return secrets.token_bytes(length).hex()


def generate_salt(length: int = 16) -> str:
    """Generate a random salt for password hashing."""
    return secrets.token_hex(length)


def generate_uuid() -> str:
    """Generate a random UUID."""
    import uuid
    return str(uuid.uuid4())


def generate_api_key(prefix: str = 'sk', length: int = 32) -> str:
    """Generate an API key with optional prefix."""
    suffix = secrets.token_urlsafe(length)
    return f"{prefix}_{suffix}"


def main():
    parser = argparse.ArgumentParser(
        description="Secrets CLI - A command-line wrapper for secrets module",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  py-secrets token-bytes 32
  py-secrets token-hex 16
  py-secrets generate-password --length 20
  py-secrets generate-api-key --prefix api
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--dry-run', action='store_true', help='Show what would be done without doing it')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Basic token functions
    token_bytes_parser = subparsers.add_parser('token-bytes', help='Generate random byte string')
    token_bytes_parser.add_argument('nbytes', type=int, default=32, nargs='?', help='Number of bytes')
    
    token_hex_parser = subparsers.add_parser('token-hex', help='Generate random hex string')
    token_hex_parser.add_argument('nbytes', type=int, default=32, nargs='?', help='Number of bytes')
    
    token_urlsafe_parser = subparsers.add_parser('token-urlsafe', help='Generate URL-safe random string')
    token_urlsafe_parser.add_argument('nbytes', type=int, default=32, nargs='?', help='Number of bytes')
    
    choice_parser = subparsers.add_parser('choice', help='Choose random element from sequence')
    choice_parser.add_argument('sequence', nargs='+', help='Sequence of items')
    
    randbelow_parser = subparsers.add_parser('randbelow', help='Generate random int below n')
    randbelow_parser.add_argument('n', type=int, help='Upper bound (exclusive)')
    
    randbits_parser = subparsers.add_parser('randbits', help='Generate int with k random bits')
    randbits_parser.add_argument('k', type=int, help='Number of bits')
    
    # Password generation
    generate_password_parser = subparsers.add_parser('generate-password', help='Generate secure password')
    generate_password_parser.add_argument('--length', type=int, default=16, help='Password length')
    generate_password_parser.add_argument('--no-letters', action='store_true', help='Exclude letters')
    generate_password_parser.add_argument('--no-digits', action='store_true', help='Exclude digits')
    generate_password_parser.add_argument('--no-symbols', action='store_true', help='Exclude symbols')
    generate_password_parser.add_argument('--no-uppercase', action='store_true', help='Exclude uppercase')
    generate_password_parser.add_argument('--no-lowercase', action='store_true', help='Exclude lowercase')
    
    generate_hex_password_parser = subparsers.add_parser('generate-hex-password', help='Generate hex password')
    generate_hex_password_parser.add_argument('--length', type=int, default=16, help='Password length')
    
    generate_urlsafe_password_parser = subparsers.add_parser('generate-urlsafe-password', help='Generate URL-safe password')
    generate_urlsafe_password_parser.add_argument('--length', type=int, default=16, help='Password length')
    
    generate_pin_parser = subparsers.add_parser('generate-pin', help='Generate numeric PIN')
    generate_pin_parser.add_argument('--length', type=int, default=6, help='PIN length')
    
    # Advanced functions
    compare_digest_parser = subparsers.add_parser('compare-digest', help='Compare strings in constant time')
    compare_digest_parser.add_argument('a', help='First string')
    compare_digest_parser.add_argument('b', help='Second string')
    
    generate_secure_token_parser = subparsers.add_parser('generate-secure-token', help='Generate secure token with metadata')
    generate_secure_token_parser.add_argument('--type', default='hex', choices=['bytes', 'hex', 'urlsafe'], help='Token type')
    generate_secure_token_parser.add_argument('--length', type=int, default=32, help='Token length')
    
    generate_multiple_tokens_parser = subparsers.add_parser('generate-multiple-tokens', help='Generate multiple tokens')
    generate_multiple_tokens_parser.add_argument('--count', type=int, default=5, help='Number of tokens')
    generate_multiple_tokens_parser.add_argument('--type', default='hex', choices=['bytes', 'hex', 'urlsafe'], help='Token type')
    generate_multiple_tokens_parser.add_argument('--length', type=int, default=32, help='Token length')
    
    generate_crypto_key_parser = subparsers.add_parser('generate-crypto-key', help='Generate cryptographic key')
    generate_crypto_key_parser.add_argument('--length', type=int, default=32, help='Key length')
    
    generate_salt_parser = subparsers.add_parser('generate-salt', help='Generate random salt')
    generate_salt_parser.add_argument('--length', type=int, default=16, help='Salt length')
    
    subparsers.add_parser('generate-uuid', help='Generate random UUID')
    
    generate_api_key_parser = subparsers.add_parser('generate-api-key', help='Generate API key')
    generate_api_key_parser.add_argument('--prefix', default='sk', help='Key prefix')
    generate_api_key_parser.add_argument('--length', type=int, default=32, help='Key length')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'token-bytes':
            if args.dry_run:
                print(f"Would generate {args.nbytes} random bytes")
                return
            result = token_bytes(args.nbytes)
        elif args.command == 'token-hex':
            if args.dry_run:
                print(f"Would generate {args.nbytes} random hex bytes")
                return
            result = token_hex(args.nbytes)
        elif args.command == 'token-urlsafe':
            if args.dry_run:
                print(f"Would generate {args.nbytes} random URL-safe bytes")
                return
            result = token_urlsafe(args.nbytes)
        elif args.command == 'choice':
            if args.dry_run:
                print(f"Would choose from: {args.sequence}")
                return
            result = choice(args.sequence)
        elif args.command == 'randbelow':
            if args.dry_run:
                print(f"Would generate random int below {args.n}")
                return
            result = randbelow(args.n)
        elif args.command == 'randbits':
            if args.dry_run:
                print(f"Would generate int with {args.k} random bits")
                return
            result = randbits(args.k)
        elif args.command == 'generate-password':
            if args.dry_run:
                print(f"Would generate password of length {args.length}")
                return
            result = generate_password(
                args.length,
                not args.no_letters,
                not args.no_digits,
                not args.no_symbols,
                not args.no_uppercase,
                not args.no_lowercase
            )
        elif args.command == 'generate-hex-password':
            if args.dry_run:
                print(f"Would generate hex password of length {args.length}")
                return
            result = generate_hex_password(args.length)
        elif args.command == 'generate-urlsafe-password':
            if args.dry_run:
                print(f"Would generate URL-safe password of length {args.length}")
                return
            result = generate_urlsafe_password(args.length)
        elif args.command == 'generate-pin':
            if args.dry_run:
                print(f"Would generate PIN of length {args.length}")
                return
            result = generate_pin(args.length)
        elif args.command == 'compare-digest':
            if args.dry_run:
                print(f"Would compare strings: {args.a} and {args.b}")
                return
            result = compare_digest(args.a, args.b)
        elif args.command == 'generate-secure-token':
            if args.dry_run:
                print(f"Would generate {args.type} token of length {args.length}")
                return
            result = generate_secure_token(args.type, args.length)
        elif args.command == 'generate-multiple-tokens':
            if args.dry_run:
                print(f"Would generate {args.count} {args.type} tokens of length {args.length}")
                return
            result = generate_multiple_tokens(args.count, args.type, args.length)
        elif args.command == 'generate-crypto-key':
            if args.dry_run:
                print(f"Would generate crypto key of length {args.length}")
                return
            result = generate_crypto_key(args.length)
        elif args.command == 'generate-salt':
            if args.dry_run:
                print(f"Would generate salt of length {args.length}")
                return
            result = generate_salt(args.length)
        elif args.command == 'generate-uuid':
            if args.dry_run:
                print("Would generate UUID")
                return
            result = generate_uuid()
        elif args.command == 'generate-api-key':
            if args.dry_run:
                print(f"Would generate API key with prefix {args.prefix}")
                return
            result = generate_api_key(args.prefix, args.length)
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