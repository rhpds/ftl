#!/usr/bin/python
#
# Copyright: (c) 2020, Johnathan Kupferer <jkupfere@redhat.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: agnosticd_user_info
short_description: Display user information for agnosticd deployment and save in output directory
version_added: "2.9"
description:
- This module provides the capability of displaying user information in agnosticd processing while saving the output as a YAML in the output directory.
options:
  msg:
    description: This is the message or data to display.
  body:
    description: Content body to accompany messages.
  data:
    description: Dictionary of data to store.
  user:
    description: User name if data or message should be set for a particular user.
author:
- Johnathan Kupferer
'''

RETURN = '''
msg:
  description: 'The message or body, prepended by "user.info" or "user.body"'
  type: str
  returned: always
'''

# Module is implemented as an action plugin
