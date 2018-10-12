#!/bin/sh
/sbin/setuser app bundle exec rake mysql:max_allowed_packet
