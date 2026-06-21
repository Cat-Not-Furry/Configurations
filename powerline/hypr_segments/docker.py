# vim:fileencoding=utf-8:noet
from __future__ import (unicode_literals, division, absolute_import, print_function)

import os
import subprocess

from powerline.theme import requires_segment_info

ICON = '\uf308'  # nf-fa-docker (Nerd Font)

DOCKER_MARKERS = (
	'Dockerfile',
	'docker-compose.yml',
	'docker-compose.yaml',
	'compose.yml',
	'compose.yaml',
	'docker-compose.override.yml',
	'.dockerignore',
)


def _has_docker_files(path):
	current = os.path.abspath(path)
	seen = set()

	while current not in seen:
		seen.add(current)
		for name in DOCKER_MARKERS:
			if os.path.isfile(os.path.join(current, name)):
				return True
		parent = os.path.dirname(current)
		if parent == current:
			break
		current = parent

	return False


@requires_segment_info
def docker(pl, segment_info, show_stopped=False):
	'''Contenedores Docker si el proyecto tiene archivos Docker.'''
	try:
		cwd = segment_info['getcwd']()
	except (OSError, KeyError):
		return None

	if not _has_docker_files(cwd):
		return None

	args = ['docker', 'ps', '-q']
	if show_stopped:
		args = ['docker', 'ps', '-aq']

	try:
		result = subprocess.run(
			args,
			stdout=subprocess.PIPE,
			stderr=subprocess.PIPE,
			timeout=2,
		)
	except (OSError, subprocess.TimeoutExpired):
		return None

	if result.returncode != 0:
		return None

	count = len([line for line in result.stdout.decode('utf-8', 'replace').splitlines() if line.strip()])
	if count == 0:
		return None

	return [{
		'contents': ICON + ' ' + str(count),
		'highlight_groups': ['docker'],
	}]
