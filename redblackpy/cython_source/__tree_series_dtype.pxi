#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

# This file is just a plain text to generate extension class 
# for multiple numeric types. This classes will be used in main wrapper class 
# for TreeSeries to get needed data type in runtime.


#------------------------------------------------------------------------------------------------------
# Series based on trees
#------------------------------------------------------------------------------------------------------
@cython.binding(False)
@cython.internal
cdef class __TreeSeries_{DTYPE}(__BaseTreeSeries):

    cdef interpolate_{DTYPE}     __interpolate
    cdef itermode_search_{DTYPE} __get_item
    cdef arithmetic_type_{DTYPE} __arithmetic

    cdef public   str  name
    cdef public   str  arithmetic
    cdef readonly str  interpolate_type
    cdef public   {DTYPE} extrapolate


    def __init__(self):
        pass


    def __cinit__( self, object index=None, object values=None, str name="Untitled", 
                   str interpolate="floor", {DTYPE} extrapolate=0, str arithmetic="left" ):

        self.set_interpolation(interpolate)
        self.extrapolate = extrapolate
        self.name = name
        self.arithmetic = arithmetic

        self.__get_item = self.__get_item_tree
        self.set_arithmetic(arithmetic)

        if index is None:
            
            if values is not None:
                raise IndexError("Index cannot be None while values are not.")

        else:
            if values is not None:
                self.__init_tree(index, values)

            else:
                self.__init_tree_index(index)


    #--------------------------------------------------------------------------------------------
    # Public methods
    #--------------------------------------------------------------------------------------------

    cpdef void insert(self, key, {DTYPE} value) except*:

        __insert_node_{DTYPE}(self.__index, key, value)


    cpdef void insert_range(self, list pairs) except*:

        cdef tuple pair

        for pair in pairs:
            __insert_node_{DTYPE}(self.__index, pair[0], pair[1])


    cpdef void erase(self, key) except*:

        __erase_node_{DTYPE}(self.__index, key)


    cpdef void erase_range(self, list keys) except*:

        cdef Py_ssize_t it

        for it in range( len(keys) ):
            __erase_node_{DTYPE}(self.__index, keys[it])


    cpdef list values(self):

        cdef rb_node_valued* it
        cdef list result = []

        for it in deref(self.__index):
            result.append( __deref_value_ptr_{DTYPE}(it) )

        return result


    cpdef list items(self):

        cdef node_ptr it
        cdef list result = []

        for it in deref(self.__index):
            result.append( ( self.__get_key_from_ptr(it), 
                             __deref_value_ptr_{DTYPE}(it) ) )

        return result


    def iteritems(self):

        cdef node_ptr it

        for it in deref(self.__index):
            yield ( self.__get_key_from_ptr(it), __deref_value_ptr_{DTYPE}(it) )


    cpdef tuple floor(self, key):

        cdef pair[node_ptr, node_ptr] bounds
        #bug? cython 0.28.3 declare c_key as const, if do not declare it directly
        cdef c_pyobject c_key = c_pyobject(<PyObject*>key)
        bounds = self.__index.tree_search(c_key)

        if bounds.first == self.link():
            return (None, None)

        return ( self.__get_key_from_ptr(bounds.first),
                 __deref_value_ptr_{DTYPE}(bounds.first) )


    cpdef tuple ceil(self, key):

        cdef pair[node_ptr, node_ptr] bounds
        #bug? cython 0.28.3 declare c_key as const, if do not declare it directly
        cdef c_pyobject c_key = c_pyobject(<PyObject*>key)  
        bounds = self.__index.tree_search(c_key)

        if bounds.second == self.link():
            return (None, None)

        return ( self.__get_key_from_ptr(bounds.second),
                 __deref_value_ptr_{DTYPE}(bounds.second) )


    cpdef __TreeSeries_{DTYPE} truncate(self, start, stop):

        cdef iterator begin
        cdef iterator end
        cdef pair[node_ptr, node_ptr] bounds_start 
        cdef pair[node_ptr, node_ptr] bounds_end
        cdef __TreeSeries_{DTYPE} result
        #bug? cython 0.28.3 declare c_key as const, if do not declare it directly
        cdef c_pyobject c_start = c_pyobject(<PyObject*>start)
        cdef c_pyobject c_stop = c_pyobject(<PyObject*>stop)

        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE}, 
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )

        bounds_start = self.__index.tree_search(c_start)
        bounds_end = self.__index.tree_search(c_stop)
        begin = deref(bounds_start.second).it_position
        end = deref(bounds_end.first).it_position

        if( bounds_start.second == self.link() ) \
            or ( bounds_end.first == self.link() ):

            return result

        while True:
            result.insert( self.__get_key_from_iter(begin), 
                           __deref_value_ptr_{DTYPE}( deref(begin) ) )

            if begin == end:
                break

            inc(begin)

        return result


    cpdef __TreeSeries_{DTYPE} periodic(self, start, stop, step):

        cdef __TreeSeries_{DTYPE} result
        cdef object it = start
        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )

        self.on_itermode()

        while it < stop:
            result.insert( it, self.__getitem__(it) )
            it = it + step

        self.off_itermode()

        return result


    cpdef __TreeSeries_{DTYPE} map( self, method, tuple args=(), 
                                  dict kwargs={map_kwargs} ):

        cdef __TreeSeries_{DTYPE} result
        cdef tuple it

        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )

        for it in self.iteritems():
            result.insert( it[0], method(it[1], *args, **kwargs) )

        return result


    cpdef void map_inplace( self, method, tuple args=(), 
                            dict kwargs={map_kwargs} ) except*:

        cdef node_ptr it

        for it in deref(self.__index):
            __set_value_{DTYPE}( it, method( __deref_value_ptr_{DTYPE}(it),
                                             *args, **kwargs ) )


    cpdef void set_interpolation(self, str interpolate):

        cdef string c_interpolate = bytearray(interpolate, 'utf8')
        self.interpolate_type = interpolate
        self.__interpolate = __INTERPOLATE_{DTYPE}[c_interpolate]


    cpdef void set_arithmetic(self, str arithmetic):

        if arithmetic == "union":
            self.__arithmetic = self.__arithmetic_union

        if arithmetic == "left":
            self.__arithmetic = self.__arithmetic_left


    cpdef void on_itermode(self):

        __BaseTreeSeries.on_itermode(self)
        self.__get_item = self.__get_item_linear


    cpdef void off_itermode(self):

        __BaseTreeSeries.off_itermode(self)
        self.__get_item = self.__get_item_tree


    cpdef void copy_data(self, other, str to_type="numerical") except*:

        cdef tuple it
        cdef {DTYPE} num
        self.clear()

        if to_type == "numerical":

            for it in other.iteritems():
                num = <{DTYPE}>float(it[1])
                self.insert( it[0], num )

        elif to_type == "str":
            
            for it in other.iteritems():
                self.insert( it[0], str(it[1]) )

        else:

            for it in other.iteritems():
                self.insert(it[0], it[1])


    cpdef void clear(self) except*:

        for key in self.keys():
            self.erase(key)

        self.__index.clear()

    #--------------------------------------------------------------------------------------------
    # Special methods
    #--------------------------------------------------------------------------------------------
    def __dealloc__(self):

        del self.__index


    def __str__(self):

        cdef str out_format = '{key}: {value}\n'
        cdef str result = 'Series object ' + self.name + '\n'
        cdef tuple it

        for it in self.iteritems():
            result += out_format.format(key=it[0], value=it[1])

        return result


    def __repr__(self):

        return self.__str__()

    
    def __iter__(self):

        cdef node_ptr it

        for it in deref(self.__index):
            yield __deref_value_ptr_{DTYPE}(it)


    def __getitem__(self, key):

        cdef int32_t error = TYPE_ERROR
        cdef {DTYPE} result

        if self.__index.size() == 0:
            return self.extrapolate

        if isinstance(key, slice):
            return self.__get_item_slice(key)

        result = self.__get_item(self, key, &error)

        if error == 0:
            return result

        if error == INT_KEY_ERROR:
            raise KeyError( str(key) )

        if error == TYPE_ERROR:
            raise TypeError("Inconsistent key type: " + key.__class__.__name__)


    def __setitem__(self, key, {DTYPE} value):

        cdef c_pyobject key_holder = to_c_pyobject(key)
        cdef node_ptr node = self.__index.insert_search(key_holder)

        if self.__index.size() == 0:
            __insert_node_by_ptr_{DTYPE}(self.__index, node, key, value)

        else:
            if self.__get_key_from_ptr(node) == key:
                __set_value_{DTYPE}(node, value)

            else:
                __insert_node_by_ptr_{DTYPE}(self.__index, node, key, value)


    #--------------------------------------------------------------------------------------------
    # Emulating numeric types
    #--------------------------------------------------------------------------------------------
    cpdef __TreeSeries_{DTYPE} add(self, __BaseTreeSeries other):

        return self.__arithmetic(self, other, __add_{DTYPE})


    cpdef __TreeSeries_{DTYPE} sub(self, __BaseTreeSeries other):

        return self.__arithmetic(self, other, __sub_{DTYPE})


    cpdef __TreeSeries_{DTYPE} mul(self, __BaseTreeSeries other):

        return self.__arithmetic(self, other, __mul_{DTYPE})


    cpdef __TreeSeries_{DTYPE} div(self, __BaseTreeSeries other):

        return self.__arithmetic(self, other, __div_{DTYPE})


    cpdef __TreeSeries_{DTYPE} lshift(self, shift_param):

        if isinstance(shift_param, int):
            return self.__lshift_int(shift_param)


    cpdef __TreeSeries_{DTYPE} rshift(self, shift_param):

        if isinstance(shift_param, int):
            return self.__rshift_int(shift_param)


    #--------------------------------------------------------------------------------------------
    # Private methods
    #--------------------------------------------------------------------------------------------
    cdef void __init_tree(self, index, values) except*:

        cdef tuple it

        if len(index) != len(values):
            raise IndexError("Index must have the same length as values.")

        for it in zip(index, values):
            self.insert(it[0], it[1])


    cdef void __init_tree_index(self, index) except*:

        for it in index:
            self.insert(it, 0)


    cdef {DTYPE} __get_item_linear(self, key, int32_t* error):

        #bug? cython 0.28.3 translate c_key to const, if do not declare it directly
        cdef c_pyobject c_key = c_pyobject(<PyObject*>key) 
        cdef pair[node_ptr, node_ptr] bounds
        
        bounds = self.__index.linear_search_from(self.__last_call, c_key)
        error[0] = 0

        if bounds.first != self.link():
            self.__last_call = bounds.first

        else:
            self.__last_call = deref( self.__index.begin() )

        return self.__interpolate( bounds.first, bounds.second, key,
                                   self.link(), self.extrapolate,
                                   error )

    
    cdef {DTYPE} __get_item_tree(self, key, int32_t* error):

        cdef c_pyobject c_key = c_pyobject(<PyObject*>key)
        cdef pair[node_ptr, node_ptr] bounds

        bounds = self.__index.tree_search(c_key)
        error[0] = 0

        return self.__interpolate( bounds.first, bounds.second, key,
                                   self.link(), self.extrapolate, 
                                   error )

    
    cdef __TreeSeries_{DTYPE} __get_item_slice(self, key):

        cdef c_pyobject c_key
        cdef node_ptr begin = deref( self.__index.begin() ) 
        cdef node_ptr end = deref( self.__index.back() )
        cdef __TreeSeries_{DTYPE} result
        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                             interpolate=self.interpolate_type,
                                             arithmetic=self.arithmetic )

        if self.__len__() == 0:
            return result

        if key.start is not None and key.stop is not None:

            if key.start < self.begin() and key.stop < self.begin():
                return result

            if key.start > self.end() and key.stop < self.end():
                return result

        if key.start is not None:
            c_key = c_pyobject(<PyObject*>key.start)
            begin = self.__index.tree_search(c_key).second

        if key.stop is not None:
            c_key = c_pyobject(<PyObject*>key.stop)
            end = self.__index.tree_search(c_key).first

        if compare_func(end.key, begin.key) \
            and ( not equal(end.key, begin.key) ):

            return result

        if begin == self.link() or end == self.link():
            return result 

        if key.step is None:
            return self.truncate( self.__get_key_from_ptr(begin),
                                  self.__get_key_from_ptr(end) )

        else: 
            return self.periodic( self.__get_key_from_ptr(begin), 
                                  self.__get_key_from_ptr(end), 
                                  key.step )


    cdef __TreeSeries_{DTYPE} __lshift_int(self, Py_ssize_t shift_param):

        cdef __TreeSeries_{DTYPE} result
        cdef list delay_holder = []
        cdef tuple pair
        cdef Py_ssize_t count = 0
        cdef bool append_status = False

        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )
        if shift_param <= 0:
            raise ValueError("Shift parameter must be more than zero.")

        for pair in self.iteritems():
            
            if append_status:
                result.insert(delay_holder[0], pair[1])
                delay_holder.pop(0)

            if count == shift_param - 1:
                append_status = True

            delay_holder.append(pair[0])
            count += 1

        return result


    cdef __TreeSeries_{DTYPE} __rshift_int(self, Py_ssize_t shift_param):

        cdef __TreeSeries_{DTYPE} result
        cdef list delay_holder = []
        cdef tuple pair
        cdef Py_ssize_t count = 0
        cdef bool append_status = False

        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )
        if isinstance(shift_param, int):

            if shift_param <= 0:
                raise ValueError("Shift parameter must be more than zero.")

            for pair in self.iteritems():
                
                if append_status:
                    result.insert(pair[0], delay_holder[0])
                    delay_holder.pop(0)

                if count == shift_param - 1:
                    append_status = True

                delay_holder.append(pair[1])
                count += 1

            return result


    cdef __TreeSeries_{DTYPE} __arithmetic_left( self, __BaseTreeSeries other, 
                                                 arithmetic_{DTYPE} action ):

        cdef {DTYPE} current
        cdef node_ptr node
        cdef object key
        cdef __TreeSeries_{DTYPE} result
        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )
        other.on_itermode()

        for node in deref(self.__index):

            key = self.__get_key_from_ptr(node)
            current = action(__deref_value_ptr_{DTYPE}(node), other[key])
            __insert_node_{DTYPE}(result.__index, key, current)

        other.off_itermode()

        return result


    cdef __TreeSeries_{DTYPE} __arithmetic_union( self, __BaseTreeSeries other, 
                                                  arithmetic_{DTYPE} action ):

        cdef {DTYPE} current
        cdef object key
        cdef trees_iterator[rb_tree, rb_node_valued] iterator
        cdef vector[rb_tree_ptr] trees = vector[rb_tree_ptr](2)
        cdef __TreeSeries_{DTYPE} result
        result = __TreeSeries_{DTYPE}.__new__( __TreeSeries_{DTYPE},
                                               interpolate=self.interpolate_type,
                                               arithmetic=self.arithmetic )
        
        trees[0] = self.__index
        trees[1] = other.get_tree()
        iterator.set_equal(equal_pair)
        iterator.set_compare(comp_pair)
        iterator.set_iterator(trees, "forward")

        self.on_itermode()
        other.on_itermode()

        while not iterator.empty():

            key = <object>deref(iterator).key.data
            current = action(self.__getitem__(key), other[key])
            __insert_node_{DTYPE}(result.__index, key, current)
            pinc(iterator)

        self.off_itermode()
        other.off_itermode()

        return result
