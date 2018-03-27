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

file_name = r'./data/10 runs.tar.gz'
#file_name = r'./data/1000 flu cases no policy.tar.gz'
experiments, outcomes = load_results(file_name)
results = (experiments, outcomes)

default_flow = 2.178849944502783e7
ooi_name = "sheep"
outcome = outcomes[ooi_name]

outcome = outcome/default_flow

ooi = np.zeros(outcome.shape[0])
temp_outcomes = {ooi_name: ooi}
print ooi.shape


desired__nr_lines = 5
nr_cases = ooi.shape[0]
indices = np.arange(0, nr_cases, nr_cases/desired__nr_lines)

lines(results, outcomes_to_show = 'sheep', density=KDE,
                  show_envelope=True, 
                  experiments_to_show=indices)
                      
        #n = key
        #plt.savefig("./pictures/adopter_category_bounded_no.png".format(key), dpi=75)
plt.show()


print(outcome)




#print(results)



#print(results)


# the plotting functions return the figure and a dict of axes
fig, axes = envelopes(results, group_by='policy', density=KDE, fill=True)

# we can access each of the axes and make changes
for key, value in axes.iteritems():
    # the key is the name of the outcome for the normal plot
    # and the name plus '_density' for the endstate distribution
    if key.endswith('_density'):
        value.set_xscale('log')

plt.show()