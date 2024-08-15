import subprocess
import os
import yaml
import argparse
from dotenv import load_dotenv

# ----------------------------------------
# - Safely restore repository
# ----------------------------------------

def safe_restore():

    os.system(f"git checkout -- rtl/")
    os.system(f"git checkout -- docs/")
    os.system(f"git checkout -- verif/")

# ----------------------------------------
# - Encapsulates docker process
# ----------------------------------------

def main(id : int):

    env_path = os.path.join('harness', f'{id}')
    print(f"Searching for .env file in : {env_path}")

    # Load correct .env file
    load_dotenv(os.path.join(env_path, 'src', '.env'))

    # Identify services from YAML File
    with open(os.path.join(env_path, 'docker-compose.yml'), 'r') as ymlfile:
        docker_config = yaml.safe_load(ymlfile)

    # Access Hash Environment Variable
    hash = os.getenv("HASH")

    if hash != None:

        os.system(f"git checkout {hash} docs/")
        os.system(f"git checkout {hash} rtl/")
        os.system(f"git checkout {hash} verif/")

        print(f"Checkout-out rtl, docs and verif folders to {hash}")

    else:
        raise ValueError("Unable to identify git hash.")

    error = 0

    # ----------------------------------------
    # - Run Docker YML
    # ----------------------------------------

    # Identify services
    services = docker_config['services'].keys()

    try:

        cwd      = os.getcwd()
        cmd      = f"-v {cwd}/rtl:/code/rtl:ro -v {cwd}/verif:/code/verif:ro -v {cwd}/docs/:/code/docs:ro"

        # Run all services for the desired data point
        for i in services:

            print(f"Starting service: {i}...")
            cmd = f"docker compose -f harness/{id}/docker-compose.yml run {cmd} --rm {i}"
            print(cmd)

            result = subprocess.run(cmd.split())
            error += result.returncode

    except:
        safe_restore()
        raise ValueError(f"Unable to safely run all docker tests.")

    # ----------------------------------------
    # - Restore git environment
    # ----------------------------------------

    print(f"Restoring to previous context...")
    safe_restore()

    # ----------------------------------------
    # - Final Report
    # ----------------------------------------

    if (error == 0):
        print(f"Success! All harness ran succesfully for data point {id}!")
    else:
        print(f"Error! At least one harness service failed for data point {id}!")

    return (error != 0)

# ----------------------------------------
# - Command Line Execution
# ----------------------------------------

if __name__ == "__main__":

    # Parse Creation
    parser = argparse.ArgumentParser(description="Exemplo de uso do argparse")

    # Adding arguments
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-i", "--id",       type=int, help="ID of the Issue related to the Harness Data Point.")
    group.add_argument("--all", action="store_true", help="Select all of the harness to run")

    # Arg Parsing
    args = parser.parse_args()

    if args.id is not None:
        main(args.id)

    elif args.all:
        items = os.listdir('harness/')
        ids   = [item for item in items if os.path.isdir(os.path.join('harness', item)) and item.isnumeric()]

        for id in ids:
            main(id)