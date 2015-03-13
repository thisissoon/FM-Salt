#!/usr/bin/env python
# encoding: utf-8

"""
FM States
=========
"""


def stop_container_if_old(name, container_id, image, tag='latest', timeout=30):
    """ Stops a container if the image its running is out of date.

    Arguments
    ----------
    container_id : str
        The docker container id
    image : str
        The docker image name
    tag : str
        The docker image tag
    """

    ret = {
        'name': name,
        'result': True,
        'changes': {}
    }

    container_info = __salt__['docker.inspect_container'](container_id)
    image_info = __salt__['docker.inspect_image'](image + ':' + tag)

    # If the container image iD does not match the image ID then its out
    # of date so we need to stop the container

    if not type(container_info['out']) == dict:
        ret['comment'] = 'Container {0} not running'.format(container_id)
        return ret

    if not type(image_info['out']) == dict:
        ret['comment'] = 'Image {0} does not exist'.format(container_id)
        return ret

    if not container_info['out']['Image'] == image_info['out']['Id']:
        stop = __salt__['docker.stop'](container_id, timeout=timeout)
        ret['comment'] = stop['comment']
        ret['result'] = stop['status']
        ret['changes'] = {
            'container_stopped': container_id
        }
    else:
        ret['comment'] = 'Container is running latest image'

    return ret


def remove_container_if_old(
        name,
        container_id,
        image,
        tag='latest',
        timeout=30):
    """ Removes a container.
    """

    ret = {
        'name': name,
        'result': True,
        'changes': {}
    }

    # Try and stop the container - may not already be running
    stop_container = stop_container_if_old(
        name,
        container_id,
        image,
        tag,
        timeout)

    if stop_container['changes']:
        remove = __salt__['docker.remove_container'](container_id)
        ret['comment'] = remove['comment']
        ret['result'] = remove['status']
        ret['changes'] = {
            'container_removed': container_id
        }
    else:
        ret['comment'] = 'Container is running latest image or does not exist'

    return ret


def cleanup_docker_images(name):
    """ Cleanup docker images based on current running containers, their image
    ids and litsts of images in docker. Remove images when are NOT being used
    by containers.
    """

    ret = {
        'name': name,
        'result': True,
        'comment': 'No images removed',
        'changes': {}
    }

    images = __salt__['docker.get_images'](all=False)
    containers = __salt__['docker.get_containers'](inspect=True)

    image_ids = [i['Id'] for i in images['out']]
    container_image_ids = [c['detail']['Image'] for c in containers['out']]

    removed = []

    for image in image_ids:
        if image not in container_image_ids:
            remove_image = __salt__['docker.remove_image'](image)
            if remove_image['status']:
                removed.append(image)

    if len(removed) > 0:
        ret['comment'] = 'Removed unused images'
        ret['changes'] = {image: 'Removed' for image in removed}

    return ret
