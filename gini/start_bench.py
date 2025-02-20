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
    timeout=timedelta(minutes=int(os.getenv("TIMEOUT_MIN", default=10)) ),

    configurations=[
        Configuration(name="Median_Gecode_BB", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -1, "Case": "MedianPeter"}),
        Configuration(name="Median_Gecode_Decomp", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -2, "Case": "MedianPeter"}),
        Configuration(name="MinDis_Gecode_BB", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -1, "Case": "MinDis"}),
        Configuration(name="MinDis_Gecode_Decomp", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -2, "Case": "MinDis"}),
        Configuration(name="MaxEff_Gecode_BB", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -1, "Case": "MaxEff"}),
        Configuration(name="MaxEff_Gecode_Decomp", solver=minizinc.Solver.lookup("gecode", driver=driver), extra_data={"mode": -2, "Case": "MaxEff"}),
    ],
    nodelist=["extra001"]
)
