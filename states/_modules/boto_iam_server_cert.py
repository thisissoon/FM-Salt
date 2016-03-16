# -*- coding: utf-8 -*-

# Import Python libs
from __future__ import absolute_import
import logging
import json
import yaml

# Import salt libs
import salt.utils.compat
import salt.utils.odict as odict
import salt.utils.boto

# Import third party libs
# pylint: disable=unused-import
from salt.ext.six import string_types
from salt.ext.six.moves.urllib.parse import unquote as _unquote  # pylint: disable=no-name-in-module
try:
    import boto
    import boto.iam
    logging.getLogger('boto').setLevel(logging.CRITICAL)
    HAS_BOTO = True
except ImportError:
    HAS_BOTO = False
# pylint: enable=unused-import

log = logging.getLogger(__name__)


__virtualname__ = 'boto_server_certificate'


def __virtual__():
    '''
    Only load if boto libraries exist.
    '''
    if not HAS_BOTO:
        return (False, 'The boto_iam module could not be loaded: boto libraries not found')
    return True


def __init__(opts):
    salt.utils.compat.pack_dunder(__name__)
    if HAS_BOTO:
        __utils__['boto.assign_funcs'](__name__, 'iam', pack=__salt__)


def get_all_server_certificates(region=None, key=None, keyid=None, profile=None):
    conn = _get_conn(region=region, key=key, keyid=keyid, profile=profile)
    try:
        certs = conn.get_all_server_certs()
        if not certs:
            return False
        return certs
    except boto.exception.BotoServerError as e:
        log.debug(e)
        msg = 'Failed to get all certificates.'
        return False
