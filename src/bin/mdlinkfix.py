#!/usr/bin/env python3

"""
mdlinkfix - fix bare or empty markdown links by fetching titles

Usage:
    mdlinkfix [options] <path>...

Options:
    --help, -h     Show this help message and exit
    --test         Run the built-in unit tests and exit
    -v, --verbose  Enable verbose logging

If a path is a directory, it is searched recursively for .md files.

If run inside a git repository, only files tracked by git will be processed.
"""

import sys
import os
import re
import subprocess
import argparse
import logging
import urllib.request
import unittest


class MdLinkFix:
    @staticmethod
    def parse_args():
        if '--help' in sys.argv or '-h' in sys.argv:
            print(__doc__)
            sys.exit(0)
        if '--test' in sys.argv:
            return argparse.Namespace(test=True, paths=[], verbose=False)
        parser = argparse.ArgumentParser(add_help=False)
        parser.add_argument(
            'paths',
            nargs='+',
            help='Files or directories to process'
        )
        parser.add_argument(
            '-v', '--verbose',
            help='Enable verbose logging',
            action='store_true'
        )
        parser.add_argument(
            '--test',
            help='Run unit tests and exit',
            action='store_true'
        )
        return parser.parse_args()

    @staticmethod
    def is_git_repo(path):
        try:
            subprocess.run(
                ['git', '-C', path, 'rev-parse'],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=True
            )
            return True
        except subprocess.CalledProcessError:
            return False

    @staticmethod
    def get_git_tracked_files(path):
        try:
            result = subprocess.run(
                ['git', '-C', path, 'ls-files'],
                capture_output=True,
                text=True,
                check=True
            )
            files = result.stdout.splitlines()
            return [os.path.join(path, f) for f in files if f.endswith('.md')]
        except subprocess.CalledProcessError:
            return []

    @staticmethod
    def walk_files(paths):
        all_md_files = []
        for p in paths:
            if os.path.isfile(p) and p.endswith('.md'):
                all_md_files.append(os.path.abspath(p))
            elif os.path.isdir(p):
                for root, _, files in os.walk(p):
                    for f in files:
                        if f.endswith('.md'):
                            all_md_files.append(os.path.join(root, f))
        return all_md_files

    @staticmethod
    def get_page_title(url):
        try:
            with urllib.request.urlopen(url, timeout=5) as response:
                content_type = response.headers.get('Content-Type', '')
                charset = 'utf-8'
                if 'charset=' in content_type:
                    charset = content_type.split('charset=')[-1].split(';')[0].strip()
                html = response.read().decode(charset, errors='ignore')
                match = re.search(
                    r'<title[^>]*>(.*?)</title>',
                    html,
                    re.IGNORECASE | re.DOTALL
                )
                if match:
                    return match.group(1).strip()
        except Exception as e:
            logging.warning(f"Could not fetch title for '{url}': {e}")
        return url

    @staticmethod
    def replace_links(text, file_path=None):
        # Regex for bare URLs
        url_pattern = re.compile(r'(?<!\]\()(?P<url>https?://[^\s)]+)')
        # Regex for empty markdown links
        empty_md_link_pattern = re.compile(
            r'\[\s*\]\((?P<url>https?://[^\s)]+)\)'
        )

        def repl_bare(match):
            old_link = match.group('url')
            title = MdLinkFix.get_page_title(old_link)
            new_link = f'[{title}]({old_link})'
            if file_path:
                logging.info(f"Replacing '{old_link}' with '{new_link}' in '{os.path.basename(file_path)}'")
            return new_link

        def repl_empty(match):
            url = match.group('url')
            title = MdLinkFix.get_page_title(url)
            old_link = f"[]({url})"
            new_link = f'[{title}]({url})'
            if file_path:
                logging.info(f"Replacing '{old_link}' with '{new_link}' in '{os.path.basename(file_path)}'")
            return new_link

        text = url_pattern.sub(repl_bare, text)
        text = empty_md_link_pattern.sub(repl_empty, text)
        return text

    @staticmethod
    def process_markdown(md_text, file_path=None):
        """
        Processes markdown but skips:
        - fenced code blocks
        - inline code
        - indented code blocks
        """

        pattern = re.compile(
            r'(```.*?```|~~~.*?~~~|`[^`\n]*`|^(?: {4}|\t).*(?:\n|$)+)',
            re.DOTALL | re.MULTILINE
        )

        parts = []
        last_end = 0

        for match in pattern.finditer(md_text):
            start, end = match.span()
            # Process text before code
            text_part = md_text[last_end:start]
            if text_part:
                parts.append(MdLinkFix.replace_links(text_part, file_path))
            parts.append(md_text[start:end])
            last_end = end

        remaining = md_text[last_end:]
        if remaining:
            parts.append(MdLinkFix.replace_links(remaining, file_path))

        return ''.join(parts)

    @classmethod
    def main(cls):
        args = cls.parse_args()

        if getattr(args, 'test', False):
            MdLinkFixTest.run_tests()
            return

        logging.basicConfig(
            level=logging.DEBUG if args.verbose else logging.INFO,
            format='[%(levelname)s] %(message)s'
        )

        # Determine which files to process
        files = []

        for path in args.paths:
            if os.path.isdir(path) and cls.is_git_repo(path):
                git_files = cls.get_git_tracked_files(path)
                logging.info(f"Detected git repo in '{path}', using tracked files ({len(git_files)} .md files).")
                files.extend(git_files)
            elif os.path.isdir(path):
                walk_files = cls.walk_files([path])
                logging.info(f"Walking directory '{path}', found {len(walk_files)} markdown files.")
                files.extend(walk_files)
            elif os.path.isfile(path) and path.endswith('.md'):
                logging.info(f"Adding markdown file '{os.path.basename(path)}'")
                files.append(os.path.abspath(path))

        # Remove duplicates
        files = list(sorted(set(files)))

        for fpath in files:
            logging.info(f"Processing '{os.path.basename(fpath)}'")
            with open(fpath, encoding='utf-8') as f:
                md = f.read()

            updated = cls.process_markdown(md, fpath)

            if updated != md:
                with open(fpath, 'w', encoding='utf-8') as f:
                    f.write(updated)
                logging.info(f"Updated '{os.path.basename(fpath)}'")
            else:
                logging.debug(f"No changes in '{os.path.basename(fpath)}'")

        logging.info("Done")


class MdLinkFixTest(unittest.TestCase):
    def test_replace_links(self):
        md = """
Here is a bare link:
https://example.com

And an empty link:
[](https://example.com)

And inline code:
`https://example.com`

And a fenced block:

```bash
https://example.com
```

~~~bash
https://example.com
~~~

~~~
https://example.com
~~~

And some text after:
[](https://example.com)
"""
        result = MdLinkFix.process_markdown(md)
        # Should replace bare links and empty links outside code blocks
        self.assertIn("[Example Domain](https://example.com)", result)
        # Inline code should remain unchanged
        self.assertIn("`https://example.com`", result)
        # Fenced code block should remain unchanged
        self.assertIn("```bash\nhttps://example.com\n```", result)
        self.assertIn("~~~bash\nhttps://example.com\n~~~", result)

    @staticmethod
    def run_tests():
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(MdLinkFixTest)
        result = unittest.TextTestRunner(verbosity=2).run(suite)
        sys.exit(0 if result.wasSuccessful() else 1)

if __name__ == "__main__":
    MdLinkFix.main()
