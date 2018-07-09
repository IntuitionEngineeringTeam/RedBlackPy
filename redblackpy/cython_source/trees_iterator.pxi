#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

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
        void set_iterator[Iterable](const Iterable&, string)
        bool empty()
        node_type& operator*()
        trees_iterator& operator++()
        trees_iterator& operator--()
        trees_iterator& operator=()
        bool operator==(const trees_iterator&)
        bool operator!=(const trees_iterator&)