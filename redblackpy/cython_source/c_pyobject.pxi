#
# Created by Soldoskikh Kirill.
# Copyright © 2018 Intuition. All rights reserved.
#

#--------------------------------------------------------------------------------------------
# Structure for Python objects handling
#--------------------------------------------------------------------------------------------
cdef extern from "Python.h":
    int PyObject_RichCompareBool(PyObject* o1, PyObject* o2, int opid)

ctypedef struct c_pyobject:
    PyObject* data

# Construct c_pyobject
cdef inline c_pyobject to_c_pyobject(object obj):

    cdef c_pyobject result = c_pyobject(<PyObject*>(obj))
    # Increment refernce counter to garbage collector will not free memory.
    Py_XINCREF(result.data)

    return result


# Comparators for c_pyobject. Needs casting to Python objects for comparison.
# Objects have to provides builtin comparison operators.
cdef inline int compare_func(const c_pyobject& a_1, const c_pyobject& a_2) with gil:

    return PyObject_RichCompareBool(a_1.data, a_2.data, Py_LT)
    
cdef inline int equal(const c_pyobject& a_1, const c_pyobject& a_2) with gil:

    return PyObject_RichCompareBool(a_1.data, a_2.data, Py_EQ)

cdef inline int comp_pair( const pair[rb_tree_ptr, iterator]& a_1,
                           const pair[rb_tree_ptr, iterator]& a_2 ) with gil:

    return compare_func( deref( deref(a_1.second) ).key,
                         deref( deref(a_2.second) ).key )


cdef inline int equal_pair( const pair[rb_tree_ptr, iterator]& a_1,
                            const pair[rb_tree_ptr, iterator]& a_2 ) with gil:

    return equal( deref( deref(a_1.second) ).key,
                  deref( deref(a_2.second) ).key )
