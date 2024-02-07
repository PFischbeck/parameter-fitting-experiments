from models import *
from parameters import *
from parameter_fitters import *

model = ErdosRenyi

fitter = RobbinsMonroFinal(
    model, (NumberOfVertices(10000), AverageDegree(2.4)))
fitter.run()
