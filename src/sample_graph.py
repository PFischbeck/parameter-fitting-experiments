import csv
import argparse
from pathlib import Path
import sys

from models import *
from parameters import *


class GraphSampler():
    def __init__(self, param_dict, model_class, seed: int | None, output_file):
        self.param_dict = param_dict
        self.model_class = model_class
        self.seed = seed
        self.output_file = Path(output_file)
        self.output_file.parent.mkdir(parents=True, exist_ok=True)

        networkit.engineering.setNumberOfThreads(1)

    def execute(self):
        params = []
        for input_param_class in self.model_class.input_parameters():
            params.append(input_param_class(
                self.param_dict[input_param_class.name()]))

        generator = self.model_class(*params, seed=self.seed)
        g = generator.generate()

        networkit.writeGraph(g, str(output_file),
                             networkit.Format.NetworkitBinary)

        output = {}
        output.update(self.param_dict)
        output["graph"] = self.output_file.stem
        fieldnames = sorted(set(output.keys()))
        dict_writer = csv.DictWriter(sys.stdout, fieldnames)
        dict_writer.writeheader()
        dict_writer.writerow(output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    # parser.add_argument('input_file', type=str)
    model_choices = {model.name().lower(): model for model in ALL_MODELS}
    parser.add_argument('--model', type=str.lower,
                        choices=model_choices.keys(), required=True)
    parser.add_argument('--seed', required=False, type=int)
    parser.add_argument('--input_file', type=str)
    parser.add_argument('--output_file', type=str)

    args, unknown = parser.parse_known_args()
    input_file = args.input_file
    output_file = args.output_file
    seed = args.seed

    # input_file = args.input_file
    model_class = model_choices[args.model]

    model_param_parser = argparse.ArgumentParser()
    for param_class in model_class.input_parameters():
        model_param_parser.add_argument(
            f'--{param_class.name()}', type=str)
    model_args = model_param_parser.parse_args(unknown)

    if input_file is not None:
        with open(input_file, "r") as input_dicts_file:
            param_dict = list(csv.DictReader(input_dicts_file))[0]
    else:
        param_dict = vars(model_args)

    runner = GraphSampler(param_dict, model_class, seed, output_file)
    runner.execute()
