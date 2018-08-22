#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#
from os.path import dirname, abspath, join
from .series.tree_series import *
from .series.series_iterator import *
from .benchmark.timer import *

__all__ = ['Series', 'SeriesIterator', 'Timer']


def get_include():

	return dirname(abspath(__file__))

