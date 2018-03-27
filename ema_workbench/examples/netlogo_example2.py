'''
Created on 20 mrt. 2013

@author: localadmin
'''
from __future__ import unicode_literals, absolute_import
import matplotlib.pyplot as plt

from ema_workbench.connectors.netlogo import NetLogoModel

from ema_workbench import (RealParameter, ema_logging,
                           perform_experiments,TimeSeriesOutcome, save_results)
from ema_workbench.em_framework.evaluators import MultiprocessingEvaluator
from ema_workbench.analysis.plotting import lines
from ema_workbench.analysis.plotting_util import BOXPLOT


if __name__ == '__main__':
    #turn on logging
    ema_logging.log_to_stderr(ema_logging.INFO)

    model = NetLogoModel('predprey', 
                          wd="./models/predatorPreyNetlogo", 
                          model_file="Wolf Sheep Predation.nlogo")
    model.run_length = 100
    model.replications = 1
    
    model.uncertainties = [RealParameter("grass-regrowth-time", 1, 99),
                           RealParameter("initial-number-sheep", 1, 200),
                           RealParameter("initial-number-wolves", 1, 200),
                           RealParameter("sheep-reproduce", 1, 20),
                           RealParameter("wolf-reproduce", 1, 20),
                     ]
    
    model.outcomes = [TimeSeriesOutcome('sheep'),
                      TimeSeriesOutcome('wolves'),
                      TimeSeriesOutcome('grass'),
                      TimeSeriesOutcome('TIME') ]
     
    #perform experiments
    n = 10
    
    with MultiprocessingEvaluator(model) as evaluator:
        results = perform_experiments(model, n, evaluator=evaluator)
        
   
    fn = r'./data/{} runs.tar.gz'.format(n)
    save_results(results, fn)
    
    

    print "finish"