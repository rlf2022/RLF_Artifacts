import shutil
import json
import os
import signal
import subprocess
import csv
import argparse

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dataset', dest='dataset', choices=['D1','D2'], default='D1')
    args = parser.parse_args()
    return args

args = get_args()
dataset = args.dataset

# get main_contract for smartest
def load_leaking_suicidal_info(csv_path):
    leaking_suicidal_dict = dict()
    with open(csv_path,newline='',) as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')
        for i,row in enumerate(spamreader):
            if i == 0:
                key_list = row
            else:
                sol = row[0]
                leaking_suicidal_dict[sol] = dict()
                for j,item in enumerate(row[1:]):
                    leaking_suicidal_dict[sol][key_list[j+1]] = item
            # print(', '.join(row))
    return leaking_suicidal_dict

if dataset == 'D1':
    address_dict = load_leaking_suicidal_info('dataset/D1_labels.csv')
    execution_time = 30*60
elif dataset == 'D2':
    address_dict = load_leaking_suicidal_info('dataset/D2.csv')
    execution_time = 60

main_dir = os.getcwd()

def run(address_list, destination, fuzzer, rl_model, proj_source, mode='test'):
    print(len(address_list))
    if not os.path.exists(destination):
        os.mkdir(destination)
    address_list = list(set(address_list).intersection(set(os.listdir(proj_source))))
    address_list = list(set(address_list)-set([x.split('.')[0] for x in os.listdir(destination)]))
    print(len(address_list))

    for i,address in enumerate(address_list[:]):
        contract_name = address_dict[address]['main_name']
        print(i, address, contract_name)

        ouput_path = f'{destination}'
        # try:
        subprocess.run(f"python3 -m rlf --proj {proj_source}/{address} --contract {contract_name} --fuzzer {fuzzer} --limit {limit} --output_path {ouput_path} --address {address} --mode {mode} --max_episode {max_episode} --reward {reward} --rl_model {rl_model} --execution {execution_path} --bug_rate {bug_rate} --limit_time {execution_time} --detect_bugs ls", shell=True, timeout=limit_time)
        # except Exception as e:
        #     pass

fuzzer = 'reinforcement'
reward = 'cov+bugs'
bug_rate = 0.7

max_episode = 50
limit = 1000000
limit_time = 10+execution_time
destination = f'output/{dataset}'
test_list = list(address_dict.keys())
rl_model = 'model_dqn'
proj_source = f'dataset/{dataset}_preprocessing'

execution_path = './execution.so'
run(test_list, f'{destination}_test', fuzzer=fuzzer,  rl_model=rl_model, proj_source=proj_source, mode='test')

