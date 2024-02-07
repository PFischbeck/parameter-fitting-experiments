import csv
import argparse
from pathlib import Path

from helpers import shrink_to_giant_component

import networkit


class GraphCleaner:
    def __init__(self, input_file: str, output_file: str):
        self.input_file = input_file
        self.output_file = output_file

        networkit.engineering.setNumberOfThreads(1)

    def execute(self):
        g = None
        try:
            g = networkit.readGraph(
                str(self.input_file),
                networkit.Format.EdgeList,
                separator=" ",
                firstNode=0,
                commentPrefix="%",
                continuous=True)
        except Exception as e:
            print(e)
            return None

        if not g:
            print("could not import graph from path", input_file)
            return None

        originally_weighted = g.isWeighted()
        if originally_weighted:
            g = networkit.graphtools.toUnweighted(g)
        g.removeSelfLoops()

        g = shrink_to_giant_component(g)

        networkit.writeGraph(g, str(output_file),
                             networkit.Format.NetworkitBinary)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input_file', type=str)
    parser.add_argument('output_file', type=str)

    args = parser.parse_args()

    input_file = args.input_file
    output_file = args.output_file
    # graph_filter_func = lambda g: 100 <= g.numberOfNodes() <= 2*10**6 and 100 < g.numberOfEdges() <= 2*10**7

    runner = GraphCleaner(input_file, output_file)

    runner.execute()
