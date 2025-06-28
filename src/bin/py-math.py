#!/usr/bin/env python3
"""
Math CLI - A command-line wrapper for math module

This script provides CLI-friendly functions that wrap math module functionality
for use in shell scripts and Makefiles.
"""

import argparse
import json
import math
import sys
from typing import List, Union


def sqrt(x: float) -> float:
    """Square root."""
    return math.sqrt(x)


def ceil(x: float) -> int:
    """Ceiling function."""
    return math.ceil(x)


def floor(x: float) -> int:
    """Floor function."""
    return math.floor(x)


def log(x: float, base: float = math.e) -> float:
    """Natural logarithm."""
    return math.log(x, base)


def exp(x: float) -> float:
    """Exponential function."""
    return math.exp(x)


def factorial(n: int) -> int:
    """Factorial."""
    return math.factorial(n)


def gcd(*numbers: int) -> int:
    """Greatest common divisor."""
    return math.gcd(*numbers)


def sin(x: float) -> float:
    """Sine function."""
    return math.sin(x)


def cos(x: float) -> float:
    """Cosine function."""
    return math.cos(x)


def tan(x: float) -> float:
    """Tangent function."""
    return math.tan(x)


def asin(x: float) -> float:
    """Arcsine function."""
    return math.asin(x)


def acos(x: float) -> float:
    """Arccosine function."""
    return math.acos(x)


def atan(x: float) -> float:
    """Arctangent function."""
    return math.atan(x)


def atan2(y: float, x: float) -> float:
    """Arctangent of y/x."""
    return math.atan2(y, x)


def sinh(x: float) -> float:
    """Hyperbolic sine."""
    return math.sinh(x)


def cosh(x: float) -> float:
    """Hyperbolic cosine."""
    return math.cosh(x)


def tanh(x: float) -> float:
    """Hyperbolic tangent."""
    return math.tanh(x)


def pow(x: float, y: float) -> float:
    """Power function."""
    return math.pow(x, y)


def fabs(x: float) -> float:
    """Absolute value."""
    return math.fabs(x)


def fmod(x: float, y: float) -> float:
    """Floating point remainder."""
    return math.fmod(x, y)


def trunc(x: float) -> int:
    """Truncate to integer."""
    return math.trunc(x)


def isfinite(x: float) -> bool:
    """Check if finite."""
    return math.isfinite(x)


def isinf(x: float) -> bool:
    """Check if infinite."""
    return math.isinf(x)


def isnan(x: float) -> bool:
    """Check if NaN."""
    return math.isnan(x)


def degrees(x: float) -> float:
    """Convert radians to degrees."""
    return math.degrees(x)


def radians(x: float) -> float:
    """Convert degrees to radians."""
    return math.radians(x)


def pi() -> float:
    """Pi constant."""
    return math.pi


def e() -> float:
    """Euler's number."""
    return math.e


def tau() -> float:
    """Tau constant."""
    return math.tau


def inf() -> float:
    """Positive infinity."""
    return math.inf


def nan() -> float:
    """Not a number."""
    return math.nan


def lcm(*numbers: int) -> int:
    """Least common multiple."""
    return math.lcm(*numbers)


def comb(n: int, k: int) -> int:
    """Combination."""
    return math.comb(n, k)


def perm(n: int, k: int) -> int:
    """Permutation."""
    return math.perm(n, k)


def dist(coordinates: List[float]) -> float:
    """Euclidean distance between points."""
    if len(coordinates) % 2 != 0:
        raise ValueError("Number of coordinates must be even")
    mid = len(coordinates) // 2
    p = coordinates[:mid]
    q = coordinates[mid:]
    return math.dist(p, q)


def hypot(*coordinates: float) -> float:
    """Hypotenuse."""
    return math.hypot(*coordinates)


def erf(x: float) -> float:
    """Error function."""
    return math.erf(x)


def erfc(x: float) -> float:
    """Complementary error function."""
    return math.erfc(x)


def gamma(x: float) -> float:
    """Gamma function."""
    return math.gamma(x)


def lgamma(x: float) -> float:
    """Natural logarithm of absolute value of gamma function."""
    return math.lgamma(x)


# Patch: Custom HelpFormatter to use 'Usage:'
class CapitalUHelpFormatter(argparse.RawDescriptionHelpFormatter):
    def _format_usage(self, usage, actions, groups, prefix=None):
        if prefix is None:
            prefix = 'Usage: '
        return super()._format_usage(usage, actions, groups, prefix)


def main():
    parser = argparse.ArgumentParser(
        description="Math CLI - A command-line wrapper for math module",
        formatter_class=CapitalUHelpFormatter,
        epilog="""
Examples:
  py-math sqrt 16
  py-math sin 3.14159
  py-math factorial 5
  py-math gcd 12 18 24
  py-math pow 2 10
  py-math pi
  py-math degrees 3.14159
        """
    )
    
    parser.add_argument('--json', action='store_true', help='Output as JSON')
    parser.add_argument('--verbose', action='store_true', help='Verbose output')
    
    subparsers = parser.add_subparsers(dest='command', help='Available commands')
    
    # Basic math functions
    sqrt_parser = subparsers.add_parser('sqrt', help='Square root')
    sqrt_parser.add_argument('x', type=float, help='Number')
    
    ceil_parser = subparsers.add_parser('ceil', help='Ceiling function')
    ceil_parser.add_argument('x', type=float, help='Number')
    
    floor_parser = subparsers.add_parser('floor', help='Floor function')
    floor_parser.add_argument('x', type=float, help='Number')
    
    log_parser = subparsers.add_parser('log', help='Natural logarithm')
    log_parser.add_argument('x', type=float, help='Number')
    log_parser.add_argument('--base', type=float, default=math.e, help='Base (default: e)')
    
    exp_parser = subparsers.add_parser('exp', help='Exponential function')
    exp_parser.add_argument('x', type=float, help='Number')
    
    factorial_parser = subparsers.add_parser('factorial', help='Factorial')
    factorial_parser.add_argument('n', type=int, help='Number')
    
    gcd_parser = subparsers.add_parser('gcd', help='Greatest common divisor')
    gcd_parser.add_argument('numbers', type=int, nargs='+', help='Numbers')
    
    lcm_parser = subparsers.add_parser('lcm', help='Least common multiple')
    lcm_parser.add_argument('numbers', type=int, nargs='+', help='Numbers')
    
    # Trigonometric functions
    sin_parser = subparsers.add_parser('sin', help='Sine function')
    sin_parser.add_argument('x', type=float, help='Angle in radians')
    
    cos_parser = subparsers.add_parser('cos', help='Cosine function')
    cos_parser.add_argument('x', type=float, help='Angle in radians')
    
    tan_parser = subparsers.add_parser('tan', help='Tangent function')
    tan_parser.add_argument('x', type=float, help='Angle in radians')
    
    asin_parser = subparsers.add_parser('asin', help='Arcsine function')
    asin_parser.add_argument('x', type=float, help='Number')
    
    acos_parser = subparsers.add_parser('acos', help='Arccosine function')
    acos_parser.add_argument('x', type=float, help='Number')
    
    atan_parser = subparsers.add_parser('atan', help='Arctangent function')
    atan_parser.add_argument('x', type=float, help='Number')
    
    atan2_parser = subparsers.add_parser('atan2', help='Arctangent of y/x')
    atan2_parser.add_argument('y', type=float, help='Y coordinate')
    atan2_parser.add_argument('x', type=float, help='X coordinate')
    
    # Hyperbolic functions
    sinh_parser = subparsers.add_parser('sinh', help='Hyperbolic sine')
    sinh_parser.add_argument('x', type=float, help='Number')
    
    cosh_parser = subparsers.add_parser('cosh', help='Hyperbolic cosine')
    cosh_parser.add_argument('x', type=float, help='Number')
    
    tanh_parser = subparsers.add_parser('tanh', help='Hyperbolic tangent')
    tanh_parser.add_argument('x', type=float, help='Number')
    
    # Power and absolute value
    pow_parser = subparsers.add_parser('pow', help='Power function')
    pow_parser.add_argument('x', type=float, help='Base')
    pow_parser.add_argument('y', type=float, help='Exponent')
    
    fabs_parser = subparsers.add_parser('fabs', help='Absolute value')
    fabs_parser.add_argument('x', type=float, help='Number')
    
    fmod_parser = subparsers.add_parser('fmod', help='Floating point remainder')
    fmod_parser.add_argument('x', type=float, help='Dividend')
    fmod_parser.add_argument('y', type=float, help='Divisor')
    
    trunc_parser = subparsers.add_parser('trunc', help='Truncate to integer')
    trunc_parser.add_argument('x', type=float, help='Number')
    
    # Special functions
    erf_parser = subparsers.add_parser('erf', help='Error function')
    erf_parser.add_argument('x', type=float, help='Number')
    
    erfc_parser = subparsers.add_parser('erfc', help='Complementary error function')
    erfc_parser.add_argument('x', type=float, help='Number')
    
    gamma_parser = subparsers.add_parser('gamma', help='Gamma function')
    gamma_parser.add_argument('x', type=float, help='Number')
    
    lgamma_parser = subparsers.add_parser('lgamma', help='Natural logarithm of absolute value of gamma function')
    lgamma_parser.add_argument('x', type=float, help='Number')
    
    # Combinatorics
    comb_parser = subparsers.add_parser('comb', help='Combination')
    comb_parser.add_argument('n', type=int, help='Total items')
    comb_parser.add_argument('k', type=int, help='Selected items')
    
    perm_parser = subparsers.add_parser('perm', help='Permutation')
    perm_parser.add_argument('n', type=int, help='Total items')
    perm_parser.add_argument('k', type=int, help='Selected items')
    
    # Distance and geometry
    dist_parser = subparsers.add_parser('dist', help='Euclidean distance between points')
    dist_parser.add_argument('coordinates', type=float, nargs='+', help='Coordinates')
    
    hypot_parser = subparsers.add_parser('hypot', help='Hypotenuse')
    hypot_parser.add_argument('coordinates', type=float, nargs='+', help='Coordinates')
    
    # Constants
    pi_parser = subparsers.add_parser('pi', help='Pi constant')
    e_parser = subparsers.add_parser('e', help="Euler's number")
    tau_parser = subparsers.add_parser('tau', help='Tau constant')
    inf_parser = subparsers.add_parser('inf', help='Positive infinity')
    nan_parser = subparsers.add_parser('nan', help='Not a number')
    
    # Utility functions
    degrees_parser = subparsers.add_parser('degrees', help='Convert radians to degrees')
    degrees_parser.add_argument('x', type=float, help='Angle in radians')
    
    radians_parser = subparsers.add_parser('radians', help='Convert degrees to radians')
    radians_parser.add_argument('x', type=float, help='Angle in degrees')
    
    # Check functions
    isfinite_parser = subparsers.add_parser('isfinite', help='Check if finite')
    isfinite_parser.add_argument('x', type=float, help='Number')
    
    isinf_parser = subparsers.add_parser('isinf', help='Check if infinite')
    isinf_parser.add_argument('x', type=float, help='Number')
    
    isnan_parser = subparsers.add_parser('isnan', help='Check if NaN')
    isnan_parser.add_argument('x', type=float, help='Number')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        sys.exit(1)
    
    try:
        result = None
        
        if args.command == 'sqrt':
            result = sqrt(args.x)
        elif args.command == 'ceil':
            result = ceil(args.x)
        elif args.command == 'floor':
            result = floor(args.x)
        elif args.command == 'log':
            result = log(args.x, args.base)
        elif args.command == 'exp':
            result = exp(args.x)
        elif args.command == 'factorial':
            result = factorial(args.n)
        elif args.command == 'gcd':
            result = gcd(*args.numbers)
        elif args.command == 'lcm':
            result = lcm(*args.numbers)
        elif args.command == 'sin':
            result = sin(args.x)
        elif args.command == 'cos':
            result = cos(args.x)
        elif args.command == 'tan':
            result = tan(args.x)
        elif args.command == 'asin':
            result = asin(args.x)
        elif args.command == 'acos':
            result = acos(args.x)
        elif args.command == 'atan':
            result = atan(args.x)
        elif args.command == 'atan2':
            result = atan2(args.y, args.x)
        elif args.command == 'sinh':
            result = sinh(args.x)
        elif args.command == 'cosh':
            result = cosh(args.x)
        elif args.command == 'tanh':
            result = tanh(args.x)
        elif args.command == 'pow':
            result = pow(args.x, args.y)
        elif args.command == 'fabs':
            result = fabs(args.x)
        elif args.command == 'fmod':
            result = fmod(args.x, args.y)
        elif args.command == 'trunc':
            result = trunc(args.x)
        elif args.command == 'erf':
            result = erf(args.x)
        elif args.command == 'erfc':
            result = erfc(args.x)
        elif args.command == 'gamma':
            result = gamma(args.x)
        elif args.command == 'lgamma':
            result = lgamma(args.x)
        elif args.command == 'comb':
            result = comb(args.n, args.k)
        elif args.command == 'perm':
            result = perm(args.n, args.k)
        elif args.command == 'dist':
            result = dist(args.coordinates)
        elif args.command == 'hypot':
            result = hypot(*args.coordinates)
        elif args.command == 'pi':
            result = pi()
        elif args.command == 'e':
            result = e()
        elif args.command == 'tau':
            result = tau()
        elif args.command == 'inf':
            result = inf()
        elif args.command == 'nan':
            result = nan()
        elif args.command == 'degrees':
            result = degrees(args.x)
        elif args.command == 'radians':
            result = radians(args.x)
        elif args.command == 'isfinite':
            result = isfinite(args.x)
        elif args.command == 'isinf':
            result = isinf(args.x)
        elif args.command == 'isnan':
            result = isnan(args.x)
        else:
            parser.print_help()
            sys.exit(1)
        
        # Output result
        if result is not None:
            if args.json:
                print(json.dumps({'result': result}))
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