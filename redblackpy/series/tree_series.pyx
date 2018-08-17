#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

# distutils: language=c++
# cython: boundscheck=False
# cython: wraparound=False
# cython: binding=True
# cython: profile=False
# cython: linetrace=False


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
from ..tree_cython_api.types_mapping cimport *
from ..tree_cython_api cimport tree as tree
import pandas as pd

import cython
cimport cython


# Include base class and time series class with specialized type of value
#--------------------------------------------------------------------------------------------
include "../cython_source/c_pyobject.pxi"
include "../cython_source/trees_iterator.pxi"
include "../cython_source/base_tree_series.pxi"
include "../cython_source/interpolation.pxi"
include "../cython_source/arithmetic.pxi"
include "../cython_source/dtype_tree_processing.pxi"
include "../cython_source/object_tree_processing.pxi"
include "../cython_source/tree_series_dtype.pxi"

#--------------------------------------------------------------------------------------------
# Series based on trees
#--------------------------------------------------------------------------------------------
@cython.embedsignature(True)
cdef class Series:
    """
    Mapping data structure based on red-black trees. Provides fast queries: 
    insertion, deletion, interpolation with no additional memory use, get item by key, 
    set item by key. It able to keep any Python object or specific numeric type as 
    values. Key type have to provide compare operators. This structure is addition to
    pandas.Series. To proccess ordered, dynamic data in efficient way redblackpy.Series 
    is a good choise. It supports main numeric types, has builtin to getitem operator (Series[key]) 
    interpolation methods (floor, ceil, near neighboor, linear, keys only), 
    so we have access at any key even though this key not in index by interpolation 
    (except case of keys only interpolation). It is very usefull in work 
    with time series.
    """
    def __init__( self, object index=None, object values=None, str dtype="float32", 
                  str name="Untitled", str interpolate="floor", extrapolate=0, 
                  str arithmetic="left" ):
        """
        :param iterable index - iterable with arbitrary datetime objects.
        :param iterable values - iterable with arbitrary datetime objects.
        :param string dtype - value type.
        :param string name.
        :param string interpolate - interpolation method.
        """
        self.dtype = dtype
        self.name = name

        if self.dtype == 'uint8':
            self.dtype_series = __TreeSeries_uint8_t.__new__( __TreeSeries_uint8_t, 
                                                              index, values, name, 
                                                              interpolate, extrapolate, 
                                                              arithmetic )

        elif self.dtype == 'uint16':
            self.dtype_series = __TreeSeries_uint16_t.__new__( __TreeSeries_uint16_t, 
                                                               index, values, name, 
                                                               interpolate, extrapolate, 
                                                               arithmetic  )

        elif self.dtype == 'uint32':
            self.dtype_series = __TreeSeries_uint32_t.__new__( __TreeSeries_uint32_t, index, 
                                                               values, name, interpolate, 
                                                               extrapolate, arithmetic  )

        elif self.dtype == 'uint64':
            self.dtype_series = __TreeSeries_uint64_t.__new__( __TreeSeries_uint64_t, index, 
                                                               values, name, interpolate, 
                                                               extrapolate, arithmetic  )

        elif self.dtype == 'uint96':
            self.dtype_series = __TreeSeries_uint96_t.__new__( __TreeSeries_uint96_t, 
                                                               index, values, name, 
                                                               interpolate, extrapolate, 
                                                               arithmetic  )

        elif self.dtype == 'uint128':
            self.dtype_series = __TreeSeries_uint128_t.__new__( __TreeSeries_uint128_t, 
                                                                index, values, name, 
                                                                interpolate, extrapolate, 
                                                                arithmetic  )

        elif self.dtype == 'int8':
            self.dtype_series = __TreeSeries_int8_t.__new__( __TreeSeries_int8_t, 
                                                             index, values, name, 
                                                             interpolate, extrapolate, 
                                                             arithmetic  )

        elif self.dtype == 'int16':
            self.dtype_series = __TreeSeries_int16_t.__new__( __TreeSeries_int16_t, 
                                                              index, values, name, 
                                                              interpolate, extrapolate, 
                                                              arithmetic  )

        elif self.dtype == 'int32':
            self.dtype_series = __TreeSeries_int32_t.__new__( __TreeSeries_int32_t, 
                                                              index, values, name, 
                                                              interpolate, extrapolate, 
                                                              arithmetic  )

        elif self.dtype == 'int64':
            self.dtype_series = __TreeSeries_int64_t.__new__( __TreeSeries_int64_t, 
                                                              index, values, name, 
                                                              interpolate, extrapolate, 
                                                              arithmetic  )

        elif self.dtype == 'int96':
            self.dtype_series = __TreeSeries_int96_t.__new__( __TreeSeries_int96_t, 
                                                              index, values, name, 
                                                              interpolate, extrapolate, 
                                                              arithmetic  )

        elif self.dtype == 'int128':
            self.dtype_series = __TreeSeries_int128_t.__new__( __TreeSeries_int128_t, 
                                                               index, values, name, 
                                                               interpolate, extrapolate, 
                                                               arithmetic  )

        elif self.dtype == 'float32':
            self.dtype_series = __TreeSeries_float32_t.__new__( __TreeSeries_float32_t, 
                                                                index, values, name, 
                                                                interpolate, extrapolate, 
                                                                arithmetic  )

        elif self.dtype == 'float64':
            self.dtype_series = __TreeSeries_float64_t.__new__( __TreeSeries_float64_t, 
                                                                index, values, name, 
                                                                interpolate, extrapolate, 
                                                                arithmetic  )

        elif self.dtype == 'float80':
            self.dtype_series = __TreeSeries_float80_t.__new__( __TreeSeries_float80_t, 
                                                                index, values, name, 
                                                                interpolate, extrapolate, 
                                                                arithmetic  )

        elif self.dtype == 'float96':
            self.dtype_series = __TreeSeries_float96_t.__new__( __TreeSeries_float96_t, 
                                                                index, values, name, 
                                                                interpolate, extrapolate, 
                                                                arithmetic  )

        elif self.dtype == 'float128':
            self.dtype_series = __TreeSeries_float128_t.__new__( __TreeSeries_float128_t, 
                                                                 index, values, name, 
                                                                 interpolate, extrapolate, 
                                                                 arithmetic  )

        elif self.dtype == 'object':
            self.dtype_series = __TreeSeries_object.__new__( __TreeSeries_object, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic )

        elif self.dtype == 'str':
            self.dtype_series = __TreeSeries_object.__new__( __TreeSeries_object, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic )

        else:
            raise TypeError( "Unsupported data type {:}".format(dtype) )


    #--------------------------------------------------------------------------------------------
    # Properties
    #--------------------------------------------------------------------------------------------
    @property
    def interpolation(self):

        return self.dtype_series.interpolate_type


    @interpolation.setter
    def interpolation(self, str interpolation):

        self.set_interpolation(interpolation)


    @property
    def extrapolation(self):

        return self.dtype_series.extrapolate


    @extrapolation.setter
    def extrapolation(self, extrapolation):

        self.set_extrapolation(extrapolation)


    @property
    def arithmetic(self):

        return self.dtype_series.arithmetic


    @arithmetic.setter
    def arithmetic(self, str arithmetic):

        self.set_arithmetic(arithmetic)


    #--------------------------------------------------------------------------------------------
    # Public methods
    #--------------------------------------------------------------------------------------------
    @cython.embedsignature(True)
    cpdef void insert(self, key, value) except*:
        """
        Insert new value at key to series.
        Complexity O(log n).
        """
        self.dtype_series.insert(key, value)


    @cython.embedsignature(True)
    cpdef void insert_range(self, pairs) except*:
        """
        Insert list of tuples (key, value) to series.
        """
        self.dtype_series.insert_range(pairs)


    @cython.embedsignature(True)
    cpdef void erase(self, key) except*:
        """
        Erase element by key.
        Complexity O(log n).
        """
        self.dtype_series.erase(key)


    @cython.embedsignature(True)
    cpdef begin(self):
        """
        Returns first key.
        """
        return self.dtype_series.begin()


    @cython.embedsignature(True)
    cpdef end(self):
        """
        Returns last key.
        """
        return self.dtype_series.end()


    @cython.embedsignature(True)
    cpdef list index(self):
        """
        Returns list of keys.
        """
        return self.dtype_series.keys()


    cdef rb_tree_ptr get_tree(self):
        """
        Returns tree pointer.
        """ 
        return self.dtype_series.get_tree()


    @cython.embedsignature(True)
    cpdef list values(self):
        """
        Returns list of values.
        """        
        return self.dtype_series.values()

    
    @cython.embedsignature(True)
    cpdef list items(self):
        """
        Returns list of tuples(key, value).
        """
        return self.dtype_series.items()


    def iteritems(self):
        """
        Returns generator of tuples(key, value).
        """        
        return self.dtype_series.iteritems()


    @cython.embedsignature(True)
    cpdef tuple floor(self, key):
        """
        Returns tuple (key', value') such that key' <= key 
        and series does not contain key'', key' < key'' <= key.
        """
        return self.dtype_series.floor(key)


    @cython.embedsignature(True)
    cpdef tuple ceil(self, key):
        """
        Returns tuple (key', value') such that key <= key' 
        and series does not contain key'', key <= key'' < key'.
        """ 
        return self.dtype_series.ceil(key)


    @cython.embedsignature(True)
    cpdef Series truncate(self, start, stop):
        """
        Truncation from start until stop.
        """        
        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = self.dtype_series.truncate(start, stop)

        return result


    @cython.embedsignature(True)
    cpdef Series uniform(self, start, stop, step):
        """
        Returns uniform grid Series from start until stop
        with step equals step.
        """        
        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = self.dtype_series.periodic(start, stop, step)

        return result

    
    @cython.embedsignature(True)
    cpdef map(self, method, bint inplace=False, tuple args=(), dict kwargs={}):
        """
        Apply method to each value in series.
        """
        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )
        if inplace:
            self.dtype_series.map_inplace(method, args, kwargs)

        else:
            result.dtype_series = self.dtype_series.map(method, args, kwargs)

            return result 


    @cython.embedsignature(True)
    cpdef void set_interpolation(self, str interpolate):
        """
        Set interpolation type.
        Supports ceil, floor, nn, linear.
        """
        self.dtype_series.set_interpolation(interpolate)


    @cython.embedsignature(True)
    cpdef void set_extrapolation(self, extrapolate):
        """
        Set interpolation type.
        Supports ceil, floor, nn, linear.
        """
        self.dtype_series.extrapolate = extrapolate


    @cython.embedsignature(True)
    cpdef void set_arithmetic(self, str arithmetic):
        """
        Set interpolation type.
        Supports ceil, floor, nn, linear.
        """
        self.dtype_series.set_arithmetic(arithmetic)


    @cython.embedsignature(True)
    cpdef void on_itermode(self):
        """
        Turn on linear search for operator[].
        """
        self.dtype_series.on_itermode()


    @cython.embedsignature(True)
    cpdef void off_itermode(self):
        """
        Turn off linear search for operator[].
        """
        self.dtype_series.off_itermode()


    @cython.embedsignature(True)
    cpdef void cast_dtype(self, str dtype) except*:
        """
        Cast values to specific dtype.
        """
        self.dtype = dtype
        
        if self.dtype == 'uint8':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint8_t.__new__( __TreeSeries_uint8_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint8_t.__new__( __TreeSeries_uint8_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series


        elif self.dtype == 'uint16':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint16_t.__new__( __TreeSeries_uint16_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint16_t.__new__( __TreeSeries_uint16_t, 
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'uint32':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint32_t.__new__( __TreeSeries_uint32_t, 
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint32_t.__new__( __TreeSeries_uint32_t,
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'uint64':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint64_t.__new__( __TreeSeries_uint64_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint64_t.__new__( __TreeSeries_uint64_t,
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'uint96':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint96_t.__new__( __TreeSeries_uint96_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint96_t.__new__( __TreeSeries_uint96_t,
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'uint128':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint128_t.__new__( __TreeSeries_uint128_t,
                                                                    name=self.name,
                                                                    interpolate=self.interpolation,
                                                                    extrapolate=self.extrapolation,
                                                                    arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_uint128_t.__new__( __TreeSeries_uint128_t,
                                                             name=self.name,
                                                             interpolate=self.interpolation,
                                                             extrapolate=self.extrapolation,
                                                             arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'int8':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_int8_t.__new__( __TreeSeries_int8_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int8_t.__new__( __TreeSeries_int8_t, 
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series


        elif self.dtype == 'int16':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_uint16_t.__new__( __TreeSeries_int16_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int16_t.__new__( __TreeSeries_int16_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'int32':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_int32_t.__new__( __TreeSeries_int32_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int32_t.__new__( __TreeSeries_int32_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'int64':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_int64_t.__new__( __TreeSeries_int64_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int64_t.__new__( __TreeSeries_int64_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'int96':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_int96_t.__new__( __TreeSeries_int96_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int96_t.__new__( __TreeSeries_int96_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'int128':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_int128_t.__new__( __TreeSeries_int128_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_int128_t.__new__( __TreeSeries_int128_t,
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'float32':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_float32_t.__new__( __TreeSeries_float32_t,
                                                                    name=self.name,
                                                                    interpolate=self.interpolation,
                                                                    extrapolate=self.extrapolation,
                                                                    arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_float32_t.__new__( __TreeSeries_float32_t,
                                                             name=self.name,
                                                             interpolate=self.interpolation,
                                                             extrapolate=self.extrapolation,
                                                             arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'float64':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_float64_t.__new__( __TreeSeries_float64_t,
                                                                    name=self.name,
                                                                    interpolate=self.interpolation,
                                                                    extrapolate=self.extrapolation,
                                                                    arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_float64_t.__new__( __TreeSeries_float64_t,
                                                             name=self.name,
                                                             interpolate=self.interpolation,
                                                             extrapolate=self.extrapolation,
                                                             arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'float80':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_float80_t.__new__( __TreeSeries_float80_t,
                                                                    name=self.name,
                                                                    interpolate=self.interpolation,
                                                                    extrapolate=self.extrapolation,
                                                                    arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_float80_t.__new__( __TreeSeries_float80_t,
                                                             name=self.name,
                                                             interpolate=self.interpolation,
                                                             extrapolate=self.extrapolation,
                                                             arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'float96':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_float96_t.__new__( __TreeSeries_float96_t,
                                                                    name=self.name,
                                                                    interpolate=self.interpolation,
                                                                    extrapolate=self.extrapolation,
                                                                    arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_float96_t.__new__( __TreeSeries_float96_t,
                                                             name=self.name,
                                                             interpolate=self.interpolation,
                                                             extrapolate=self.extrapolation,
                                                             arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'float128':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_float128_t.__new__( __TreeSeries_float128_t,
                                                                     name=self.name,
                                                                     interpolate=self.interpolation,
                                                                     extrapolate=self.extrapolation,
                                                                     arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_float128_t.__new__( __TreeSeries_float128_t,
                                                              name=self.name,
                                                              interpolate=self.interpolation,
                                                              extrapolate=self.extrapolation,
                                                              arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'object':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_object.__new__( __TreeSeries_object,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )
            else:
                new_series = __TreeSeries_object.__new__( __TreeSeries_object,
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )

                new_series.copy_data(self.dtype_series, to_type="object")
                self.dtype_series.clear()
                self.dtype_series = new_series

        elif self.dtype == 'str':

            if self.dtype_series is None:
                self.dtype_series = __TreeSeries_object.__new__( __TreeSeries_object,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = __TreeSeries_object.__new__( __TreeSeries_object, 
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )

                new_series.copy_data(self.dtype_series, to_type="str")
                self.dtype_series.clear()
                self.dtype_series = new_series

        else:
            raise TypeError( "Unsupported data type {:}".format(dtype) )

        self.dtype = dtype

    #--------------------------------------------------------------------------------------------
    # Pandas convertations
    #--------------------------------------------------------------------------------------------
    @cython.embedsignature(True)
    cpdef to_pandas(self):
        """
        Convert to pandas.Series.
        """
        return pd.Series( data=self.values(), index=self.index() )


    @staticmethod
    def from_pandas( pd_series, str interpolate='floor', extrapolate=0, 
                     str arithmetic='left' ):
        """
        Initialize Series object from pandas.Series.
        """
        cdef Series result = Series( index=pd_series.index,
                                     values=pd_series.data,
                                     dtype=str(pd_series.dtype), 
                                     interpolate=interpolate,
                                     extrapolate=extrapolate,
                                     arithmetic=arithmetic )
        return result
    #--------------------------------------------------------------------------------------------
    # Special methods
    #--------------------------------------------------------------------------------------------
    def __del__(self):

        self.dtype_series.__del__()


    def __len__(self):

        return self.dtype_series.__len__()


    def __str__(self):

        return self.dtype_series.__str__()


    def __repr__(self):

        return self.dtype_series.__str__()


    def __contains__(self, key):

        return self.dtype_series.__contains__(key)


    def __iter__(self):

        return self.dtype_series.__iter__()


    def __getitem__(self, key):

        if not isinstance(key, slice):
            return self.dtype_series.__getitem__(key)

        result = Series( dtype=self.dtype, 
                         interpolate=self.interpolation,
                         extrapolate=self.extrapolation,
                         arithmetic=self.arithmetic )

        (<Series>result).dtype_series = self.dtype_series.__getitem__(key)

        return result


    def __setitem__(self, key, value):

        self.dtype_series.__setitem__(key, value)

    #-------------------------------------------------------------------------------------------------
    # Emulating numeric types
    #-------------------------------------------------------------------------------------------------
    def __add__(self, other):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.add( (<Series?>other).dtype_series )

        return result


    def __sub__(self, Series other):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.sub( (<Series?>other).dtype_series )

        return result


    def __mul__(self, Series other):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.mul( (<Series?>other).dtype_series )

        return result


    def __div__(self, Series other):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.div( (<Series?>other).dtype_series )

        return result


    def __truediv__(self, Series other):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.div( (<Series?>other).dtype_series )

        return result


    def __lshift__(self, shift_param):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.lshift(shift_param)

        return result


    def __rshift__(self, shift_param):

        cdef Series result = Series( dtype=self.dtype, 
                                     interpolate=self.interpolation,
                                     extrapolate=self.extrapolation,
                                     arithmetic=self.arithmetic )

        result.dtype_series = (<Series>self).dtype_series.rshift(shift_param)

        return result       


    #--------------------------------------------------------------------------------------------------
    # Pickle serialization
    #--------------------------------------------------------------------------------------------------
    def __reduce__(self):

        return Series, (), self.__getstate__()


    def __getstate__(self):

        cdef dict state = {}

        state['items']       = self.items()
        state['dtype']       = self.dtype
        state['name']        = self.name
        state['interpolate'] = self.dtype_series.interpolate_type
        state['extrapolate'] = self.dtype_series.extrapolate
        state['arithmetic']  = self.dtype_series.arithmetic

        return state

    
    def __setstate__(self, dict state):

        self.name = state['name']
        self.cast_dtype(state['dtype'])
        self.set_interpolation(state['interpolate'])
        self.set_extrapolation(state['extrapolate'])
        self.set_arithmetic(state['arithmetic'])
        self.insert_range(state['items'])
