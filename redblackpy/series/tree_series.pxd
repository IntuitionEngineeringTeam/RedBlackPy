#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#


from libcpp cimport bool
from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as inc
from cython.operator cimport postincrement as pinc
from cpython.object cimport Py_LT, Py_EQ
from cpython.ref cimport PyObject, Py_XINCREF, Py_XDECREF
from libc.stdlib cimport malloc, free
from libcpp.unordered_map cimport unordered_map
from libcpp.string cimport string
from libcpp.utility cimport pair
from libcpp.vector cimport vector
from redblackpy.tree_cython_api.types_mapping cimport *
from redblackpy.tree_cython_api cimport tree as tree

import cython
cimport cython


cdef enum RedBlackPyError:
    INT_KEY_ERROR = -1
    EXT_KEY_ERROR = -2
    TYPE_ERROR = -3

#--------------------------------------------------------------------------------------------
# Structure for Python objects handling
#--------------------------------------------------------------------------------------------
cdef extern from "Python.h":
    int PyObject_RichCompareBool(PyObject* o1, PyObject* o2, int opid)

ctypedef struct c_pyobject:
    PyObject* data

# Typedefs
#--------------------------------------------------------------------------------------------
ctypedef void*                                              void_ptr
ctypedef tree.rb_node_valued[c_pyobject, void_ptr]          rb_node_valued
ctypedef tree.rb_tree[rb_node_valued, c_pyobject]           rb_tree
ctypedef tree.rb_tree[rb_node_valued, c_pyobject]*          rb_tree_ptr
ctypedef rb_node_valued*                                    node_ptr
ctypedef tree.rb_tree[rb_node_valued, c_pyobject].iterator  iterator
#--------------------------------------------------------------------------------------------
cdef c_pyobject to_c_pyobject(object obj)
cdef int compare_func(const c_pyobject& a_1, const c_pyobject& a_2) with gil
cdef int equal(const c_pyobject& a_1, const c_pyobject& a_2) with gil
cdef int comp_pair( const pair[rb_tree_ptr, iterator]& a_1,
                           const pair[rb_tree_ptr, iterator]& a_2 ) with gil
cdef int equal_pair( const pair[rb_tree_ptr, iterator]& a_1,
                            const pair[rb_tree_ptr, iterator]& a_2 ) with gil


#--------------------------------------------------------------------------------------------
# Base series class definition
#--------------------------------------------------------------------------------------------
cdef class __BaseTreeSeries:

    # Attributes
    cdef rb_tree_ptr __index
    cdef node_ptr    __last_call
    cdef bool        __iter_mode

    # Methods
    cpdef bint empty(self)
    cpdef list keys(self)
    cpdef begin(self)
    cpdef end(self)
    cpdef void on_itermode(self)
    cpdef void off_itermode(self)
    cdef rb_tree_ptr get_tree(self)
    cdef inline node_ptr link(self)
    cdef __get_key_from_ptr(self, node_ptr node)
    cdef __get_key_from_iter(self, iterator node)


#--------------------------------------------------------------------------------------------
# Series class definition
#--------------------------------------------------------------------------------------------
cdef class Series:

    # Attributes
    cdef __BaseTreeSeries dtype_series
    cdef public   str name
    cdef readonly str dtype

    # Methods
    cpdef void insert(self, key, value) except*
    cpdef void insert_range(self, pairs) except*
    cpdef void erase(self, key) except*
    cpdef begin(self)
    cpdef end(self)
    cdef rb_tree_ptr get_tree(self)
    cpdef list index(self)
    cpdef list values(self)
    cpdef list items(self)
    cpdef tuple floor(self, key)
    cpdef tuple ceil(self, key)
    cpdef Series truncate(self, start, stop)
    cpdef map(self, method, bint inplace=*, tuple args=*, dict kwargs=*)
    cpdef void set_interpolation(self, str interpolate)
    cpdef void set_extrapolation(self, extrapolate)
    cpdef void set_arithmetic(self, str arithmetic)
    cpdef void on_itermode(self)
    cpdef void off_itermode(self)
    cpdef void cast_dtype(self, str dtype) except*
    cpdef to_pandas(self)

