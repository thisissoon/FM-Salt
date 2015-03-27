#!/usr/bin/env python
# encoding: utf-8


def api_env():
    return {
        'C_FORCE_ROOT': True,
        'SERVER_NAME': 'api.thisissoon.fm',
        'GUNICORN_HOST': '0.0.0.0',
        'GUNICORN_PORT': '5000',
        'GUNICORN_WORKERS': '8',
        'FM_SETTINGS_MODULE': 'fm.config.default',
        'REDIS_SERVER_URI': 'redis://redis.thisissoon.fm:6379/',
        'REDIS_DB': '0',
        'REDIS_CHANNEL': 'fm:events',
        'SQLALCHEMY_DATABASE_URI': __pillar__['rds.uri'],
        'GOOGLE_CLIENT_ID': __pillar__['google.client.id'],
        'GOOGLE_CLIENT_SECRET': __pillar__['google.client.secret'],
        'GOOGLE_REDIRECT_URI': 'https://thisissoon.fm/',
        'CORS_ACA_ORIGIN': 'https://thisissoon.fm',
    }
