import subprocess
import sys
from pathlib import Path
import toml

streamlit_file = "browser_ui.py"
STREAMLIT_APP = Path(
    streamlit_file
)

STREAMLIT_CONFIG = (
    Path.home()
    / ".streamlit"
    / "config.toml"
)


def configure_streamlit():

    config_dir = Path(".streamlit")
    config_dir.mkdir(exist_ok=True)

    config_file = config_dir / "config.toml"

    try:
        config = (
            toml.load(config_file)
            if config_file.exists()
            else {}
        )
    except Exception:
        config = {}

    config.setdefault("browser", {})
    config.setdefault("client", {})

    config["browser"]["gatherUsageStats"] = False
    config["client"]["showErrorDetails"] = False
    config["client"]["toolbarMode"] = "minimal"

    with open(config_file, "w", encoding="utf-8") as f:
        toml.dump(config, f)


def run_app():

    return subprocess.Popen(
        [
            sys.executable,
            "-m",
            "streamlit",
            "run",
            str(STREAMLIT_APP)
        ]
    )


if __name__ == "__main__":

    configure_streamlit()

    process = run_app()

    print(
        f"Inventory Agent UI started "
        f"(PID={process.pid})"
    )