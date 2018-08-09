//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __QSE // header guards
#define __QSE

#include <exception>
#include <string>


namespace qseries {

//--------------------------------------------------------------------------------
// Base class for handling exceptions
//--------------------------------------------------------------------------------

class BaseException : public std::exception {


    public:

        // Constructors, Destructor
        explicit BaseException(const char* message) : 
            __msg_converter(message) {}

        explicit BaseException(const std::string& message) :
            __msg_converter(message) {}

        virtual ~BaseException() throw() {}

        virtual const char* what() const throw () {
            return __msg_converter.c_str();
        }

    protected:

        std::string __msg_converter;

};

//--------------------------------------------------------------------------------
// Key errors
//--------------------------------------------------------------------------------

class KeyError : public BaseException {

    
    public:

        KeyError(const char* message):BaseException(message) {}
        KeyError(const std::string& message):BaseException(message) {}
};


class TypeError : public BaseException {

    
    public:

        TypeError(const char* message):BaseException(message) {}
        TypeError(const std::string& message):BaseException(message) {}
};



} // namespace qseries

#endif // __QSE