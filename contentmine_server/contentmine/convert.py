import logging
import os
import sys
import subprocess
from tempfile import TemporaryDirectory
from pathlib import Path
from glob import glob

from ..utils.mime_type_constants import MimeTypes


LOGGER = logging.getLogger(__name__)


def get_supported_mime_types():
    return {MimeTypes.PDF}


def get_contentmine_home():
    return os.environ.get('CONTENTMINE_HOME')


def run_command(command, cwd=None, shell=False):
    try:
        LOGGER.info('command: %s', command)
        subprocess.run(
            command,
            stdout=sys.stdout,
            stderr=sys.stderr,
            cwd=cwd,
            shell=shell,
            check=True
        )
    except subprocess.CalledProcessError as e:
        LOGGER.error('command %s failed with %s, output=%s', command, e, e.output)
        raise e


def convert_document(filename, data_type, content):
    contentmine_home = get_contentmine_home()
    with TemporaryDirectory(suffix='-convert') as path:
        p = Path(path)
        input_file = p.joinpath('file%s' % Path(filename).suffix)
        input_file.write_bytes(content)
        xml_output_file = p.joinpath('target/output/svg/TEXT.0.html')
        command = [str(x) for x in [
            Path(contentmine_home).joinpath('pdf2xml.sh'),
            input_file
        ]]
        run_command(command, cwd=path)
        LOGGER.info('output files: %s', glob('%s/**/*' % path, recursive=True))
        return {
            'type': MimeTypes.XHTML,
            'content': xml_output_file.read_bytes()
        }
