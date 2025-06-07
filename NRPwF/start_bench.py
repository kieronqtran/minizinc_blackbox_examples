from datetime import timedelta
from pathlib import Path
from dotenv import load_dotenv
import minizinc
import os
import shutil
import json
from mzn_bench import Configuration, schedule

load_dotenv()

driver = minizinc.Driver.find([os.getenv("MINIZINC_PATH", default=shutil.which("minizinc"))])

current_dir = os.path.dirname(os.path.abspath("__file__"))
workspace_config_filepath = os.path.join(current_dir, 'model_REVERSE.mpc')

gecode_decomp_config = Configuration(name="Gecode_Decomp", solver=minizinc.Solver.lookup("gecode", driver=driver), other_flags={'--json-stream' : workspace_config_filepath}, extra_data={'Case': 'Tabular'})
# gecode_blackbox_config = Configuration(name="Gecode_single_nurse_bb", solver=minizinc.Solver.lookup("gecode", driver=driver), other_flags={'--json-stream' : workspace_config_filepath})

instances = Path("./instances.csv")
output_dir: Path = Path.cwd() / "new_attempt_results_decomp"
output_dir.mkdir(exist_ok=True)
timeout = timedelta(hours=2)
configurations = [
    # gecode_decomp_config,
    # gecode_blackbox_config,
]
schedule(
    instances=instances,
    timeout=timeout,
    output_dir=output_dir,
    configurations=[
        # gecode_blackbox_config,
        gecode_decomp_config,
    ],
)
