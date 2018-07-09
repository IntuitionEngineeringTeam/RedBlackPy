#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

# distutils: language=c++
from libcpp cimport bool
from libcpp.pair cimport pair
from libcpp.string cimport string


#--------------------------------------------------------------------------------------------
# Extern node template class
#--------------------------------------------------------------------------------------------
cdef extern from "<core/tree/tree.hpp>" namespace "qseries" nogil:

    cdef cppclass rb_node[key_type]:

        cppclass iterator:
            rb_node operator*()
            iterator operator++()
            bint operator==(iterator)
            bint operator!=(iterator)

        rb_node()
        rb_node(const rb_node&)
        rb_node(const key_type&) except +
        rb_node* left
        rb_node* right
        rb_node* parent
        key_type key
        iterator it_position

        rb_node& operator=(const rb_node& other)

#--------------------------------------------------------------------------------------------
# Extern node with value template class
#--------------------------------------------------------------------------------------------
cdef extern from "<core/tree/tree.hpp>" namespace "qseries" nogil:

    cdef cppclass rb_node_valued[key_type, val_type]:

        cppclass iterator:
            rb_node_valued* operator*()
            iterator operator++()
            bint operator==(iterator)
            bint operator!=(iterator)

        rb_node_valued()
        rb_node_valued(const rb_node&)
        rb_node_valued(const key_type&, const val_type&) except +
        rb_node_valued* left
        rb_node_valued* right
        rb_node_valued* parent
        key_type key
        val_type value
        iterator it_position

        rb_node_valued& operator=(const rb_node_valued& other)

#--------------------------------------------------------------------------------------------
# Extern red-black tree template class
#--------------------------------------------------------------------------------------------
cdef extern from "<core/tree/tree.hpp>" namespace "qseries" nogil:

    cdef cppclass rb_tree[node_type, key_type, alloc_type = *]:

        cppclass iterator:
            node_type* operator*()
            iterator operator++()
            bint operator==(iterator)
            bint operator!=(iterator)

        cppclass const_iterator:
            const node_type* operator*()
            const_iterator operator++()
            bint operator==(const_iterator)
            bint operator!=(const_iterator)

        ctypedef node_type* node_ptr
        ctypedef int (*key_compare)(const key_type&, const key_type&)

        rb_tree()
        rb_tree(const rb_tree&)
        size_t size()
        void clear()
        iterator begin()
        iterator end()
        iterator back()
        const_iterator cbegin()
        const_iterator cend()
        node_ptr insert(const key_type&) except +KeyError
        node_ptr insert(const node_type&) except +KeyError
        node_ptr insert(node_ptr&, const node_type&) except +KeyError
        node_ptr insert_search(const key_type&) except +RuntimeError
        void erase(const key_type&) except +KeyError 
        void erase(node_ptr) except +KeyError 
        node_ptr root()
        node_ptr link()
        node_ptr search(const key_type&) except +RuntimeError 
        pair[node_ptr, node_ptr] linear_search_from(node_type*, const key_type&) except +RuntimeError 
        pair[node_ptr, node_ptr] tree_search(const key_type&) except +RuntimeError
        void set_compare(key_compare)
        void set_equal(key_compare)

        rb_tree& operator=(const rb_tree& other)
