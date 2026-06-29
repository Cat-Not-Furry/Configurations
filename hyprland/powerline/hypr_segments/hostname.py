# vim:fileencoding=utf-8:noet
from __future__ import (unicode_literals, division, absolute_import, print_function)

import socket

from powerline.theme import requires_segment_info

# Mismo icono que waybar custom/hostname (Nerd Font U+F109)
ICON = '\uf109'


@requires_segment_info
def hostname(pl, segment_info, only_if_ssh=False, exclude_domain=False):
	'''Return the current hostname.

	:param bool only_if_ssh:
		Only return the hostname if currently in an SSH session.
	:param bool exclude_domain:
		Return the hostname without domain if there is one.
	'''
	if only_if_ssh and not segment_info['environ'].get('SSH_CLIENT'):
		return None

	if exclude_domain:
		name = socket.gethostname().split('.')[0]
	else:
		name = socket.gethostname()

	return [{
		'contents': ICON + ' ' + name,
		'highlight_groups': ['hostname'],
	}]
