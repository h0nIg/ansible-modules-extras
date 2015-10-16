#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright 2015, Hans-Joachim Kliemeck <git@kliemeck.de>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_service_configure
version_added: "2.0"
short_description: Configures Windows services
description:
    - Configures Windows services
options:
  name:
    description:
      - Name of the service
    required: true
    default: null
  start_mode:
    description:
      - Set the startup type for the service
    required: false
    choices:
      - auto
      - manual
      - disabled
  state:
    description:
      - Indicates the desired service state
    required: false
    choices:
      - present
      - absent
    default: present
  path:
    description:
      - Path to be used for service startup. Required if state is present.
    required: false
  display_name:
    description:
      - Name to be used for service list.
    required: false
    default: name
  description:
    description:
      - Description to be used for service list
    required: false
  user:
    description:
      - User to be used for service startup. Required if state is present.
    required: false
  password:
    description:
      - Password to be used for service startup
    required: false
  start_mode:
    description:
      - If C(auto) is selected, the service will start at bootup. C(manual) means that the service will start only when another service needs it. C(disabled) means that the service will stay off, regardless if it is needed or not.
    required: false
    choices:
      - auto
      - manual
      - disabled
    default: auto
author: Hans-Joachim Kliemeck
'''

EXAMPLES = '''
# Playbook example
# Add new Apache service
---
- name: Add Apache service
  win_service_configure:
    name: apache
    path: 'C:\\apache\\bin\\httpd.exe'
    user: apache
    password: secret
    start_mode: manual

# Remove previously added service
- name: Remove Apache service
    name: 'apache'
    state: 'absent'

# Update not required attributes
- name: 
    name: 'apache'
    description: 'world\'s best html serving service'
    start_mode: auto
'''
