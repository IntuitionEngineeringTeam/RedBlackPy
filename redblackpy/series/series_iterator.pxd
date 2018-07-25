#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.utility cimport pair
from tree_series cimport rb_tree_ptr, rb_tree, rb_node_valued, iterator


#--------------------------------------------------------------------------------------------
# Extern trees_iterator template class
#--------------------------------------------------------------------------------------------
cdef extern from "<core/trees_iterator/iterator.hpp>" namespace "qseries" nogil:

    cdef cppclass trees_iterator[tree_type, node_type]:

        # typedef to specific type of arguments
        # cannot extern class typdefs using cython?
        ctypedef int (*key_compare)( const pair[rb_tree_ptr,iterator]&, 
                                     const pair[rb_tree_ptr,iterator]& )

        trees_iterator()

        void set_compare(key_compare)
        void set_equal(key_compare)
        void set_iterator[Iterable](const Iterable&, string) except +TypeError
        bool empty()
        node_type& operator*()
        trees_iterator& operator++()
        trees_iterator& operator--()
        trees_iterator& operator=()
        bool operator==(const trees_iterator&)
        bool operator!=(const trees_iterator&)


#--------------------------------------------------------------------------------------------
# SeriesIterator definition
#--------------------------------------------------------------------------------------------
cdef class SeriesIterator:

    cdef trees_iterator[rb_tree, rb_node_valued] __iterator
    cdef list __series_container

    cdef void __set_iterator(self, str iterator_type) except*
