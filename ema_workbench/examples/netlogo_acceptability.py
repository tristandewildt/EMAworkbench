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

    model = NetLogoModel('Netlogo', 
                          wd="./models/capabilityapproach", 
                          model_file="Model cap approach.nlogo")
    model.run_length = 100
    model.replications = 2
    
    model.uncertainties = [RealParameter('clustering-resources', 0, 1),
                           RealParameter('clustering-PCFs', 0, 1),
                           RealParameter('clustering-SCFs', 0, 1),
                           RealParameter('clustering-ECFs', 0, 1),
                           RealParameter('width-distributions-resources', 0, 1),
                           #RealParameter('width-distributions-PCFs', 0, 1),
                           RealParameter('width-distributions-SCFs', 0, 1),
                           RealParameter('width-distributions-ECFs', 0, 1),
                           RealParameter('social-network-size', 2, 8),
                           RealParameter('network-ratio', 0, 1)
                     ]
    
    model.outcomes = [TimeSeriesOutcome('level-of-achievability'),
                      TimeSeriesOutcome('personal-conversion-factor-shortage'),
                      TimeSeriesOutcome('social-conversion-factor-shortage'),
                      TimeSeriesOutcome('environmental-conversion-factor-shortage'),
                      TimeSeriesOutcome('TIME')]
     
    #perform experiments
    n = 100
    
    with MultiprocessingEvaluator(model) as evaluator:
        #results = evaluator.perform_experiments(scenarios=500)
        results = perform_experiments(model, n, evaluator=evaluator)
        
   
    fn = r'./data/{}_runs_cap_approach.tar.gz'.format(n)
    save_results(results, fn)
    
  
    
    

    print "finish"