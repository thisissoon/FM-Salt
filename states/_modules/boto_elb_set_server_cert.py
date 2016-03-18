# -*- coding: utf-8 -*-

from __future__ import absolute_import

# Import Python libs
import logging
from distutils.version import LooseVersion as _LooseVersion  # pylint: disable=import-error,no-name-in-module
import json
import salt.ext.six as six

log = logging.getLogger(__name__)

# Import third party libs
try:
    import boto
    # connection settings were added in 2.33.0
    required_boto_version = '2.33.0'
    if (_LooseVersion(boto.__version__) <
            _LooseVersion(required_boto_version)):
        msg = 'boto_elb requires boto {0}.'.format(required_boto_version)
        logging.debug(msg)
        raise ImportError()
    import boto.ec2
    from boto.ec2.elb import HealthCheck
    from boto.ec2.elb.attributes import AccessLogAttribute
    from boto.ec2.elb.attributes import ConnectionDrainingAttribute
    from boto.ec2.elb.attributes import ConnectionSettingAttribute
    from boto.ec2.elb.attributes import CrossZoneLoadBalancingAttribute
    logging.getLogger('boto').setLevel(logging.CRITICAL)
    HAS_BOTO = True
except ImportError:
    HAS_BOTO = False

# Import Salt libs
from salt.ext.six import string_types
import salt.utils.odict as odict


__virtualname__ = 'boto_elb_ssl_certificate'


def __virtual__():
    '''
    Only load if boto libraries exist.
    '''
    if not HAS_BOTO:
        return (False, "The boto_elb module cannot be loaded: boto library not found")
    __utils__['boto.assign_funcs'](__name__, 'elb', module='ec2.elb', pack=__salt__)
    return True


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
