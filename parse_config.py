import json
import argparse
import pathlib

if __name__ == "__main__":

    # Set up command line options
    parser = argparse.ArgumentParser(description='Parse config file for building python env')
    parser.add_argument('input', nargs=1, type=pathlib.Path)
    parser.add_argument('--versions', help="print pyhton version(s) to install", default=False, action='store_true')
    parser.add_argument('--description', help="print pyhton version(s) to install", default=False, action='store_true')

    # parse the input
    args = parser.parse_args()

    with open(args.input[0], 'r') as file:
        data = json.load(file)

        if args.versions:
            print(','.join(data['python versions']))
        elif args.description:
           print(data['description'])
