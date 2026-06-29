# vim:fileencoding=utf-8:noet
from __future__ import (unicode_literals, division, absolute_import, print_function)

from powerline.theme import requires_segment_info

ICON = '\ue0a2'  # candado powerline (U+E0A2)


@requires_segment_info
def ssh(pl, segment_info):
	'''Indicador de sesión SSH remota.'''
	client = segment_info['environ'].get('SSH_CLIENT')
	if not client:
		return None

	remote = client.split()[0]
	return [{
		'contents': ICON + ' ' + remote,
		'highlight_groups': ['ssh'],
	}]
