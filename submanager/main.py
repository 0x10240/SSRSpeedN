import json
import os
import subprocess
import yaml
import re
from loguru import logger

import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from ssrspeed.parser.parser import UniversalParser

current_dir = os.path.abspath(os.path.dirname(__file__))


class SubscriptionManager(object):
    def __init__(self, url):
        self.url = url
        self.project_dir = "/root/pycharm_projects/SSRSpeedN1/ssrspeed"
        self.parser = UniversalParser()
        self.result_path = ''

    def on_loss_detected(self, line):
        print(f"Detected Loss: {line}")
        # 这里可以添加其他处理 Loss 的逻辑

    def on_result_exported(self, line):
        print(f"Detected Result Export: {line}")
        # 这里调用你需要的处理函数
        match = re.search(r'Result exported as (/.+\.json)', line)
        if match:
            self.result_path = match.group(1)

    def get_result_path(self):
        if not self.result_path:
            result_dir = os.path.join(self.project_dir, "data/results")
            for filename in sorted(os.listdir(result_dir), reverse=True):
                if filename.endswith(".json"):
                    self.result_path = os.path.join(result_dir, filename)
                    break
        return self.result_path

    def load_speedtest_result(self, path):
        ret = {}

        with open(path, "r") as f:
            data = json.load(f)

        for item in data:
            if item['loss'] > 0.5:
                logger.info(f'node {item.get("remarks")} loss: {item.get("loss")}, drop it')
                continue
            ret[item.get("remarks")] = item

        return ret

    def get_nodes(self):
        nodes = self.parser.read_subscription(self.url.split())
        return nodes

    def subscribe_speed_test(self):
        os.chdir(self.project_dir)
        ssr_speed_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../ssrspeed/main.py'))

        cmd = f"/root/.virtualenvs/SSRSpeedN1/bin/python {ssr_speed_path} -u '{self.url}' --mode pingonly --sort ping --skip-requirements-check --exclude '美国' --exclude 'US'"
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        for line in process.stdout:
            line = line.strip()
            if "Loss:" in line:
                self.on_loss_detected(line)
            if "Result exported" in line:
                self.on_result_exported(line)

        process.stdout.close()
        process.wait()

    def generate_docker_compose(self, start_port, output_file='docker-compose.yml'):
        subscribe_nodes = self.get_nodes()
        speedtest_nodes = self.load_speedtest_result(self.get_result_path())

        nodes = []
        for node in subscribe_nodes:
            remarks = node.config.get('remarks')
            speed = speedtest_nodes.get(remarks)
            if not speed:
                continue
            setattr(node, 'speed', speed)
            nodes.append(node)

        nodes.sort(key=lambda node: node.speed['gPing'])

        docker_compose_dict = {
            'services': {}
        }

        local_port = start_port
        for node in nodes:
            config_file = os.path.realpath(os.path.join(current_dir, f'./configs/config_{local_port}.json'))
            config = node.config

            if node.node_type == 'Trojan':
                config.pop('local_address')
                config.update({'local_addr': '0.0.0.0', 'local_port': local_port})
                # config["ssl"]["verify"] = False
            elif node.node_type == 'Vmess':
                config.pop('local_address', '')
                config.pop('local_port', '')
                config["inbounds"][0]["listen"] = '0.0.0.0'
                config["inbounds"][0]["port"] = local_port
            elif node.node_type == 'Hysteria2':
                config['socks5']['listen'] = f'0.0.0.0:{local_port}'
            else:
                config.update({'local_address': '0.0.0.0', 'local_port': local_port})

            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=4, ensure_ascii=False)

            if node.node_type == 'Shadowsocks':
                service = {
                    'container_name': f'ss-{local_port}',
                    'restart': 'always',
                    'ports': [
                        f"{local_port}:{local_port}/tcp",
                        f"{local_port}:{local_port}/udp"
                    ],
                    'volumes': [
                        {
                            'type': "bind",
                            'bind': {'propagation': "rprivate"},
                            'source': f"{config_file}",
                            'target': '/etc/shadowsocks/config.json'
                        }
                    ],
                    'image': 'ss-local'
                }
            elif node.node_type == 'Trojan':
                service = {
                    'container_name': f'trajon-{local_port}',
                    'restart': 'always',
                    'ports': [
                        f"{local_port}:{local_port}/tcp",
                        f"{local_port}:{local_port}/udp"
                    ],
                    'volumes': [
                        {
                            'type': "bind",
                            'bind': {'propagation': "rprivate"},
                            'source': f"{config_file}",
                            'target': '/etc/trojan/config.json'
                        }
                    ],
                    'image': 'teddysun/trojan'
                }
            elif node.node_type == 'Vmess':
                service = {
                    'container_name': f'v2ray-{local_port}',
                    'restart': 'always',
                    'ports': [
                        f"{local_port}:{local_port}/tcp",
                        f"{local_port}:{local_port}/udp"
                    ],
                    'volumes': [
                        {
                            'type': "bind",
                            'bind': {'propagation': "rprivate"},
                            'source': f"{config_file}",
                            'target': '/etc/v2ray/config.json'
                        }
                    ],
                    'image': 'v2fly/v2fly-core',
                    'command': 'run -c /etc/v2ray/config.json'
                }
            elif node.node_type == 'Hysteria2':
                service = {
                    'container_name': f'hy2-{local_port}',
                    'restart': 'always',
                    'ports': [
                        f"{local_port}:{local_port}/tcp",
                        f"{local_port}:{local_port}/udp"
                    ],
                    'volumes': [
                        {
                            'type': "bind",
                            'bind': {'propagation': "rprivate"},
                            'source': f"{config_file}",
                            'target': '/etc/hysteria.json'
                        }
                    ],
                    'image': 'tobyxdd/hysteria',
                    'command': '-c /etc/hysteria.json'
                }
            else:
                logger.warning(f'unsupported node type: {node.node_type}')
                continue

            key = f'{local_port}'
            docker_compose_dict['services'][key] = service
            local_port += 1
            logger.info(f'node: {key} {node.config.get("remarks")} config file: {config_file}')

        # 将字典转换为YAML并写入文件
        with open(os.path.join(current_dir, output_file), 'w', encoding='utf-8') as file:
            yaml.dump(docker_compose_dict, file, default_flow_style=False, sort_keys=False)


if __name__ == '__main__':
    url = ""
    s = SubscriptionManager(url)
    s.subscribe_speed_test()
    output_file = 'docker-compose-huachoud.yml'
    start_port = 30001
    s.generate_docker_compose(start_port, output_file)
