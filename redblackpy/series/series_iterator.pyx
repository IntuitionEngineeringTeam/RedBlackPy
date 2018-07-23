#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

# distutils: language=c++
# cython: boundscheck=False
# cython: wraparound=False
# cython: binding=False

from libcpp cimport bool
from libcpp.utility cimport pair
from cython.operator cimport dereference as deref
from libcpp.vector cimport vector
from libcpp.string cimport string
from cython.operator cimport postincrement as pinc, postdecrement as pdec
from redblackpy.series.tree_series import  Series
from redblackpy.series.tree_series cimport Series
from tree_series cimport rb_tree_ptr, equal_pair, comp_pair, \
                         c_pyobject, rb_tree, rb_node_valued, iterator


import cython
cimport cython

include "../cython_source/trees_iterator.pxi"


#--------------------------------------------------------------------------------------------
# Iterator-generator on multiple Series
#--------------------------------------------------------------------------------------------
@cython.embedsignature(True)
cdef class SeriesIterator:
    """
    Iterator on union of keys of multiple redblackpy.Series objects.
    This iterator does not concatinating keys, i.e. does not use
    additional memory to construct union of keys. SeriesIterator 
    uses only O(n) additional memory, where n is the number of Series,
    to keep n pointers on trees, and generates next key inplace.
    """

    cdef trees_iterator[rb_tree, rb_node_valued] __iterator
    cdef list __series_container


    def __cinit__(self, iterable_series):
        """
        Construct SeriesIterator instance.

        :param iterable_series: container with redblackpy.Series objects.
        """
        self.__iterator.set_equal(equal_pair)
        self.__iterator.set_compare(comp_pair)
        self.__series_container = [series for series in iterable_series]


    def __call__(self, str iterator_type="forward"):
        """
        :param iterator_type: str, forward or reverse. Default is forward.
        """
        self.__set_iterator(iterator_type)

        if iterator_type == "forward":

            while not self.__iterator.empty():
                key = <object>deref(self.__iterator).key.data
                pinc(self.__iterator)

                yield key

        elif iterator_type == "reverse":

            while not self.__iterator.empty():
                key = <object>deref(self.__iterator).key.data
                pdec(self.__iterator)

                yield key

        else:
            raise TypeError("Uknown iterator type")            


    cdef void __set_iterator(self, str iterator_type) except*:

        cdef vector[rb_tree_ptr] trees = vector[rb_tree_ptr]( len(self.__series_container) )
        cdef string c_type = bytearray(iterator_type, 'utf8')
        cdef Py_ssize_t i
        cdef Series current
        
        for i in range( len(self.__series_container) ):
            current = self.__series_container[i]
            trees[i] = current.get_tree()

        self.__iterator.set_iterator(trees, c_type)

