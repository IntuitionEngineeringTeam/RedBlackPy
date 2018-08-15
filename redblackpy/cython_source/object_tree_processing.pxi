#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#
cdef inline object __deref_value_ptr_object(node_ptr node):

    return <object>deref(node).value


cdef inline void __insert_node_object(rb_tree_ptr& index, key, value) except*:

    index.insert( rb_node_valued( to_c_pyobject(key), 
                                  to_c_pyobject(value).data ) )


cdef inline void __insert_node_by_ptr_object( rb_tree_ptr& index, node_ptr& position, 
                                              key, value ) except*:

    index.insert( position, rb_node_valued( to_c_pyobject(key), 
                                            to_c_pyobject(value).data ) )


cdef void __erase_node_object(rb_tree_ptr& index, key) except*:

    cdef c_pyobject c_key = c_pyobject(<PyObject*>key) 
    cdef node_ptr node = index.search(c_key)

    if ( node != index.link() ):
        # Decrement reference counter to destroy value
        Py_XDECREF(<PyObject*>deref(node).value)
        # Decrement reference counter to destroy key
        Py_XDECREF(deref(node).key.data)
        index.erase(node)


cdef void __set_value_object(node_ptr node, value) except*:

    Py_XDECREF(<PyObject*>deref(node).value)
    deref(node).value = to_c_pyobject(value).data


cdef inline void __dealloc_value_object(node_ptr node) except*:

    Py_XDECREF(<PyObject*>deref(node).value)
