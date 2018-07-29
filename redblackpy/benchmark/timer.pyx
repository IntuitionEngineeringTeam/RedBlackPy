#
#  Created by Soldoskikh Kirill.
#  Copyright © 2018 Intuition. All rights reserved.
#

#--------------------------------------------------------------------------------------------
# Extern timer class
#--------------------------------------------------------------------------------------------
cdef extern from "<core/timer/timer.hpp>" namespace "qseries" nogil:

    cdef cppclass nano_timer:
        nano_timer()
        void start()
        double stop()


#--------------------------------------------------------------------------------------------
# Cython wrapper for timer
#--------------------------------------------------------------------------------------------
cdef class Timer:

    cdef nano_timer __timer


    def __cinit__(self):

        self.__timer = nano_timer()


    def start(self):

        self.__timer.start()


    def stop(self):

        return self.__timer.stop()
