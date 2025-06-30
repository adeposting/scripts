#!/usr/bin/env python3

# ------------------------------
# Imports
# ------------------------------

from datetime import datetime
from itertools import chain
from pathlib import Path
from typing import Dict, List, Optional
import argparse
import logging
import os
import re
import subprocess
import sys


# ------------------------------
# Class iMsgDL
# ------------------------------


class iMsgDL:
    """
    Encapsulates functionality for running imessage-exporter
    and renaming exported files based on a macOS vCard.

    Attributes:
        vcard_path (Path): Path to the exported vCard file.
        formats (List[str]): List of formats to export (txt, html).
        export_root (Path): Root directory where exports are stored.
        rename_only (bool): Whether to skip export and only rename files.
        phone_to_name (Dict[str, str]): Mapping from last 7 digits of phone number
            to contact name.
        logger (logging.Logger): Logger instance for progress and errors.
    """

    def __init__(
        self,
        vcard_path: Path,
        formats: List[str],
        export_root: Path,
        rename_only: bool,
        log_level: str,
        log_file: Optional[Path],
    ):
        self.vcard_path = vcard_path
        self.formats = formats
        self.export_root = export_root
        self.rename_only = rename_only
        self.phone_to_name: Dict[str, str] = {}
        self.logger = self._setup_logger(log_level, log_file)

    def _setup_logger(self, level: str, logfile: Optional[Path]) -> logging.Logger:
        """
        Configures the Python logger.

        Args:
            level: Logging level as a string.
            logfile: Optional path to a file for writing logs.

        Returns:
            Configured logging.Logger instance.
        """
        numeric_level = getattr(logging, level.upper(), None)
        if not isinstance(numeric_level, int):
            numeric_level = logging.INFO

        handlers = [logging.StreamHandler(sys.stdout)]
        if logfile:
            handlers.append(logging.FileHandler(str(logfile)))

        logging.basicConfig(
            level=numeric_level,
            format="[%(levelname)s] %(message)s",
            handlers=handlers,
        )
        logger = logging.getLogger("iMsgDL")
        logger.debug("Logger initialized with level %s", level.upper())
        return logger

    def run(self) -> None:
        """
        Main entry point for running exports and renaming operations.
        """
        self.logger.info("Starting iMsgDL process")
        self._validate_inputs()
        self._parse_vcard()

        for fmt in self.formats:
            export_path = self._export_path_for_format(fmt)

            if not self.rename_only:
                if export_path.exists():
                    self._fail(
                        f"Export path already exists: {export_path}. "
                        f"Refusing to overwrite. Use --rename-only if you only want to rename."
                    )
                copy_method = self._choose_copy_method(fmt)
                self._run_exporter(fmt, copy_method, export_path)

            if export_path.exists():
                self._rename_files(export_path)
            else:
                self.logger.warning(
                    f"Export path does not exist for format {fmt}: {export_path}. "
                    f"Skipping renaming."
                )

        self.logger.info("iMsgDL completed successfully.")

    def _validate_inputs(self) -> None:
        """
        Validates input paths and CLI arguments.
        """
        self.logger.debug(f"Validating vCard path: {self.vcard_path}")
        if not self.vcard_path.exists():
            self._fail(f"vCard file not found: {self.vcard_path}")
        if not self.vcard_path.is_file():
            self._fail(f"vCard path is not a file: {self.vcard_path}")

        self.logger.debug(f"Validating export root: {self.export_root}")
        if not self.export_root.exists():
            self.logger.info(f"Creating export root: {self.export_root}")
            self.export_root.mkdir(parents=True)

        if not self.formats:
            self.logger.info("No formats specified. Defaulting to ['html', 'txt']")
            self.formats = ["html", "txt"]

    def _parse_vcard(self) -> None:
        """
        Parses vCard file and populates phone-to-name lookup table.
        """
        filtered_vcf = self._filter_vcard(self.vcard_path)
        total_contacts = self._count_vcards(filtered_vcf)

        block: List[str] = []
        processed = 0

        with filtered_vcf.open() as f:
            for line in f:
                line = line.rstrip("\n")
                if line == "BEGIN:VCARD":
                    block = [line]
                elif line == "END:VCARD":
                    block.append(line)
                    self._process_vcard_block(block)
                    processed += 1
                    self.logger.info(f"Processed {processed}/{total_contacts} contacts")
                else:
                    block.append(line)

        filtered_vcf.unlink()
        self.logger.info(
            f"Finished parsing vCard. Loaded {len(self.phone_to_name)} phone mappings."
        )

    def _filter_vcard(self, vcf_path: Path) -> Path:
        """
        Filters vCard file for only relevant lines.

        Args:
            vcf_path: Path to original vCard file.

        Returns:
            Path to the filtered temporary vCard file.
        """
        filtered = vcf_path.with_suffix(".filtered")
        with vcf_path.open() as infile, filtered.open("w") as outfile:
            for line in infile:
                if line.startswith(("BEGIN:VCARD", "END:VCARD", "FN:", "TEL")):
                    outfile.write(line)
        self.logger.debug(f"Filtered vCard written to: {filtered}")
        return filtered

    def _count_vcards(self, vcf_path: Path) -> int:
        """
        Counts the number of contacts in a filtered vCard file.

        Args:
            vcf_path: Path to filtered vCard.

        Returns:
            Number of BEGIN:VCARD entries.
        """
        count = sum(1 for line in vcf_path.open() if line.startswith("BEGIN:VCARD"))
        self.logger.debug(f"Found {count} vCard blocks")
        return count

    def _process_vcard_block(self, block: List[str]) -> None:
        """
        Processes a single vCard block and updates lookup table.

        Args:
            block: Lines from one vCard contact block.
        """
        long_name = ""
        numbers: List[str] = []

        for line in block:
            if line.startswith("FN:"):
                long_name = line[3:]
            elif line.startswith("TEL"):
                phone = self._clean_phone(line.split(":", 1)[1])
                if phone:
                    numbers.append(phone)

        short_name = self._shorten_name(long_name)

        if long_name and numbers:
            for phone in numbers:
                self.phone_to_name[phone] = short_name
                self.logger.debug(f"Mapped phone {phone} → {short_name}")

    def _clean_phone(self, raw_phone: str) -> str:
        """
        Normalizes a phone string to last 7 digits.

        Args:
            raw_phone: Raw TEL string from vCard.

        Returns:
            String of last 7 digits, or empty string if invalid.
        """
        digits = "".join(c for c in raw_phone if c.isdigit())
        if len(digits) >= 7:
            last7 = digits[-7:]
            self.logger.debug(f"Cleaned phone {raw_phone} → {last7}")
            return last7
        else:
            self.logger.debug(f"Ignoring phone number too short: {raw_phone}")
            return ""

    def _shorten_name(self, name: str) -> str:
        """
        Removes parentheses or brackets and trims the name for filenames.

        Args:
            name: Original contact name.

        Returns:
            Cleaned name suitable for filenames.
        """
        clean_name = re.sub(r"\s*[\(\[].*?[\)\]]", "", name).strip()
        clean_name = re.sub(r"[^A-Za-z0-9_]", "_", clean_name)
        if len(clean_name) > 50:
            self.logger.warning(f"Truncating long name for filename safety: {clean_name}")
            clean_name = clean_name[:50]
        self.logger.debug(f"Shortened name: {name} → {clean_name}")
        return clean_name

    def _choose_copy_method(self, fmt: str) -> str:
        """
        Determines copy method based on export format.

        Args:
            fmt: Export format ('html' or 'txt').

        Returns:
            String representing copy method for imessage-exporter.
        """
        if fmt == "html":
            return "full"
        elif fmt == "txt":
            return "disabled"
        else:
            self._fail(f"Unknown format: {fmt}")

    def _run_exporter(self, fmt: str, copy_method: str, export_path: Path) -> None:
        """
        Runs the imessage-exporter CLI tool.

        Args:
            fmt: Export format.
            copy_method: Copy method argument.
            export_path: Destination path for export files.
        """
        binary = self._get_exporter_path()
        cmd = [
            str(binary),
            "--format", fmt,
            "--copy-method", copy_method,
            "--export-path", str(export_path),
        ]

        self.logger.info(f"Running imessage-exporter: {' '.join(cmd)}")
        self._run_subprocess(cmd)
        self.logger.info(f"Export completed: {export_path}")

    def _run_subprocess(self, cmd: List[str]) -> None:
        """
        Executes a subprocess command.

        Args:
            cmd: List of command-line arguments.
        """
        subprocess.run(cmd, check=True)

    def _rename_files(self, export_dir: Path) -> None:
        """
        Renames message export files based on vCard mappings.

        Args:
            export_dir: Directory containing exported message files.
        """
        renamed = 0
        skipped = 0

        for file_path in chain(export_dir.glob("+*.txt"), export_dir.glob("+*.html")):
            stem = file_path.stem

            # Skip files already renamed (contain an underscore)
            if "_" in stem:
                self.logger.debug(f"Skipping already-renamed file: {file_path.name}")
                skipped += 1
                continue

            # Split on commas for multi-number files
            numbers_raw = [n.strip() for n in stem.split(",")]

            new_segments = []
            for num_str in numbers_raw:
                digits = "".join(c for c in num_str if c.isdigit())
                if len(digits) >= 7:
                    last7 = digits[-7:]
                    name = self.phone_to_name.get(last7)
                    if name:
                        safe_name = name.replace(" ", "_")
                        safe_name = re.sub(r"[^A-Za-z0-9_]", "_", safe_name)
                        new_segment = f"+{digits}_{safe_name}"
                    else:
                        new_segment = f"+{digits}"
                    new_segments.append(new_segment)
                else:
                    self.logger.warning(f"Skipping unrecognizable number part: {num_str}")
                    new_segments.append(num_str)

            new_filename = "_".join(new_segments) + file_path.suffix
            new_path = export_dir / new_filename

            if new_path.exists():
                self.logger.warning(f"File already exists, skipping rename: {new_filename}")
                skipped += 1
                continue

            file_path.rename(new_path)
            self.logger.info(f"Renamed {file_path.name} → {new_filename}")
            renamed += 1

        self.logger.info(
            f"Renaming complete. Renamed: {renamed} files. Skipped: {skipped} files."
        )

    def _clean_filename_number(self, text: str) -> str:
        """
        Extracts last 7 digits from a filename stem.

        Args:
            text: Filename stem.

        Returns:
            Last 7 digits of phone number, or empty string if insufficient length.
        """
        digits = "".join(c for c in text if c.isdigit())
        return digits[-7:] if len(digits) >= 7 else ""

    def _get_exporter_path(self) -> Path:
        """
        Returns path to imessage-exporter binary.

        Returns:
            Path to binary.
        """
        return Path.home() / ".cargo" / "bin" / "imessage-exporter"

    def _export_path_for_format(self, fmt: str) -> Path:
        """
        Constructs export path for a given format.

        Args:
            fmt: Format string.

        Returns:
            Path to the export folder for this format.
        """
        date_prefix = datetime.now().strftime("%Y-%m-%d")
        return self.export_root / f"{date_prefix}_imessage_export_{fmt}"

    def _fail(self, message: str) -> None:
        """
        Logs an error and raises a runtime exception.

        Args:
            message: Error message to log.
        """
        self.logger.error(message)
        raise RuntimeError(message)


# ------------------------------
# CLI
# ------------------------------


def cli(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Export iMessages from macOS and rename exported message files "
            "to include contact names from your vCard."
        ),
        epilog=(
            "How to export your vCard:\n"
            "  1. Open the Contacts app on macOS.\n"
            "  2. Select all contacts (⌘A).\n"
            "  3. Go to File → Export → Export vCard…\n"
            "  4. Save your vCard, e.g. ~/contacts.vcf\n\n"
            "Examples:\n"
            "  imsgdl.py --vcard-path ~/contacts.vcf\n"
            "  imsgdl.py --vcard-path ~/contacts.vcf --format txt\n"
            "  imsgdl.py --vcard-path ~/contacts.vcf --rename-only --export-path ./my_exports"
        ),
        formatter_class=argparse.RawTextHelpFormatter,
    )

    parser.add_argument(
        "--vcard-path",
        type=Path,
        required=True,
        help="Path to exported vCard (.vcf) file from Contacts.app",
    )

    parser.add_argument(
        "--format",
        action="append",
        choices=["html", "txt"],
        help="Export format(s): html or txt. Can be specified multiple times.",
    )

    parser.add_argument(
        "--export-path",
        type=Path,
        default=Path.cwd(),
        help="Root directory under which export folders will be created. Defaults to current directory.",
    )

    parser.add_argument(
        "--rename-only",
        action="store_true",
        help="Skip running imessage-exporter and only rename files in existing export directories.",
    )

    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output.",
    )

    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug output.",
    )

    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress non-error output.",
    )

    parser.add_argument(
        "--log-level",
        choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
        help="Explicit logging level. Overrides other flags.",
    )

    parser.add_argument(
        "--log-file",
        type=Path,
        help="Write logs to file instead of stdout.",
    )

    args = parser.parse_args(argv)

    # Determine log level priority:
    level = "INFO"

    env_level = os.environ.get("IMSGDL_LOG_LEVEL")
    if env_level:
        level = env_level

    if args.log_level:
        level = args.log_level
    elif args.debug:
        level = "DEBUG"
    elif args.verbose:
        level = "INFO"
    elif args.quiet:
        level = "ERROR"

    try:
        downloader = iMsgDL(
            vcard_path=args.vcard_path,
            formats=args.format or [],
            export_root=args.export_path,
            rename_only=args.rename_only,
            log_level=level,
            log_file=args.log_file,
        )
        downloader.run()
        return 0
    except RuntimeError as e:
        print(str(e))
        return 1


if __name__ == "__main__":
    sys.exit(cli())
