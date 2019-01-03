#
#  Created by Soldoskikh Kirill.
#  Copyright 2018 Intuition. All rights reserved.
#

import os
import platform
from setuptools import setup
from setuptools.command.build_ext import build_ext
from distutils.extension import Extension
from Cython.Build import cythonize
from rbp_setup_tools.code_generation import generate_from_cython_src
from rbp_setup_tools.types import TYPES


if platform.system() == 'Darwin':

    compile_opts = [ '-std=c++11', 
                     '-mmacosx-version-min={:}'.format( platform.mac_ver()[0] ),
                     '-Ofast' ]

elif platform.system() == 'Linux':

    compile_opts = [ '-std=c++11',  
                     '-Ofast' ]

elif platform.system() == 'Windows':
    
    compile_opts = [ '-std=c++11',  
                     '-Ofast' ]     

else:
    raise EnvironmentError( 'Not supported platform: {plat}'.format(plat=platform.system()) )
#--------------------------------------------------------------------------------------------
# Generate cython code for all supporting types
#--------------------------------------------------------------------------------------------
src_1 = './redblackpy/cython_source/__dtype_tree_processing.pxi'
src_2 = './redblackpy/cython_source/__tree_series_dtype.pxi'
src_3 = './redblackpy/cython_source/__interpolation.pxi'
src_4 = './redblackpy/cython_source/__arithmetic.pxi'

src_1 = open(src_1, 'r')
src_2 = open(src_2, 'r')
src_3 = open(src_3, 'r')
src_4 = open(src_4, 'r')

output_1 = open('./redblackpy/cython_source/dtype_tree_processing.pxi', 'w')
output_2 = open('./redblackpy/cython_source/tree_series_dtype.pxi', 'w')
output_3 = open('./redblackpy/cython_source/interpolation.pxi', 'w')
output_4 = open('./redblackpy/cython_source/arithmetic.pxi', 'w')

generate_from_cython_src(src_1, output_1, TYPES[:-1], 0)
generate_from_cython_src(src_2, output_2, TYPES, 14)
generate_from_cython_src(src_3, output_3, TYPES, 0)
generate_from_cython_src(src_4, output_4, TYPES, 0)

src_1.close()
src_2.close()
src_3.close()
src_4.close()

output_1.close()
output_2.close()
output_3.close()
output_4.close()
#--------------------------------------------------------------------------------------------

ext_modules=[ Extension( "redblackpy.series.tree_series",
                         sources=["redblackpy/series/tree_series.pyx"],
                         extra_compile_args=compile_opts,
                         extra_link_args=compile_opts[:-1],
                         language = "c++",
                         include_dirs=['./redblackpy'],
                         depends=[ 'core/tree/tree.hpp',
                                   'core/tree/rb_tree.tpp'
                                   'core/tree/rb_node.tpp',
                                   'core/tree/rb_node_valued.tpp',
                                   'core/trees_iterator/iterator.hpp',
                                   'core/trees_iterator/iterator.tpp' ], ),

              Extension( "redblackpy.series.series_iterator",
                         sources=["redblackpy/series/series_iterator.pyx"],
                         extra_compile_args=compile_opts,
                         extra_link_args=compile_opts[:-1],
                         language = "c++",
                         include_dirs=['./redblackpy'],
                         depends=[ 'core/tree/tree.hpp',
                                   'core/tree/rb_tree.tpp'
                                   'core/tree/rb_node.tpp',
                                   'core/tree/rb_node_valued.tpp',
                                   'core/trees_iterator/iterator.hpp',
                                   'core/trees_iterator/iterator.tpp' ], ),
              
              Extension( "redblackpy.benchmark.timer",
                         sources=["redblackpy/benchmark/timer.pyx"],
                         extra_compile_args=compile_opts,
                         extra_link_args=compile_opts[:-1],
                         language = "c++",
                         include_dirs=['./redblackpy'] ) ]

setup( name='redblackpy',
       ext_modules = cythonize(ext_modules),
       version='0.1.3.0',
       author='Solodskikh Kirill',
       author_email='hypo@intuition.engineering',
       maintainer='Intuition',
       maintainer_email='dev@intuition.engineering',
       install_requires=['cython'],
       description='Data structures based on red-black trees.',
       url='https://intuitionengineeringteam.github.io/RedBlackPy/',
       download_url='https://github.com/IntuitionEngineeringTeam/RedBlackPy/archive/master.zip',
       zip_safe=False,
       packages=[ 'redblackpy', 'redblackpy.series', 
                  'redblackpy.benchmark', 'redblackpy.tree_cython_api'],
       package_data={'redblackpy.series': ['*.pxd']},
       include_package_data=True,
       license='Apache License 2.0', 
       long_description='RedBlackPy is a light Python library that provides data structures \
       aimed to fast insertion, removal and self sorting to manipulating ordered data in efficient way.\
       The core part of the library had been written on C++ and then was wrapped in Cython. \
       Hope that many would find the primary data structures of this library very handy in working \
       with time series. One of the main feature of this structures is an access by arbitrary \
       key using interpolation, what makes processing of multiple non synchronized time series very simple.\
       All data structures based on red black trees.',
       classifiers = [ 'Programming Language :: Python :: 2.7',
                       'Programming Language :: Python :: 3' ] )
