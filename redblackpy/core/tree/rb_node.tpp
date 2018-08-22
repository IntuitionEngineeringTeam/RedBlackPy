//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __NODE_TPP
#define __NODE_TPP

//---------------------------------------------------------------------------------------
// Red-Black Tree node template class implementation
//---------------------------------------------------------------------------------------

// Constructors
//---------------------------------------------------------------------------------------
template <class key_type>
rb_node<key_type>::rb_node()
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , key( key_type() )
    , color(true) { }


template <class key_type>
rb_node<key_type>::rb_node(rb_node<key_type>::const_ref other) {

    *this = other;
}


template <class key_type>
rb_node<key_type>::rb_node(rb_node<key_type>::self_rref other) {

    std::swap(color, other.color);
    std::swap(key, other.key);
    std::swap(left, other.left);
    std::swap(right, other.right);
    std::swap(parent, other.parent);
    std::swap(it_position, other.it_position);
}


template <class key_type>
rb_node<key_type>::rb_node(const key_type& key)
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , color(true) { 

    rb_node<key_type>::key = key_type(key);
}


template <class key_type>
rb_node<key_type>::rb_node(key_type&& key)
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , color(true) { 

    std::swap(rb_node<key_type>::key, key);
}


template <class key_type>
rb_node<key_type>::rb_node( const key_type& key, rb_node<key_type>* left, 
                            rb_node<key_type>* right )
    : parent(nullptr)
    , color(true) {

    rb_node<key_type>::key = key_type(key);
    rb_node<key_type>::left = left;
    rb_node<key_type>::right = right;
}


template <class key_type>
rb_node<key_type>::~rb_node() { }


// Public methods
//---------------------------------------------------------------------------------------

template <class key_type>
rb_node<key_type>& rb_node<key_type>::operator=(rb_node<key_type>::const_ref other) {

    color = other.color;
    key = other.key;
    left = other.left;
    right = other.right;
    parent = other.parent;
    it_position = other.it_position;

    return *this;
}

#endif // __NODE_TPP