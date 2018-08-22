//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __TIMER
#define __TIMER


#include <chrono>

namespace qseries {

//---------------------------------------------------------------------------------------------------------
// Simple timer class for benchmarking.
//---------------------------------------------------------------------------------------------------------
class nano_timer {

    public:

        nano_timer() : __run(false) {}
        ~nano_timer() {}


        void start() {
            __start = __clock::now();
            __run = true;
        }


        double stop() {

            if (__run) {
                __run = false;
                return std::chrono::duration_cast<__second>(
                            __clock::now() - __start).count();
            }

            return 0;
        }


    private:

        typedef std::chrono::high_resolution_clock            __clock;
        typedef std::chrono::duration<double, std::ratio<1> > __second;

        bool __run;
        std::chrono::time_point<__clock> __start;
};


} // namespace qseries


#endif // __TIMER