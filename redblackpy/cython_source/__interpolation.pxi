#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

#--------------------------------------------------------------------------------------------
# Basics interpolation implementation.
#--------------------------------------------------------------------------------------------
ctypedef {DTYPE} ( *interpolate_{DTYPE})(node_ptr, node_ptr, object, node_ptr, 
                   {DTYPE}, int32_t* )
ctypedef {DTYPE} (*itermode_search_{DTYPE})(TreeSeries_{DTYPE}, object, int32_t*)



# Interpolation for node wich key in [node_1->key, node_2->key]
cdef {DTYPE} __interpolate_floor_{DTYPE}( node_ptr node_1, node_ptr node_2, key, 
                                          node_ptr link, {DTYPE} extrapolate,
                                          int32_t* error ):
    
    if node_1 != link:
        return __deref_value_ptr_{DTYPE}(node_1)

    return extrapolate


cdef {DTYPE} __interpolate_ceil_{DTYPE}( node_ptr node_1, node_ptr node_2, key, 
                                         node_ptr link, {DTYPE} extrapolate,
                                         int32_t* error ):

    if node_2 != link:
        return __deref_value_ptr_{DTYPE}(node_2)

    return extrapolate


cdef {DTYPE} __interpolate_nn_{DTYPE}( node_ptr node_1, node_ptr node_2, key, 
                                       node_ptr link, {DTYPE} extrapolate,
                                       int32_t* error ):
    
    cdef object time_1
    cdef object time_2

    if (node_1 != link) and (node_2 != link):

        time_1 = <object>deref(node_1).key.data
        time_2 = <object>deref(node_2).key.data

        if (time_2 - key) <= (key - time_1):
            return __deref_value_ptr_{DTYPE}(node_2)

        return __deref_value_ptr_{DTYPE}(node_1)

    elif (node_1 == link):
        return __deref_value_ptr_{DTYPE}(node_2)

    return __deref_value_ptr_{DTYPE}(node_1)


cdef {DTYPE} __interpolate_linear_{DTYPE}( node_ptr node_1, node_ptr node_2, key, 
                                           node_ptr link, {DTYPE} extrapolate,
                                           int32_t* error ):
    
    cdef object time_1
    cdef object time_2
    cdef {DTYPE} tan
    cdef {DTYPE} value

    if (node_1 != link) and (node_2 != link):

        time_1 = <object>deref(node_1).key.data
        time_2 = <object>deref(node_2).key.data
        tan = (key - time_1)/(time_2 - time_1)
        value = __deref_value_ptr_{DTYPE}(node_1)

        return value + tan*(__deref_value_ptr_{DTYPE}(node_2) - value)

    return extrapolate


cdef {DTYPE} __interpolate_keys_only_{DTYPE}( node_ptr node_1, node_ptr node_2, key, 
                                              node_ptr link, {DTYPE} extrapolate,
                                              int32_t* error ):
    
    if node_1 != link:

        if <object>deref(node_1).key.data == key:
            return __deref_value_ptr_{DTYPE}(node_1)

    error[0] = INT_KEY_ERROR

    return <{DTYPE}>0xdeadbeef 


cdef unordered_map[string, interpolate_{DTYPE}] __INTERPOLATE_{DTYPE}
__INTERPOLATE_{DTYPE}["floor"]  = &__interpolate_floor_{DTYPE}
__INTERPOLATE_{DTYPE}["ceil"]   = &__interpolate_ceil_{DTYPE}
__INTERPOLATE_{DTYPE}["nn"]     = &__interpolate_nn_{DTYPE}
__INTERPOLATE_{DTYPE}["linear"] = &__interpolate_linear_{DTYPE}
__INTERPOLATE_{DTYPE}["error"]  = &__interpolate_keys_only_{DTYPE}
