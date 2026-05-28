#!/bin/sh

set -e

exec supervisord -c /supervisor/supervisord.conf
