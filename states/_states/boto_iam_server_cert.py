# -*- coding: utf-8 -*-

# Import Python Libs
from __future__ import absolute_import
import logging
import json
import os

# Import Salt Libs
import salt.utils
import salt.utils.odict as odict
import salt.utils.dictupdate as dictupdate
import salt.ext.six as six
from salt.ext.six import string_types
from salt.ext.six.moves import range  # pylint: disable=import-error,redefined-builtin

# Import 3rd party libs
try:
    from salt._compat import ElementTree as ET
    HAS_ELEMENT_TREE = True
except ImportError:
    HAS_ELEMENT_TREE = False

log = logging.getLogger(__name__)

__virtualname__ = 'boto_server_certificate'


def __virtual__():
    '''
    Only load if elementtree xml library and boto are available.
    '''
    if not HAS_ELEMENT_TREE:
        return (False, 'Cannot load {0} state: ElementTree library unavailable'.format(__virtualname__))

    if 'boto_iam.get_user' in __salt__:
        return True
    else:
        return (False, 'Cannot load {0} state: boto_iam module unavailable'.format(__virtualname__))

def present(
        name,
        public_key,
        private_key,
        cert_chain=None,
        path=None,
        region=None,
        key=None,
        keyid=None,
        profile=None):

    ret = {
        'name': name,
        'result': True,
        'comment': '', 'changes': {}
    }
    exists = __salt__['boto_iam.get_server_certificate'](name, region, key, keyid, profile)
    log.debug('Variables are : {0}.'.format(locals()))

    if exists:
        ret['comment'] = 'Certificate {0} exists.'.format(name)
        return ret

    pems = {
        'public_key': {
            'path': public_key,
            'body': ''
        },
        'private_key': {
            'path': private_key,
            'body': ''
        },
        'cert_chain': {
            'path': cert_chain,
            'body': ''
        }
    }
    for k in pems.keys():
        loc = pems[k]['path']
        try:
            pems[k]['body'] = __salt__['cp.get_file_str'](loc)
        except IOError as e:
            log.debug(e)
            ret['comment'] = 'File {0} not found.'.format(loc)
            ret['result'] = False
            return ret

    if __opts__['test']:
        ret['comment'] = 'Server certificate {0} is set to be created.'.format(name)
        ret['result'] = None
        return ret

    created = __salt__['boto_iam.upload_server_cert'](
            name,
            pems['public_key']['body'],
            pems['private_key']['body'],
            pems['cert_chain']['body'],
            path,
            region,
            key,
            keyid,
            profile)
    if not created:
        ret['result'] = False
        ret['comment'] = 'Certificate {0} failed to be created.'.format(name)
        return ret

    ret['comment'] = 'Certificate {0} was created.'.format(name)
    ret['changes'] = created
    return ret
