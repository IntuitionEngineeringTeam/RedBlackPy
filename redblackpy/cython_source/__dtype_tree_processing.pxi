#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#


cdef inline {DTYPE} __deref_value_ptr_{DTYPE}(node_ptr node):

    return deref( <{DTYPE}*>deref(node).value )


cdef void __insert_node_{DTYPE}(rb_tree_ptr& index, key, {DTYPE} value) except*:

    cdef void* address = malloc( sizeof({DTYPE}) )
    # assign new value and insert node with address
    (<{DTYPE}*>address)[0] = value
    index.insert( rb_node_valued(to_c_pyobject(key), address) )


cdef void __insert_node_by_ptr_{DTYPE}( rb_tree_ptr& index, node_ptr& position, 
                                        key, {DTYPE} value ) except*:

    cdef void* address = malloc( sizeof({DTYPE}) )
    # assign new value and insert node with address
    (<{DTYPE}*>address)[0] = value
    index.insert( position, rb_node_valued(to_c_pyobject(key), address) )


cdef void __erase_node_{DTYPE}(rb_tree_ptr& index, key) except*:
    
    cdef c_pyobject c_key = c_pyobject(<PyObject*>key) 
    cdef node_ptr node = index.search(c_key)

    if ( node != index.link() ):
        # free memomry that has been used to keeping value
        if deref(node).value != NULL:
            free(deref(node).value)
        # Decrement reference counter to destroy key
        Py_XDECREF(deref(node).key.data)
        index.erase(node)


cdef inline void __set_value_{DTYPE}(node_ptr node, {DTYPE} value) nogil:

    if deref(node).value != NULL:
        (<{DTYPE}*>deref(node).value)[0] = value

    else:
        deref(node).value = malloc( sizeof({DTYPE}) )
        (<{DTYPE}*>deref(node).value)[0] = value


cdef inline void __dealloc_value_{DTYPE}(node_ptr node) nogil:

    if deref(node).value != NULL:
        free(deref(node).value)


