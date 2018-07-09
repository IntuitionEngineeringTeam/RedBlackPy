#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

# distutils: language=c++
# cython: binding=True
# cython: boundscheck=False
# cython: wraparound=False
# cython: cdivision=True


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
import datetime as dt
import pandas as pd

import cython
cimport cython


# Include base class and time series class with specialized type of value
#--------------------------------------------------------------------------------------------
cdef enum InterpolationError:

    INT_KEY_ERROR = -1
    EXT_KEY_ERROR = -2
    TYPE_ERROR = -3

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
    One of the primary mapping data structure. Provides fast queries: insertion,
    deletion, interpolation with no additional memory use, get item by key, 
    set item by key.
    """

    cdef BaseTreeSeries dtype_series
    cdef public   str name
    cdef readonly str dtype


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
            self.dtype_series = TreeSeries_uint8_t.__new__( TreeSeries_uint8_t, index, 
                                                            values, name, interpolate, 
                                                            extrapolate, arithmetic )

        elif self.dtype == 'uint16':
            self.dtype_series = TreeSeries_uint16_t.__new__( TreeSeries_uint16_t, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic  )

        elif self.dtype == 'uint32':
            self.dtype_series = TreeSeries_uint32_t.__new__( TreeSeries_uint32_t, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic  )

        elif self.dtype == 'uint64':
            self.dtype_series = TreeSeries_uint64_t.__new__( TreeSeries_uint64_t, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic  )

        elif self.dtype == 'uint96':
            self.dtype_series = TreeSeries_uint96_t.__new__( TreeSeries_uint96_t, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic  )

        elif self.dtype == 'uint128':
            self.dtype_series = TreeSeries_uint128_t.__new__( TreeSeries_uint128_t, index, 
                                                              values, name, interpolate, 
                                                              extrapolate, arithmetic  )

        elif self.dtype == 'int8':
            self.dtype_series = TreeSeries_int8_t.__new__( TreeSeries_int8_t, index, 
                                                           values, name, interpolate, 
                                                           extrapolate, arithmetic  )

        elif self.dtype == 'int16':
            self.dtype_series = TreeSeries_int16_t.__new__( TreeSeries_int16_t, index, 
                                                            values, name, interpolate, 
                                                            extrapolate, arithmetic  )

        elif self.dtype == 'int32':
            self.dtype_series = TreeSeries_int32_t.__new__( TreeSeries_int32_t, index, 
                                                            values, name, interpolate, 
                                                            extrapolate, arithmetic  )

        elif self.dtype == 'int64':
            self.dtype_series = TreeSeries_int64_t.__new__( TreeSeries_int64_t, index, 
                                                            values, name, interpolate, 
                                                            extrapolate, arithmetic  )

        elif self.dtype == 'int96':
            self.dtype_series = TreeSeries_int96_t.__new__( TreeSeries_int96_t, index, 
                                                            values, name, interpolate, 
                                                            extrapolate, arithmetic  )

        elif self.dtype == 'int128':
            self.dtype_series = TreeSeries_int128_t.__new__( TreeSeries_int128_t, index, 
                                                             values, name, interpolate, 
                                                             extrapolate, arithmetic  )

        elif self.dtype == 'float32':
            self.dtype_series = TreeSeries_float32_t.__new__( TreeSeries_float32_t, index, 
                                                              values, name, interpolate, 
                                                              extrapolate, arithmetic  )

        elif self.dtype == 'float64':
            self.dtype_series = TreeSeries_float64_t.__new__( TreeSeries_float64_t, index, 
                                                              values, name, interpolate, 
                                                              extrapolate, arithmetic  )

        elif self.dtype == 'float80':
            self.dtype_series = TreeSeries_float80_t.__new__( TreeSeries_float80_t, index, 
                                                              values, name, interpolate, 
                                                              extrapolate, arithmetic  )

        elif self.dtype == 'float96':
            self.dtype_series = TreeSeries_float96_t.__new__( TreeSeries_float96_t, index, 
                                                              values, name, interpolate, 
                                                              extrapolate, arithmetic  )

        elif self.dtype == 'float128':
            self.dtype_series = TreeSeries_float128_t.__new__( TreeSeries_float128_t, index, 
                                                               values, name, interpolate, 
                                                               extrapolate, arithmetic  )

        elif self.dtype == 'object':
            self.dtype_series = TreeSeries_object.__new__( TreeSeries_object, index, 
                                                           values, name, interpolate, 
                                                           extrapolate, arithmetic )

        elif self.dtype == 'str':
            self.dtype_series = TreeSeries_object.__new__( TreeSeries_object, index, 
                                                           values, name, interpolate, 
                                                           extrapolate, arithmetic )

        else:
            raise RuntimeError( "Unsupported data type {:}".format(dtype) )


    def __cinit__(self):
        pass


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


    @cython.embedsignature(True)
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
        return self.dtype_series.ceil()


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
    cpdef void cast_dtype(self, str dtype):
        """
        Cast values to specific dtype.
        """
        self.dtype = dtype

        if self.dtype == 'uint8':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint8_t.__new__( TreeSeries_uint8_t,
                                                                name=self.name,
                                                                interpolate=self.interpolation,
                                                                extrapolate=self.extrapolation,
                                                                arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint8_t.__new__( TreeSeries_uint8_t,
                                                         name=self.name,
                                                         interpolate=self.interpolation,
                                                         extrapolate=self.extrapolation,
                                                         arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series


        if self.dtype == 'uint16':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint16_t.__new__( TreeSeries_uint16_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint16_t.__new__( TreeSeries_uint16_t, 
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'uint32':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint32_t.__new__( TreeSeries_uint32_t, 
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint32_t.__new__( TreeSeries_uint32_t,
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'uint64':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint64_t.__new__( TreeSeries_uint64_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint64_t.__new__( TreeSeries_uint64_t,
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'uint96':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint96_t.__new__( TreeSeries_uint96_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint96_t.__new__( TreeSeries_uint96_t,
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'uint128':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint128_t.__new__( TreeSeries_uint128_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_uint128_t.__new__( TreeSeries_uint128_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'int8':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_int8_t.__new__( TreeSeries_int8_t,
                                                               name=self.name,
                                                               interpolate=self.interpolation,
                                                               extrapolate=self.extrapolation,
                                                               arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int8_t.__new__( TreeSeries_int8_t, 
                                                        name=self.name,
                                                        interpolate=self.interpolation,
                                                        extrapolate=self.extrapolation,
                                                        arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series


        if self.dtype == 'int16':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_uint16_t.__new__( TreeSeries_int16_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int16_t.__new__( TreeSeries_int16_t,
                                                         name=self.name,
                                                         interpolate=self.interpolation,
                                                         extrapolate=self.extrapolation,
                                                         arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'int32':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_int32_t.__new__( TreeSeries_int32_t,
                                                                name=self.name,
                                                                interpolate=self.interpolation,
                                                                extrapolate=self.extrapolation,
                                                                arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int32_t.__new__( TreeSeries_int32_t,
                                                         name=self.name,
                                                         interpolate=self.interpolation,
                                                         extrapolate=self.extrapolation,
                                                         arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'int64':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_int64_t.__new__( TreeSeries_int64_t,
                                                                name=self.name,
                                                                interpolate=self.interpolation,
                                                                extrapolate=self.extrapolation,
                                                                arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int64_t.__new__( TreeSeries_int64_t,
                                                         name=self.name,
                                                         interpolate=self.interpolation,
                                                         extrapolate=self.extrapolation,
                                                         arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'int96':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_int96_t.__new__( TreeSeries_int96_t,
                                                                name=self.name,
                                                                interpolate=self.interpolation,
                                                                extrapolate=self.extrapolation,
                                                                arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int96_t.__new__( TreeSeries_int96_t,
                                                         name=self.name,
                                                         interpolate=self.interpolation,
                                                         extrapolate=self.extrapolation,
                                                         arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'int128':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_int128_t.__new__( TreeSeries_int128_t,
                                                                 name=self.name,
                                                                 interpolate=self.interpolation,
                                                                 extrapolate=self.extrapolation,
                                                                 arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_int128_t.__new__( TreeSeries_int128_t,
                                                          name=self.name,
                                                          interpolate=self.interpolation,
                                                          extrapolate=self.extrapolation,
                                                          arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'float32':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_float32_t.__new__( TreeSeries_float32_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_float32_t.__new__( TreeSeries_float32_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'float64':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_float64_t.__new__( TreeSeries_float64_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_float64_t.__new__( TreeSeries_float64_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'float80':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_float80_t.__new__( TreeSeries_float80_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_float80_t.__new__( TreeSeries_float80_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'float96':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_float96_t.__new__( TreeSeries_float96_t,
                                                                  name=self.name,
                                                                  interpolate=self.interpolation,
                                                                  extrapolate=self.extrapolation,
                                                                  arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_float96_t.__new__( TreeSeries_float96_t,
                                                           name=self.name,
                                                           interpolate=self.interpolation,
                                                           extrapolate=self.extrapolation,
                                                           arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'float128':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_float128_t.__new__( TreeSeries_float128_t,
                                                                   name=self.name,
                                                                   interpolate=self.interpolation,
                                                                   extrapolate=self.extrapolation,
                                                                   arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_float128_t.__new__( TreeSeries_float128_t,
                                                            name=self.name,
                                                            interpolate=self.interpolation,
                                                            extrapolate=self.extrapolation,
                                                            arithmetic=self.arithmetic )
                new_series.copy_data(self.dtype_series)
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'object':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_object.__new__( TreeSeries_object,
                                                               name=self.name,
                                                               interpolate=self.interpolation,
                                                               extrapolate=self.extrapolation,
                                                               arithmetic=self.arithmetic )
            else:
                new_series = TreeSeries_object.__new__( TreeSeries_object,
                                                        name=self.name,
                                                        interpolate=self.interpolation,
                                                        extrapolate=self.extrapolation,
                                                        arithmetic=self.arithmetic )

                new_series.copy_data(self.dtype_series, to_type="object")
                self.dtype_series.clear()
                self.dtype_series = new_series

        if self.dtype == 'str':

            if self.dtype_series is None:
                self.dtype_series = TreeSeries_object.__new__( TreeSeries_object,
                                                               name=self.name,
                                                               interpolate=self.interpolation,
                                                               extrapolate=self.extrapolation,
                                                               arithmetic=self.arithmetic )

            else:
                new_series = TreeSeries_object.__new__( TreeSeries_object, 
                                                        name=self.name,
                                                        interpolate=self.interpolation,
                                                        extrapolate=self.extrapolation,
                                                        arithmetic=self.arithmetic )

                new_series.copy_data(self.dtype_series, to_type="str")
                self.dtype_series.clear()
                self.dtype_series = new_series

    #--------------------------------------------------------------------------------------------
    # Pandas convertations
    #--------------------------------------------------------------------------------------------
    @cython.embedsignature(True)
    cpdef to_pandas(self):
        """
        Convert to pandas.Series.
        """
        return pd.Series( data=self.values(), index=self.index() )


    @cython.embedsignature(True)
    @staticmethod
    def from_pandas( pd_series, str interpolate='floor', extrapolate=0, 
                     str arithmetic='left' ):
        """
        Initialize Series object from pandas.Series.
        """
        cdef Series result = Series( dtype=str(pd_series.dtype), 
                                     interpolate=interpolate,
                                     extrapolate=extrapolate,
                                     arithmetic=arithmetic )
        return result
    #--------------------------------------------------------------------------------------------
    # Special methods
    #--------------------------------------------------------------------------------------------
    def __del__(self):

        self.dtype_series.clear()
        self.dtype_series.__del__()


    def __len__(self):

        return self.dtype_series.__len__()


    def __str__(self):

        return self.dtype_series.__str__()


    def __contains__(self, key):

        return self.dtype_series.__contains__(key)


    def __iter__(self):

        return self.dtype_series.__iter__()


    def __getitem__(self, key):

        return self.dtype_series.__getitem__(key)


    def __setitem__(self, key, value):

        self.dtype_series.__setitem__(key, value)

    #-------------------------------------------------------------------------------------------------
    # Emulating numeric types
    #-------------------------------------------------------------------------------------------------
    def __add__(self, Series other):

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
