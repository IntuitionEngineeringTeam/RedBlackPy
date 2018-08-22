//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __NODE_VAL_TPP
#define __NODE_VAL_TPP

//---------------------------------------------------------------------------------------
// Red-Black Tree node template class implementation
//---------------------------------------------------------------------------------------

// Constructors
//---------------------------------------------------------------------------------------
template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::rb_node_valued()
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , key( key_type() )
    , value( val_type() )
    , color(true) { }


template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::
rb_node_valued(rb_node_valued<key_type, val_type>::const_ref other) {

    *this = other;
}


template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::
rb_node_valued(rb_node_valued<key_type, val_type>::self_rref other) {

    std::swap(color, other.color);
    std::swap(key, other.key);
    std::swap(value, other.value);
    std::swap(left, other.left);
    std::swap(right, other.right);
    std::swap(parent, other.parent);
    std::swap(it_position, other.it_position);
}


template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::rb_node_valued(const key_type& key, const val_type& value)
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , color(true) { 

    rb_node_valued<key_type, val_type>::key = key_type(key);
    rb_node_valued<key_type, val_type>::value = val_type(value);
}


template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::rb_node_valued(key_type&& key, val_type&& value)
    : left(nullptr)
    , right(nullptr)
    , parent(nullptr)
    , color(true) { 

    std::swap(rb_node_valued<key_type, val_type>::key, key);
    std::swap(rb_node_valued<key_type, val_type>::value, value);
}


template <class key_type, class val_type>
rb_node_valued<key_type, val_type>::~rb_node_valued() { }


// Public methods
//---------------------------------------------------------------------------------------

template <class key_type, class val_type>
rb_node_valued<key_type, val_type>& rb_node_valued<key_type, val_type>::
operator=(rb_node_valued<key_type, val_type>::const_ref other) {

    color = other.color;
    key = other.key;
    value = other.value;
    left = other.left;
    right = other.right;
    parent = other.parent;
    it_position = other.it_position;

    return *this;
}

#endif // __NODE_VAL_TPP