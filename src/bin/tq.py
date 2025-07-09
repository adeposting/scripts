#!/usr/bin/env python3


# TODO
#
# NEXT STEPS - Milestone 2
#
# - some filters make a *selection* over lines/chars/words/fields, some make a *transformation*
# - lets introduce filters 
# 	- 'lines' which is for all lines
# 	- 'chars' which is for chars on each line
# 	- 'words[:delim]' which is for words separated by delims 
# 	- 'fields' is used when words are split and have indices, but sometimes fields is used interchangably for some filters
# - selection syntax works like this 'lines|uniq' for uniq lines or 'chars|uniq' for all uniq chars on a line or 'words|uniq' for uniq words on a line
# - different filters have different defaults
# - but there are no filters that are specific to lines/chars/words, so even in the below e.g. count which currents counts chars per line becomes chars|count, but lines|count would count the number of lines
# - but selections can also be applied to other things, like (lines|head:1) could select only the first line
# - if selections occur in parenthesis, then we can apply a selection then a transform only on the selection, so (lines|head:1|upper) would only make the first line uppercase
# - modify the existing script with this new functionality
# - do not care about backwards compatibility
# - add to the help text, but don't remove most of the detail that is already there, just add to it or modify any changed filters
#
# NEXT STEPS - Milestone 3
#
# - now lets implement a comprehensive suite of new filters
# - some of these may not make sense for lines or chars or words, lets think about this first
# - some may make sense with a default for lines, chars or words, lets think about this first
#
# - grep[:pattern]: Output only lines/chars/words matching a regex pattern.
# - grep-v[:pattern]: Output only lines/chars/words NOT matching a pattern (inverse grep).
# - head[:n]: Output the first n lines/chars/words (default 10).
# - tail[:n]: Output the last n lines/chars/words (default 10).
# - nth[:n]: Output the nth line/char/word (1-based).
# - range[:start[:end]]: Output lines/chars/words from start to end (inclusive, 1-based).
# - cut[:delim[:fields]]: Split lines/chars/words by delimiter and output specified field (e.g., cut:,:1,3).
# - word[:n[:delim]]: Output the nth word from each line (default delim: whitespace.
# - split[:delim]: Split each line into multiple lines/chars/words by delimiter.
# - count: Output the number of lines/chars/words.
# - sum[:field[:delim]]: Sum numeric values in a field.
# - min[:field[:delim]]: Minimum value in a field.
# - max[:field[:delim]]: Maximum value in a field.
# - avg[:field[:delim]]: Average value in a field.
# - replace[:pattern[:replacement]]: Regex replace pattern with replacement.
# - match[:pattern]: Output only parts of line matching pattern
# - strip-ansi: Remove ANSI color codes from lines/chars/words.
# - json: Output lines/chars/words as a JSON array.
# - csv[:delim]: Output lines/chars/words as CSV, optionally with a custom delimiter.
# - prepend[:text]: Prepend text to each line.
# - append[:text]: Append text to each line.
# - wrap[:prefix[:suffix]]: Wrap each line with prefix and suffix.
# - uniq: Remove consecutive duplicate lines/chars/words (like Unix uniq).
# - group-by[:field[:delim]]: Group lines/chars/words by a field value.
# - sort-by[:field[:delim]]: Sort lines/chars/words by a field.
# - reverse: Reverse the order of all lines/chars/words (not the content), change reverse for chars to reverse-chars.
# - shuffle[:delim]: Randomly shuffle words with optional delim
# - at[:index1,index2,...]
# - jq-inspired (structure/transform)
# - to-array: Output all lines/chars/words as a JSON array.
# - from-json: Parse each line as JSON and allow field extraction
#


"""
tq - commandline plaintext processor [version 0.1.0]

tq is a tool for processing plaintext inputs, applying the given filter to its
plaintext text inputs and producing the filter's results as plaintext on
standard output.

Usage:
    tq [options] <tq filter> [file...]
    tq [options] --args <tq filter> [strings...]
    tq --test

If no file or string is provided, tq will read from standard input.

Options:
    --help, -h     Show this help message and exit
    --test         Run the built-in unit tests and exit
    --args         Treat remaining arguments as input strings instead of files
    -v, --version  Show version and exit

Filters:
    - join             Join all lines into a single string
    - snake-case       Convert to snake_case
    - kebab-case       Convert to kebab-case
    - camel-case       Convert to camelCase
    - pascal-case      Convert to PascalCase
    - title-case       Convert to Title Case
    - sentence-case    Convert to sentence case
    - lowercase        Convert to lowercase
    - uppercase        Convert to UPPERCASE
    - capitalize       Capitalize the first character
    - trim             Remove leading and trailing whitespace
    - reverse          Reverse each line
    - sort             Sort all lines
    - unique           Remove duplicate lines, preserving order
    - count            Count the number of characters in each line
    - length           Alias for count
    - first            Output only the first line
    - last             Output only the last line
    - indent[:n]       Indent each line by n spaces (default 4)
    - dedent           Remove leading whitespace from each line
    - pad-left[:w[:c]] Pad each line on the left to width w with char c
                       (default w=10, c=' ')
    - pad-right[:w[:c]] Pad each line on the right to width w with char c
                        (default w=10, c=' ')
    - remove-empty     Remove empty lines
    - truncate[:n]     Truncate each line to n characters (default 10)
    - col-width[:n]    Set a max number of characters per line; lines longer
                       than this are split (default 10)

Filters are applied per-line, however the 'join' filter can be used to join all
lines together to apply a filter to the entire input.

These filters may be piped together to create more complex filters with the pipe
operator |.

Examples:

# Convert each line of input to snake_case
    tq 'snake-case'

# Convert each line of input to kebab-case
    tq 'kebab-case'

# Convert each line of input to camelCase
    tq 'camel-case'

# Convert each line of input to snake_case, then reverse it
    tq 'snake-case | reverse'

# Convert each line of input to snake_case, then reverse it, then capitalize it
    tq 'snake-case | reverse | capitalize'

# Convert each line of input to snake_case, then reverse it, then capitalize it,
# then count the number of characters per-line
    tq 'snake-case | reverse | capitalize | count'

# Indent each line by 2 spaces, pad right to 20 chars with _
    tq 'indent:2 | pad-right:20:_'

# Remove empty lines and split lines to max 8 chars per line
    tq 'remove-empty | col-width:8'

# Run the built-in unit tests
    tq --test
"""

import sys
import re
import argparse
import unittest

class Tq:
	@classmethod
	def parse_args(cls):
		# Custom help handling
		if '--help' in sys.argv or '-h' in sys.argv:
			print(__doc__)
			sys.exit(0)
		if '--test' in sys.argv:
			return argparse.Namespace(test=True, filter=None, files=None, args=False)
		parser = argparse.ArgumentParser(add_help=False)
		parser.add_argument(
			'filter',
			help="tq filter string (e.g. 'snake-case | reverse')",
			nargs='?'
		)
		parser.add_argument(
			'files',
			help="Input files (default: stdin)",
			nargs='*'
		)
		parser.add_argument(
			'--args',
			help="Treat remaining arguments as input strings instead of files",
			action='store_true'
		)
		parser.add_argument(
			'-v', '--version',
			help="Show version and exit",
			action='version',
			version='0.1.0'
		)
		parser.add_argument(
			'--test',
			help="Run unit tests and exit",
			action='store_true'
		)
		return parser.parse_args()

	# --- Filter implementations ---
	@classmethod
	def join(cls, lines):
		return [''.join(lines)]

	@classmethod
	def snake_case(cls, line):
		return re.sub(r'[^a-zA-Z0-9]+', '_', line).strip('_').lower()

	@classmethod
	def kebab_case(cls, line):
		return re.sub(r'[^a-zA-Z0-9]+', '-', line).strip('-').lower()

	@classmethod
	def camel_case(cls, line):
		words = re.split(r'[^a-zA-Z0-9]+', line)
		return words[0].lower() + ''.join(w.capitalize() for w in words[1:]) if words else ''

	@classmethod
	def pascal_case(cls, line):
		words = re.split(r'[^a-zA-Z0-9]+', line)
		return ''.join(w.capitalize() for w in words)

	@classmethod
	def title_case(cls, line):
		return line.title()

	@classmethod
	def sentence_case(cls, line):
		line = line.strip()
		return line[:1].upper() + line[1:].lower() if line else ''

	@classmethod
	def lowercase(cls, line):
		return line.lower()

	@classmethod
	def uppercase(cls, line):
		return line.upper()

	@classmethod
	def capitalize(cls, line):
		return line.capitalize()

	@classmethod
	def trim(cls, line):
		return line.strip()

	@classmethod
	def reverse(cls, line):
		return line[::-1]

	@classmethod
	def sort(cls, lines):
		return sorted(lines)

	@classmethod
	def unique(cls, lines):
		seen = set()
		result = []
		for l in lines:
			if l not in seen:
				seen.add(l)
				result.append(l)
		return result

	@classmethod
	def count(cls, line):
		return str(len(line))

	@classmethod
	def length(cls, line):
		return str(len(line))

	@classmethod
	def first(cls, lines):
		return [lines[0]] if lines else []

	@classmethod
	def last(cls, lines):
		return [lines[-1]] if lines else []

	@classmethod
	def indent(cls, line, n=4):
		return ' ' * n + line

	@classmethod
	def dedent(cls, line):
		return line.lstrip()

	@classmethod
	def pad_left(cls, line, width=10, char=' '):
		return line.rjust(width, char)

	@classmethod
	def pad_right(cls, line, width=10, char=' '):
		return line.ljust(width, char)

	@classmethod
	def remove_empty(cls, lines):
		return [l for l in lines if l.strip() != '']

	@classmethod
	def truncate(cls, line, length=10):
		return line[:length]

	@classmethod
	def col_width(cls, lines, width=10):
		result = []
		for line in lines:
			while len(line) > width:
				result.append(line[:width])
				line = line[width:]
			if line:
				result.append(line)
		return result

	@classmethod
	def get_filters(cls):
		return {
			'join': cls.join,
			'snake-case': lambda l: cls.snake_case(l),
			'kebab-case': lambda l: cls.kebab_case(l),
			'camel-case': lambda l: cls.camel_case(l),
			'pascal-case': lambda l: cls.pascal_case(l),
			'title-case': lambda l: cls.title_case(l),
			'sentence-case': lambda l: cls.sentence_case(l),
			'lowercase': lambda l: cls.lowercase(l),
			'uppercase': lambda l: cls.uppercase(l),
			'capitalize': lambda l: cls.capitalize(l),
			'trim': lambda l: cls.trim(l),
			'reverse': lambda l: cls.reverse(l),
			'sort': cls.sort,
			'unique': cls.unique,
			'count': lambda l: cls.count(l),
			'length': lambda l: cls.length(l),
			'first': cls.first,
			'last': cls.last,
			'indent': lambda l: cls.indent(l),
			'dedent': lambda l: cls.dedent(l),
			'pad-left': lambda l: cls.pad_left(l),
			'pad-right': lambda l: cls.pad_right(l),
			'truncate': lambda l: cls.truncate(l),
		}

	@classmethod
	def parse_filter_string(cls, filter_str):
		if not filter_str:
			return []
		return [f.strip() for f in filter_str.split('|')]

	@classmethod
	def apply_filters(cls, lines, filter_chain):
		filters = cls.get_filters()
		for f in filter_chain:
			if f == 'join':
				lines = cls.join(lines)
			elif f == 'sort':
				lines = cls.sort(lines)
			elif f == 'unique':
				lines = cls.unique(lines)
			elif f == 'first':
				lines = cls.first(lines)
			elif f == 'last':
				lines = cls.last(lines)
			elif f == 'remove-empty':
				lines = cls.remove_empty(lines)
			elif f.startswith('col-width'):
				# e.g. col-width:20
				parts = f.split(':')
				w = int(parts[1]) if len(parts) > 1 else 10
				lines = cls.col_width(lines, w)
			elif f.startswith('indent'):
				# e.g. indent:2
				parts = f.split(':')
				n = int(parts[1]) if len(parts) > 1 else 4
				lines = [cls.indent(line, n) for line in lines]
			elif f.startswith('pad-left'):
				# e.g. pad-left:20:0
				parts = f.split(':')
				w = int(parts[1]) if len(parts) > 1 else 10
				c = parts[2] if len(parts) > 2 else ' '
				lines = [cls.pad_left(line, w, c) for line in lines]
			elif f.startswith('pad-right'):
				# e.g. pad-right:20:0
				parts = f.split(':')
				w = int(parts[1]) if len(parts) > 1 else 10
				c = parts[2] if len(parts) > 2 else ' '
				lines = [cls.pad_right(line, w, c) for line in lines]
			elif f.startswith('truncate'):
				# e.g. truncate:5
				parts = f.split(':')
				length = int(parts[1]) if len(parts) > 1 else 10
				lines = [cls.truncate(line, length) for line in lines]
			else:
				func = filters.get(f)
				if func:
					lines = [func(line) for line in lines]
				else:
					lines = [line for line in lines]
		return lines

	@classmethod
	def main(cls):
		args = cls.parse_args()
		if getattr(args, 'test', False):
			TqTest.run_tests()
			return
		if args.args:
			lines = args.files
		else:
			if args.files:
				lines = []
				for fname in args.files:
					with open(fname, 'r') as f:
						lines.extend([l.rstrip('\n') for l in f])
			else:
				lines = [l.rstrip('\n') for l in sys.stdin]

		if args.filter is None:
			for line in lines:
				print(line)
			return

		filter_chain = cls.parse_filter_string(args.filter)
		result = cls.apply_filters(lines, filter_chain)
		for line in result:
			print(line)

class TqTest(unittest.TestCase):
	def test_snake_case(self):
		self.assertEqual(Tq.snake_case('Hello World!'), 'hello_world')
		self.assertEqual(Tq.snake_case('fooBarBaz'), 'foobarbaz')
		self.assertEqual(Tq.snake_case('foo bar-baz'), 'foo_bar_baz')

	def test_kebab_case(self):
		self.assertEqual(Tq.kebab_case('Hello World!'), 'hello-world')
		self.assertEqual(Tq.kebab_case('fooBarBaz'), 'foobarbaz')
		self.assertEqual(Tq.kebab_case('foo bar-baz'), 'foo-bar-baz')

	def test_camel_case(self):
		self.assertEqual(Tq.camel_case('Hello World!'), 'helloWorld')
		self.assertEqual(Tq.camel_case('foo bar-baz'), 'fooBarBaz')
		self.assertEqual(Tq.camel_case('foo'), 'foo')

	def test_pascal_case(self):
		self.assertEqual(Tq.pascal_case('hello world'), 'HelloWorld')
		self.assertEqual(Tq.pascal_case('foo bar-baz'), 'FooBarBaz')
		self.assertEqual(Tq.pascal_case('foo'), 'Foo')

	def test_title_case(self):
		self.assertEqual(Tq.title_case('hello world'), 'Hello World')
		self.assertEqual(Tq.title_case('foo bar'), 'Foo Bar')

	def test_sentence_case(self):
		self.assertEqual(Tq.sentence_case('hello world'), 'Hello world')
		self.assertEqual(Tq.sentence_case('FOO BAR'), 'Foo bar')

	def test_lowercase(self):
		self.assertEqual(Tq.lowercase('Hello'), 'hello')

	def test_uppercase(self):
		self.assertEqual(Tq.uppercase('Hello'), 'HELLO')

	def test_capitalize(self):
		self.assertEqual(Tq.capitalize('hello'), 'Hello')

	def test_trim(self):
		self.assertEqual(Tq.trim('  hello  '), 'hello')

	def test_reverse(self):
		self.assertEqual(Tq.reverse('abc'), 'cba')

	def test_sort(self):
		self.assertEqual(Tq.sort(['b', 'a', 'c']), ['a', 'b', 'c'])

	def test_unique(self):
		self.assertEqual(Tq.unique(['a', 'b', 'a', 'c']), ['a', 'b', 'c'])

	def test_count(self):
		self.assertEqual(Tq.count('hello'), '5')

	def test_length(self):
		self.assertEqual(Tq.length('hello'), '5')

	def test_first(self):
		self.assertEqual(Tq.first(['a', 'b', 'c']), ['a'])
		self.assertEqual(Tq.first([]), [])

	def test_last(self):
		self.assertEqual(Tq.last(['a', 'b', 'c']), ['c'])
		self.assertEqual(Tq.last([]), [])

	def test_indent(self):
		self.assertEqual(Tq.indent('foo', 2), '  foo')

	def test_dedent(self):
		self.assertEqual(Tq.dedent('   foo'), 'foo')

	def test_pad_left(self):
		self.assertEqual(Tq.pad_left('foo', 5, '0'), '00foo')

	def test_pad_right(self):
		self.assertEqual(Tq.pad_right('foo', 5, '0'), 'foo00')

	def test_remove_empty(self):
		self.assertEqual(Tq.remove_empty(['a', '', 'b', ' ', 'c']), ['a', 'b', 'c'])

	def test_truncate(self):
		self.assertEqual(Tq.truncate('foobar', 3), 'foo')

	def test_col_width(self):
		self.assertEqual(Tq.col_width(['abcdef'], 2), ['ab', 'cd', 'ef'])
		self.assertEqual(Tq.col_width(['abc', 'defg'], 3), ['abc', 'def', 'g'])

	@staticmethod
	def run_tests():
		suite = unittest.defaultTestLoader.loadTestsFromTestCase(TqTest)
		result = unittest.TextTestRunner(verbosity=2).run(suite)
		sys.exit(0 if result.wasSuccessful() else 1)

if __name__ == "__main__":
	Tq.main()