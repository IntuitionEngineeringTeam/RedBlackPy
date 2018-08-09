#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#


#--------------------------------------------------------------------------------------------
# Base class for series on trees
#--------------------------------------------------------------------------------------------
cdef class __BaseTreeSeries:


    def __init__(self):
        pass


    def __cinit__(self):

        self.__index = new rb_tree()
        self.__index.set_compare(compare_func)
        self.__index.set_equal(equal)
        self.__iter_mode = False
        self.__last_call = deref( self.__index.begin() )


    cpdef bint empty(self):

        return (self.__index.size() == 0)


    cpdef list keys(self):

        cdef node_ptr it
        cdef list result = []

        for it in deref(self.__index):
            result.append( self.__get_key_from_ptr(it) )

        return result


    cpdef begin(self):

        if self.__index.size() == 0:
            raise IndexError("Index is empty.")

        return self.__get_key_from_iter( self.__index.begin() )


    cpdef end(self):

        if self.__index.size() == 0:
            raise IndexError("Index is empty.")

        return self.__get_key_from_iter( self.__index.back() )


    cpdef void on_itermode(self):

        self.__iter_mode = True
        self.__last_call = deref(self.__index.begin())

    
    cpdef void off_itermode(self):

        self.__iter_mode = False
        self.__last_call = deref(self.__index.begin())


    cdef inline rb_tree_ptr get_tree(self):

        return self.__index 


    cdef inline node_ptr link(self):

        return self.__index.link()


    def __len__(self):

        return self.__index.size()


    def __contains__(self, key):

        cdef c_pyobject c_key = c_pyobject(<PyObject*>key)
        cdef node_ptr node = self.__index.search(c_key)

        if ( node != self.link() ):
            return True

        return False


    cdef inline __get_key_from_ptr(self, node_ptr node):

        return <object>deref(node).key.data


    cdef inline __get_key_from_iter(self, iterator node):

        return <object>deref( deref(node) ).key.data
