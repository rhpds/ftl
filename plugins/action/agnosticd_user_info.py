#!/usr/bin/python
# Copyright: (c) 2020, Johnathan Kupferer <jkupfere@redhat.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import json
import yaml
import os

yaml.SafeDumper.yaml_representers[None] = lambda self, data: \
    yaml.representer.SafeRepresenter.represent_str(self, str(data))

from ansible.plugins.action import ActionBase
try:
    from ansible.template import trust_as_template
except Exception:
    trust_as_template = lambda x: x

class ActionModule(ActionBase):
    '''Print statements during execution and save user info to file'''

    TRANSFERS_FILES = False
    _VALID_ARGS = frozenset(('msg','data','user','body'))

    def run(self, tmp=None, task_vars=None):
        self._supports_check_mode = True

        if task_vars is None:
            task_vars = dict()

        result = super(ActionModule, self).run(tmp, task_vars)
        result['_ansible_verbose_always'] = True
        del tmp

        msg = self._task.args.get('msg')
        body = self._task.args.get('body')
        data = self._task.args.get('data', {})
        user = self._task.args.get('user')

        if msg and body:
            result['failed'] = True
            result['error'] = 'msg and body are mutually exclusive'
            return result

        if msg != None:
            if user:
                result['msg'] = msg
            else:
                if isinstance(msg, list):
                    result['msg'] = ['user.info: ' + m for m in msg]
                else:
                    result['msg'] = 'user.info: ' + msg

        if not user and body != None:
            result['msg'] = 'user.body: ' + body

        if data:
            result['data'] = data
            if not isinstance(data, dict):
                result['failed'] = True
                result['error'] = 'data must be a dictionary of name/value pairs'
                return result

        if user:
            result['user'] = user

        try:
            _action_expr = '{{ ACTION | default(hostvars.localhost.ACTION) | default("provision", true) }}'
            action = self._templar.template(trust_as_template(_action_expr))

            _out_expr = '{{ output_dir | default(hostvars.localhost.output_dir, true) | default(playbook_dir, true) | default(".", true) }}'
            output_dir = self._templar.template(trust_as_template(_out_expr))

            try:
                os.makedirs(output_dir)
            except OSError:
                pass

            if not user and msg != None:
                with open(os.path.join(output_dir, f'{action}-user-info.yaml'), 'a') as fh:
                    if isinstance(msg, list):
                        for m in msg:
                            fh.write('- ' + json.dumps(m) + "\n")
                    else:
                        fh.write('- ' + json.dumps(msg) + "\n")

            if not user and body != None:
                with open(os.path.join(output_dir, f'{action}-user-body.yaml'), 'a') as fh:
                    fh.write('- ' + json.dumps(body) + "\n")

            if data or user:
                data = json.loads(json.dumps(data))
                user_data = None
                try:
                    with open(os.path.join(output_dir, f'{action}-user-data.yaml'), 'r') as fh:
                        user_data = yaml.safe_load(fh) or {}
                except FileNotFoundError:
                    pass

                if user_data == None:
                    user_data = {}

                if user:
                    if 'users' not in user_data:
                        user_data['users'] = {}
                    if user in user_data['users']:
                        user_data_item = user_data['users'][user]
                        user_data_item.update(data)
                    else:
                        user_data_item = data
                        user_data['users'][user] = user_data_item
                    if msg:
                        msg_str = "\n".join(msg) if isinstance(msg, list) else msg
                        if 'msg' in user_data_item:
                            user_data_item['msg'] += "\n" + msg_str
                        else:
                            user_data_item['msg'] = msg_str
                    if body:
                        if 'body' in user_data_item:
                            user_data_item['body'] += "\n" + body
                        else:
                            user_data_item['body'] = body
                else:
                    user_data.update(data)

                with open(os.path.join(output_dir, f'{action}-user-data.yaml'), 'w') as fh:
                    yaml.safe_dump(user_data, stream=fh, explicit_start=True)

            result['failed'] = False
        except Exception as e:
            result['failed'] = True
            result['error'] = str(e)

        return result
