#!/usr/bin/env python3

import argparse
import logging
import os
import sys
import re
import json
# from copy import deepcopy
from subprocess import Popen, PIPE

_header = """
                        -`
        ...            .o+`
     .+++s+   .h`.    `ooo/
    `+++%++  .h+++   `+oooo:
    +++o+++ .hhs++. `+oooooo:
    +s%%so%.hohhoo'  'oooooo+:
    `+ooohs+h+sh++`/:  ++oooo+:
     hh+o+hoso+h+`/++++.+++++++:
      `+h+++h.+ `/++++++++++++++:
               `/+++ooooooooooooo/`
              ./ooosssso++osssssso+`
             .oossssso-````/osssss::`
            -osssssso.      :ssss``to.
           :osssssss/  Mike  osssl   +
          /ossssssss/   8a   +sssslb
        `/ossssso+/:-        -:/+ossss'.-
       `+sso+:-`                 `.-/+oso:
      `++:.                           `-/+/
      .`                                 `/
"""

_VERSION = '0.1.0'
_AUTHOR = 'Mike'

# _log = None
_log = logging.getLogger('MainLogger')
_log.setLevel(logging.DEBUG)
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_SCRIPTNAME = os.path.basename(__file__)
_log_file = os.path.splitext(_SCRIPTNAME)[0] + '.log'
_path_json = os.path.expanduser('~/.config/remotes/paths.json')
_configs = {}


def _createLogger(
        stdout_level: int = logging.INFO,
        file_level: int = logging.DEBUG,
        color: bool = True):
    """ Creaters logging obj

    stdout_level: int: logging level displayed into the terminal
    file_level: int: logging level saved into the logging file
    color: bool: Enable/Disable color console output

    """
    global _log

    try:
        from colorlog import ColoredFormatter as ColorFormatter
        Formatter = ColorFormatter
    except ImportError:
        ColorFormatter = None
        Formatter = logging.Formatter

    # This means both 0 and 100 silence all output
    stdout_level = 100 if stdout_level == 0 else stdout_level

    has_color = ColorFormatter is not None and color

    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setLevel(stdout_level)
    logformat = '{color}%(levelname)-8s | %(message)s'
    logformat = logformat.format(
        color='%(log_color)s' if has_color else '',
        # reset='%(reset)s' if has_color else '',
    )
    stdout_format = Formatter(logformat)
    stdout_handler.setFormatter(stdout_format)

    _log.addHandler(stdout_handler)

    if file_level > 0 and file_level < 100:

        with open(_log_file, 'a') as log:
            log.write(_header)
            # log.write(f'\nDate: {datetime.datetime.date()}')
            log.write(f'\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}\n\n')

        file_handler = logging.FileHandler(filename=_log_file)
        file_handler.setLevel(file_level)
        file_format = logging.Formatter('%(levelname)-8s | %(filename)s: [%(funcName)s] - %(message)s')
        file_handler.setFormatter(file_format)

        _log.addHandler(file_handler)


def _str_to_logging(level: str):
    """ Convert logging level string to a logging number

    :level: str: integer representation or a valid logging string
                - debug/verbose
                - info
                - warn/warning
                - error
                - critical
            All non valid integer or logging strings defaults to 0 logging
    :returns: int: logging level from the given string

    """

    try:
        level = abs(int(level) - 100)
    except Exception:
        level = level.lower()
        if level == "debug" or level == 'verbose':
            level = logging.DEBUG
        elif level == "info":
            level = logging.INFO
        elif level == "warn" or level == "warning":
            level = logging.WARN
        elif level == "error":
            level = logging.ERROR
        elif level == "critical":
            level = logging.CRITICAL
        else:
            level = 100

    return level


def _parseArgs():
    """ Parse CLI arguments
    :returns: argparse.ArgumentParser class instance

    """
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--version',
        dest='show_version',
        action='store_true',
        help='print script version and exit',
    )

    parser.add_argument(
        '--verbose',
        dest='verbose',
        action='store_true',
        default=False,
        help='Turn on Debug messages',
    )

    parser.add_argument(
        '--quiet',
        dest='quiet',
        action='store_true',
        default=False,
        help='Turn off all messages',
    )

    parser.add_argument(
        '-l',
        '--logging',
        dest='stdout_logging',
        default="info",
        type=str,
        help='File logger verbosity',
    )

    parser.add_argument(
        '--file-logging',
        dest='file_logging',
        default='0',
        type=str,
        help='File logger verbosity'
    )

    parser.add_argument(
        '--no-color',
        dest='no_color',
        action='store_false',
        help='Disable colored output'
    )

    parser.add_argument(
        '-g',
        '--get-file',
        dest='get_file',
        action='store_true',
        default=False,
        help='Get remote file instead of sending it'
    )

    parser.add_argument(
        '-H',
        '--host',
        '--hosts',
        dest='hosts',
        # default='',
        nargs='+',
        type=str,
        help='Hostname to send/get file'
    )

    parser.add_argument(
        '-f',
        '--file',
        dest='files',
        # default='',
        nargs='+',
        type=str,
        help='Hostname to send/get file'
    )

    parser.add_argument(
        '--dry',
        '--dry-run',
        dest='dry',
        action='store_true',
        default=False,
        help="Just print the messages but doesn't send/get them",
    )

    return parser.parse_args()


def _parse_ssh_config():
    """TODO: Docstring for _parse_ssh_config.
    :returns: TODO

    """
    config = {}
    config_file = os.path.expanduser('~/.ssh/config')
    if os.path.isfile(config_file):
        with open(config_file, 'r') as config_data:
            ishostname = False
            host = ''
            hostregex = re.compile(r'^\s*Host\s+([\w._-]+)$', re.IGNORECASE)
            hostnameregex = re.compile(r'^\s*Hostname\s+([\w._-]+)$', re.IGNORECASE)
            for line in config_data.readlines():
                if not ishostname:
                    host_match = hostregex.match(line)
                    if host_match is not None:
                        host = host_match.group(1)
                        ishostname = not ishostname
                else:
                    host_match = hostnameregex.match(line)
                    if host_match is not None:
                        config[host] = host_match.group(1)
                        ishostname = not ishostname

    return config


def _execute(cmd: list, background: bool):
    """ Execute a synchronous command

    :cmd: list: command to execute
    :returns: Popen obj: command object after execution

    """
    rc = 0
    stdout = sys.stdout if not background else PIPE
    stderr = sys.stderr if not background else PIPE
    _log.debug(f'Executing cmd: {cmd}')
    cmd_obj = Popen(cmd, stdout=stdout, stderr=stderr, text=True)
    out, err = cmd_obj.communicate()
    if out is not None and len(out) > 0:
        _log.debug(out)
    if cmd_obj.returncode != 0:
        rc = 1
        _log.error(f'Command exited with {cmd_obj.returncode}')
        if err is not None:
            _log.error(err)
    return rc


def convert_path(path: str, send: bool, hostname: str):
    """TODO: Docstring for convert_path.

    :path: TODO
    :send: TODO
    :returns: TODO

    """
    global _configs

    remote_path = './'
    path = os.path.realpath(os.path.expanduser(path))
    # _log.debug(f'Realpath: {path}')

    paths = {}
    hosts = {}
    project = 'mike'
    projects = {}

    if 'hosts' in _configs:
        hosts = _configs['hosts']

    if 'projects' in _configs:
        projects = _configs['projects'].copy()
        if 'default' in projects:
            project = projects['default']
            del projects['default']

    if hostname in hosts:
        paths = hosts[hostname]
    elif 'paths' in _configs:
        paths = _configs['paths']

    # _log.debug(f"Default Project: {project}")
    # _log.debug(f"Projects: {projects}")
    # _log.debug(f"Paths: {paths}")

    project_regex = re.compile(r'projects/(\w+)', re.IGNORECASE)
    project_match = project_regex.match(path)
    if project_match is not None:
        project = project_match.group(1)
    elif len(projects.keys()) > 0:
        short_regex = re.compile(f'/({"|".join(projects.keys())})(\\w+|/)', re.IGNORECASE)
        short_match = short_regex.match(path)
        if short_match is not None and short_match.group(1) in projects:
            project = projects[short_match.group(1)]
        elif os.getenv('PROJECT') is not None:
            project = os.getenv('PROJECT')

        if short_match is not None and short_match.group(1) not in projects:
            _log.warn(f'Unknown project {short_match.group(1)} using {project}')

    _log.debug(f"Current Project: {project}")

    for loc, remote in paths.items():
        if loc.find('%PROJECT'):
            loc = loc.replace('%PROJECT', project)
        loc = os.path.expanduser(loc)
        # _log.debug(f'Local path check {loc}')
        if path.find(loc) != -1:
            tail = path.replace(loc, '')
            if remote.find('%PROJECT'):
                remote = remote.replace('%PROJECT', project)
            remote_path = remote + tail
            break

    if not send and remote_path == './':
        remote_path = remote_path + os.path.basename(path)

    return remote_path


def remote_cmd(locpath: str, rmtpath: str, host: str, send: bool):
    """TODO: Docstring for remote_cmd.

    :path: TODO
    :send: TODO
    :returns: TODO

    """
    remote_path = f'{host}:{rmtpath}'
    rcmd = [
        'scp',
        '-r'
    ]
    rcmd += [locpath, remote_path] if send else [remote_path, locpath]
    return rcmd


def main():
    """ Main function
    :returns: TODO

    """
    global _configs
    args = _parseArgs()

    if args.show_version:
        print(f'{_header}\nAuthor:   {_AUTHOR}\nVersion:  {_VERSION}')
        return 0

    stdout_level = args.stdout_logging if not args.verbose else 'debug'
    file_level = args.file_logging if not args.verbose else 'debug'

    stdout_level = stdout_level if not args.quiet else 0
    file_level = file_level if not args.quiet else 0

    _createLogger(
        stdout_level=_str_to_logging(stdout_level),
        file_level=_str_to_logging(file_level),
        color=args.no_color,
    )

    if args.files is None or args.hosts is None:
        _log.error('Missing files or hosts arguments')
        return 1

    errors = 0
    try:
        hosts = _parse_ssh_config()
        _log.debug(f'SSH hosts: {hosts}')

        if os.path.isfile(_path_json):
            _log.debug('Parsing remote paths')
            with open(_path_json) as remotes:
                _configs = json.load(remotes)

            # _log.debug(f'Configs: {_configs}')
        else:
            _log.warning(f'Missing remote json config "{_path_json}"')

        get = args.get_file

        for hostname in args.hosts:
            action = 'Dry-run - ' if args.dry else ''
            action += 'Getting {file} from {host}:{rmtpath}' if get else 'Sending {file} to {host}:{rmtpath}'
            for filename in args.files:
                if not os.path.isfile(filename) and not os.path.isdir(filename) and not args.get_file:
                    _log.warning(f'Skipping {filename}, not a file/dir')
                    continue
                rmtpath = convert_path(filename, not args.get_file, hostname)
                rcmd = remote_cmd(filename, rmtpath, hostname, not args.get_file)
                _log.info(action.format(file=filename, host=hostname, rmtpath=rmtpath))
                if not args.dry:
                    errors += _execute(rcmd, hostname in hosts)

    except (Exception, KeyboardInterrupt) as e:
        _log.exception(f'Halting due to {str(e.__class__.__name__)} exception')
        errors = 1

    return errors


if __name__ == "__main__":
    exit(main())
