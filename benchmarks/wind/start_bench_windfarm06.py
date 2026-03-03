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
    instances=Path("./instances_windfarm06.csv"),
    timeout=timedelta(minutes=int(os.getenv("TIMEOUT_MIN", default=15))),
    configurations=[
        Configuration(name=f"Gecode_Windfarm06_{per}_{scale}_{thread}",
                      solver=Solver.lookup("gecode", driver=driver),
                      other_flags={
                        "--param-file": str(current_dir / "models" / "configs" / "gecode_bb.mpc"),
                        "--restart-scale": scale,
                        "--restart": "constant",
                        "--parallel": thread,
                      },
                      extra_data={
                        "percentage": per,
                      }
        )
        for per, scale, thread in product([-1] + list(range(75, 100, 5)), [1] + list(range(25, 251, 25), range(1, 10)))
    ],
)