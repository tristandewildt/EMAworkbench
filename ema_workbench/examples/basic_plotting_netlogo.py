'''
Created on Jul 8, 2014

@author: jhkwakkel@tudelft.net
'''
import matplotlib.pyplot as plt
import numpy as np

from ema_workbench import ema_logging, load_results

from ema_workbench.analysis.plotting import envelopes, lines
from ema_workbench.analysis.plotting_util import KDE

ema_logging.log_to_stderr(ema_logging.INFO)


experiments, outcomes = load_results(r'./Data/500_runs_cap_approach.tar.gz')
#results = (experiments, outcomes)

#experiments, outcomes = results
print(experiments.shape) #500 scenarios
print(outcomes['level-of-achievability'].shape)


fig, ax = plt.subplots(1)


ax.plot(outcomes['level-of-achievability'][:,0,:].T)
ax.set_ylabel('Percentage')

fig.set_size_inches(6,6)
plt.show()

np.mean




## the plotting functions return the figure and a dict of axes
#fig, axes = envelopes(results, group_by='policy', density=KDE, fill=True)

## we can access each of the axes and make changes
#for key, value in axes.iteritems():
#    # the key is the name of the outcome for the normal plot
#    # and the name plus '_density' for the endstate distribution
#    if key.endswith('_density'):
#        value.set_xscale('log')

#plt.show()

