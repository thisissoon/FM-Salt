# -*- coding: utf-8 -*-

# Import Python Libs
from __future__ import absolute_import

# Import Salt Libs
import hashlib
import re
import salt.utils.dictupdate as dictupdate
from salt.exceptions import SaltInvocationError
import salt.ext.six as six


__virtualname__ = 'boto_elb_listener'


def __virtual__():
    '''
    Only load if boto is available.
    '''
    return __virtualname__ if 'boto_elb.exists' in __salt__ else False


def managed(
        name,
        elb,
        elb_port,
        elb_proto,
        instance_port,
        instance_porto,
        certificate_arn=None,
        region=None,
        key=None,
        keyid=None,
        profile=None)
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

    # Delete the listener
    if listener:
        delted = __salt__['boto_elb.delete_listeners'](
            elb,
            [elb_port],
            region=region,
            key=key,
            keyid=keyid,
            profile=profile)
        if not deleted:
            rtn['result'] = False
            rtn['comment'] = 'Failed to remove existing listener {0} > {1}'.format(elb_port, instance_port)
            return rtn
        rtn['changes']['removed'] = 'Removed {0} > {1}'.format(elb_port, instance_port)

    # Create the listener
    listener = [elb_proto, instance_porto, elb_port, instance_porto]
    if certificate_arn:
        listener.append(certificate_arn)
    created = __salt__['boto_elb.create_listeners'](
        elb,
        [listener]
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
