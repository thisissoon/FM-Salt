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


__virtualname__ = 'boto_elb_ssl_certificate'


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
        __utils__['boto.assign_funcs'](__name__, 'elb', module='ec2.elb', pack=__salt__)


def set(
        elb_name,
        elb_port,
        certificate_arn,
        region=None,
        key=None,
        keyid=None,
        profile=None):
    '''
    Set an ELB's Certificate
    '''

    conn = _get_conn(region=region, key=key, keyid=keyid, profile=profile)
    try:
        conn.set_lb_listener_SSL_certificate(elb_name, elb_port, certificate_arn)
    except boto.exception.BotoServerError as e:
        log.debug(e)
        return False

    return True
