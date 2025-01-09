import json
import argparse
import pathlib

if __name__ == "__main__":

    # Set up command line options
    parser = argparse.ArgumentParser(description='Parse config file for building python env')
    parser.add_argument('input', nargs=1, type=pathlib.Path)
    parser.add_argument('--versions', help="print pyhton version(s) to install", default=False, action='store_true')
    parser.add_argument('--description', help="print module description", default=False, action='store_true')
    parser.add_argument('--name', help="print module name", default=False, action='store_true')
    parser.add_argument('--modules', help="print extra modules", default=False, action='store_true')
    parser.add_argument('--urls', help="print extra urls", default=False, action='store_true')
    parser.add_argument('--channels', help="print extra channels", default=False, action='store_true')
    parser.add_argument('--conda', help="print extra conda packages", default=False, action='store_true')

 # parse the input
    args = parser.parse_args()

    try:

        with open(args.input[0], 'r') as file:
            data = json.load(file)

            if args.versions:
                try:
                     print(','.join(data['python versions']))
                except:
                     print("")
            elif args.description:
                try:
                     print(data['description'])
                except:
                     print("")
            elif args.name:
                try:
                     print(data['name'])
                except:
                     print("")
            if args.modules:
                try:
                     print(','.join(data['extra modules']))
                except:
                     print("")
            if args.urls:
                try:
                     tmp = ' --extra-index-url '.join(data['extra-index-urls'])
                     if tmp.strip() != '':
                         tmp = '--extra-index-url ' + tmp
                     print(tmp)
                except:
                     print("")
            if args.channels:
                try:
                     tmp = ' -c '.join(data['extra conda channels'])
                     if tmp.strip() != '':
                         tmp = '-c ' + tmp
                     print(tmp)
                except:
                     print("")
            if args.conda:
                try:
                     print(' '.join(data['conda packages']))
                except:
                     print("")
    except:
        print("")
