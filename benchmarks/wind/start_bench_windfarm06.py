#%%
from datetime import timedelta
from pathlib import Path
from dotenv import load_dotenv
from minizinc import Driver, Solver
import os
import shutil
from itertools import product

from mzn_bench import Configuration, schedule

load_dotenv()

#%%
driver = Driver(Path(os.getenv("MINIZINC_PATH", default=shutil.which("minizinc"))))
current_dir = Path(__file__).parent
#%%
schedule(
    instances=Path("./instances.csv"),
    timeout=timedelta(minutes=int(os.getenv("TIMEOUT_MIN", default=15))),
    configurations=[
        Configuration(name=f"Gecode_Windfarm06_{i}_{j}",
                      solver=Solver.lookup("gecode", driver=driver),
                      other_flags={
                        "--param-file": str(current_dir / "models" / "configs" / "gecode_bb.mpc"),
                        "--restart-scale": j,
                        "--restart": "constant",
                      },
                      extra_data={
                        "initTemp": 10000,
                        "coolingRate": j,
                      }
        )
        for i, j in product(range(0.005, 1, 0.005), [1] + list(range(25, 251, 25)))
    ],
)