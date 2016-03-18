# -*- coding: utf-8 -*-

# Import Python Libs
from __future__ import absolute_import

# Import Salt Libs
import hashlib
import re
import time
import salt.utils.dictupdate as dictupdate
import salt.utils.boto
from salt.exceptions import SaltInvocationError
import salt.ext.six as six
import logging


log = logging.getLogger(__name__)


__virtualname__ = 'boto_elb_listener'


def __virtual__():
    '''
    Only load if boto is available.
    '''
    return __virtualname__ if 'boto_elb.exists' in __salt__ else False


def _certificate_exists(
        name,
        certificate_check_limit=5,
        certificate_check_interval=3,
        region=None,
        key=None,
        keyid=None,
        profile=None):
    '''
    Check if a SSL certificate exists.
    '''

    log.info('Checking Certificate Exists: {0}'.format(name))
    log.debug('Variables are : {0}.'.format(locals()))

    for i in range(0, certificate_check_limit):
        log.info('Checking Certificate Exists: {0}'.format(name))
        exists = __salt__['boto_iam.get_server_certificate'](
            name,
            region=region,
            key=key,
            keyid=keyid,
            profile=profile)
        log.debug('Exists: {0}'.format(exists))

        if exists:
            return True

        log.debug('Cert Not Found: Sleeping for {0} seconds...'.format(certificate_check_interval))
        time.sleep(certificate_check_interval)

    return False


def managed(
        name,
        elb,
        elb_port,
        elb_proto,
        instance_port,
        instance_proto,
        account_id=None,  # Optionally required
        certificate_name=None,
        certificate_check_limit=5,  # max 5 checks
        certificate_check_interval=3,  # 3 seconds
        region=None,
        key=None,
        keyid=None,
        profile=None):
    '''
    Ensure a listener exists on an ELB, if one already exists and there are
    changes this will update the existing listener.
    '''

    rtn = {
        'name': name,
        'result': True,
        'comment': 'No changes made',
        'changes': {}
    }

    # Get the ELB
    exists = __salt__['boto_elb.exists'](elb, region=region, key=key, keyid=keyid, profile=profile)
    if not exists:
        rtn['result'] = False
        rtn['comment'] = 'ELB does not exist for given region'
        return rtn

    # Get ELB Config - Includes Listeners
    config = __salt__['boto_elb.get_elb_config'](elb, region=region, key=key, keyid=keyid, profile=profile)
    if not config:  # Empty dict if not found
        rtn['result'] = False
        rtn['comment'] = 'Failed to get ELB config'

    # Listeners are a lists of (elb port, instance port, elb proto, instance proto, cert arn)
    listener = {}
    for l in config['listeners']:
        # Unpack listener details
        _cert_arn = None
        if len(l) == 4:
            _elb_port, _instance_port, _elb_proto, _instance_proto = l
        elif len(l) == 5:
            _elb_port, _instance_port, _elb_proto, _instance_proto, _cert_arn = l
        else:
            rtn['result'] = False
            rtn['comment'] = 'Failed to get listener data'
            return

        if elb_port == _elb_port and instance_port == _instance_port:
            listener = l
            break

    certificate_arn = None
    if certificate_name is not None:
        if account_id is None:
            rtn['result'] = False
            rtn['comment'] = 'You must provide an AWS account ID for managing ELB Listener SSL Certificates'
            return rtn
        certificate_arn = 'arn:aws:iam::{0}:server-certificate/{1}'.format(
            account_id,
            certificate_name)

    # The listener exists
    if listener:
        try:
            current_cert_arn = listener[4]
        except IndexError:
            # Our listener exists and dosn't have an ssl to check, return here
            rtn['comment'] = 'Listener {0} > {1} Exists'.format(elb_port, instance_port)
            return rtn

        if current_cert_arn == certificate_arn:
            # Our listener exists and is using the correct SSL certificate, return here
            rtn['comment'] = 'Listener {0} > {1} using SSL {2} Exists'.format(
                elb_port,
                instance_port,
                certificate_arn)
            return rtn

        # Our certificates differ, so we need to change them, first check if the certificate
        # exists
        exists = _certificate_exists(
            certificate_name,
            certificate_check_limit,
            certificate_check_interval,
            region=region,
            key=key,
            keyid=keyid,
            profile=profile)
        if not exists:
            rtn['result'] = False
            rtn['comment'] = 'Certificate {0} dpes not exist'.format(certificate_name)
            return rtn

        # Sleep here for a few seconds to ensure the certificate propagtes within AWS
        time.sleep(10)
        # Certificate exists, update the listener certificate
        result = __salt__['boto_elb_ssl_certificate.set'](
            elb,
            elb_port,
            certificate_arn,
            region=region,
            key=key,
            keyid=keyid,
            profile=profile)
        if not result:
            rtn['result'] = False
            rtn['comment'] = 'Failed to update {0} listener SSL certificate'.format(elb)
            return rtn

        rtn['comment'] = 'Updated {0} listener SSL certificate'.format(elb)
        rtn['changes']['updated'] = {
            'old': current_cert_arn,
            'new': certificate_arn,
        }
        return rtn

    # Create the listener
    listener = [elb_port, instance_port, elb_proto, instance_proto]
    if certificate_arn is not None:
        # Ensure the certificate exists
        exists = _certificate_exists(
            certificate_name,
            certificate_check_limit,
            certificate_check_interval,
            region=region,
            key=key,
            keyid=keyid,
            profile=profile)
        if not exists:
            rtn['result'] = False
            rtn['comment'] = 'Certificate {0} does not exist'.format(certificate_name)
            return rtn
        listener.append(certificate_arn)
        # Sleep here for a few seconds to ensure the certificate propagtes within AWS
        time.sleep(10)

    created = __salt__['boto_elb.create_listeners'](
        elb,
        [listener],
        region=region,
        key=key,
        keyid=keyid,
        profile=profile)
    if not created:
        rtn['result'] = False
        rtn['comment'] = 'Failed to create listener {0} > {1}'.format(elb_port, instance_port)
        return rtn

    # Success!
    rtn['comment'] = 'Created listener listener {0} > {1}'.format(elb_port, instance_port)
    rtn['changes']['created'] = 'Created {0} > {1}'.format(elb_port, instance_port)
    return rtn
