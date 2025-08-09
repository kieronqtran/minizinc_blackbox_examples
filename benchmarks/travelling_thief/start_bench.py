from datetime import timedelta
from pathlib import Path
from dotenv import load_dotenv
import minizinc
import os
import shutil

from mzn_bench import Configuration, schedule

load_dotenv()

driver = minizinc.Driver.find([os.getenv("MINIZINC_PATH", default=shutil.which("minizinc"))])

schedule(
    instances=Path("./instances.csv"),
    timeout=timedelta(minutes=int(os.getenv("TIMEOUT_MIN", default=15))),

    configurations=[
        Configuration(name="Gecode_BB", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"Case": "BlackBox"}),
        Configuration(name="Gecode_Decomp", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"Case": "Tabular"}),
    ],
)