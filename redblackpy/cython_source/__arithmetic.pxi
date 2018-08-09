#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

#--------------------------------------------------------------------------------------------
# Arithmetic helpers
#--------------------------------------------------------------------------------------------
ctypedef {DTYPE} (*arithmetic_{DTYPE})({DTYPE}, {DTYPE})
ctypedef __TreeSeries_{DTYPE} (*arithmetic_type_{DTYPE})( __TreeSeries_{DTYPE}, 
													      __BaseTreeSeries, 
                                                          arithmetic_{DTYPE} )


cdef inline {DTYPE} __add_{DTYPE}({DTYPE} a, {DTYPE} b):

    return a + b


cdef inline {DTYPE} __sub_{DTYPE}({DTYPE} a, {DTYPE} b):

    return a - b


cdef inline {DTYPE} __mul_{DTYPE}({DTYPE} a, {DTYPE} b):

    return a * b


cdef inline {DTYPE} __div_{DTYPE}({DTYPE} a, {DTYPE} b):

    return a / b
