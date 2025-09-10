#!/usr/bin/env python3
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

# Path to config.json relative to the script
SCRIPT_DIR = Path(__file__).resolve().parent
CONFIG_PATH = (SCRIPT_DIR / "../config.json").resolve()

# Files to render (in the current working directory)
FILES_TO_RENDER = ["hosts.ini", "main.tf"]
CWD = Path.cwd()

def main():
    # Load config
    with open(CONFIG_PATH, "r") as f:
        config = json.load(f)

    # Jinja environment: load templates from the current working directory
    env = Environment(
        loader=FileSystemLoader(str(CWD)),
        autoescape=False,
        trim_blocks=True,
        lstrip_blocks=True,
    )

    for filename in FILES_TO_RENDER:
        template = env.get_template(filename)
        rendered = template.render(**config)

        out_path = CWD / filename
        with open(out_path, "w") as f:
            f.write(rendered)

        print(f"Rendered {filename} in {CWD} using config at {CONFIG_PATH}")

if __name__ == "__main__":
    main()
