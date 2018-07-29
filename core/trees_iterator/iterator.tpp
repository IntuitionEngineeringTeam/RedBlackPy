//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __ITER_TPP // header guards
#define __ITER_TPP

//---------------------------------------------------------------------------------------------------------
// Tree iterator template class implementation
//---------------------------------------------------------------------------------------------------------

// Constructors
//---------------------------------------------------------------------------------------------------------
template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>::trees_iterator()
    : __current(nullptr) { }


template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>::trees_iterator(const trees_iterator& other) {

    __current = other.__current;
    __queue = other.__queue;
    __comp_py = other.__comp_py; 
    __equal_py = other.__equal_py;
}


template < class tree_type, 
           class node_type >
template <class Iterable>
trees_iterator<tree_type, node_type>::
trees_iterator(Iterable& trees, std::string type) {

    set_iterator(trees, type);
}


template < class tree_type, 
           class node_type >
template <class Iterable>
trees_iterator<tree_type, node_type>::
trees_iterator( Iterable& trees, std::string type, 
                key_compare_py comp, 
                key_compare_py equal ) {

    __queue.set_equal(equal);
    __queue.set_compare(comp);
    __comp_py = comp; 
    __equal_py = equal;

    set_iterator(trees, type);
}


template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>::~trees_iterator() { }


// Public Methods
//---------------------------------------------------------------------------------------------------------
template < class tree_type, 
           class node_type >
inline bool trees_iterator<tree_type, node_type>::empty() {

    if (__queue.size() == 0)
        return true;

    return false; 
}


template < class tree_type, 
           class node_type >
template <class Iterable>
inline void trees_iterator<tree_type, node_type>::
set_iterator(Iterable& trees, std::string type) {

    if (type == "forward")
        __set_iterator( trees, &tree_type::begin, 
                        &rb_tree<node_t, pair_t>::begin );

    else if (type == "reverse")
        __set_iterator( trees, &tree_type::back, 
                        &rb_tree<node_t, pair_t>::back );

    else
        throw TypeError("Uknown iterator type.");
}


template < class tree_type, 
           class node_type >
inline void trees_iterator<tree_type, node_type>::
set_compare(key_compare_py compare) {

    __queue.set_compare(compare);
    __comp_py = compare;
}


template < class tree_type, 
           class node_type >
inline void trees_iterator<tree_type, node_type>::
set_equal(key_compare_py equal) {

    __queue.set_equal(equal);
    __equal_py = equal;
}


// Operators
//---------------------------------------------------------------------------------------------------------
template < class tree_type, 
           class node_type >
inline bool trees_iterator<tree_type, node_type>::
operator==(const trees_iterator& other) const {

    return (*__current == *other.__current);
}

template < class tree_type, 
           class node_type >
inline bool trees_iterator<tree_type, node_type>::
operator!=(const trees_iterator& other) const {

    return (*__current != *other.__current);    
}


template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>& 
trees_iterator<tree_type, node_type>::operator++(int) {

    __advance( &__next, &tree_type::back, 
               &rb_tree<node_t, pair_t>::begin );

    return *this;
}


template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>& 
trees_iterator<tree_type, node_type>::operator--(int) {

    __advance( &__prev, &tree_type::begin, 
               &rb_tree<node_t, pair_t>::back );

    return *this;
}


template < class tree_type, 
           class node_type >
trees_iterator<tree_type, node_type>& 
trees_iterator<tree_type, node_type>::operator=(const trees_iterator& other) {

    __current = other.__current;
    __queue = other.__queue;
    __comp_py = other.__comp_py;
    __equal_py = other.__equal_py;

    return *this;
}


template < class tree_type, 
           class node_type >
inline node_type& trees_iterator<tree_type, node_type>::operator*() const {

    return *(*__current->second);
}


// Private methods
//-------------------------------------------------------------------------------------------
template < class tree_type, 
           class node_type >
inline typename trees_iterator<tree_type, node_type>::node_iter
trees_iterator<tree_type, node_type>::__next(node_iter it) {

    return std::next(it);
}


template < class tree_type, 
           class node_type >
inline typename trees_iterator<tree_type, node_type>::node_iter
trees_iterator<tree_type, node_type>::__prev(node_iter it) {

    return std::prev(it);
}


template < class tree_type, 
           class node_type >
void trees_iterator<tree_type, node_type>::
__advance(advance_t advance, tail_tree access_1, tail_queue access_2) {

    if ( __queue.size() != 0 ) {

        if ( __current->second != (__current->first->*access_1)() ) {
            pair_t pair;
            node_iter iter = __current->second;
            node_t* it;

            do {
                iter = advance(iter);
                pair = pair_t( __current->first, iter);
                it = __queue.insert_search(pair);

                if ( !__equal(it->key, pair) ) {
                    __queue.insert( it, node_t(pair) );
                    break;
                }

            } while ( pair.second != (pair.first->*access_1)() );
        }

        __queue.erase( *( (&__queue)->*access_2 )() );

        if (__queue.size() != 0)
            /*
            ( (&__queue)->*access_2 )() - call member function begin() or back() by pointer.
            begin() or back() returns iterators of nodes pointers, so we get the object using *.
            ( *( (&__queue)->*access_2 )() )->key - this has type trees_iterator::pair_t, __current
            has type pair_t*, so we get the addres using &. 
            **/
            __current = &( *( (&__queue)->*access_2 )() )->key;
    }
}


template < class tree_type, 
           class node_type >
template <class Iterable>
void trees_iterator<tree_type, node_type>::
__set_iterator(Iterable& trees, tail_tree access_1, tail_queue access_2) {

    pair_t pair;
    node_t* it;

    __queue = rb_tree<node_t, pair_t>();
    __queue.set_equal(__equal_py);
    __queue.set_compare(__comp_py);
    __queue.insert( pair_t( trees[0], (trees[0]->*access_1)() ) );

    for(size_t i = 1; i < trees.size(); i++) {
        pair = pair_t( trees[i], (trees[i]->*access_1)() );
        it = __queue.insert_search(pair);

        if ( !__equal(it->key, pair) )
            __queue.insert( it, node_t(pair) );
    }
    /*
    ( (&__queue)->*access_2 )() - call member function begin() or back() by pointer.
    begin() or back() returns iterators of nodes pointers, so we get the object using *.
    ( *( (&__queue)->*access_2 )() )->key - this has type trees_iterator::pair_t, __current
    has type pair_t*, so we get the addres using &. 
    **/
    __current =  &( *( (&__queue)->*access_2 )() )->key;
}


template < class tree_type, 
           class node_type >
bool trees_iterator<tree_type, node_type>::
__comp(const pair_t& pair_1, const pair_t& pair_2) {

    int result = __comp_py(pair_1, pair_2);

    if (result != -1)
        return result;

    throw TypeError("Your query to tree contains inconsistent key type.");

    return true;
}


template < class tree_type, 
           class node_type >
bool trees_iterator<tree_type, node_type>::
__equal(const pair_t& pair_1, const pair_t& pair_2) {

    int result = __equal_py(pair_1, pair_2);

    if (result != -1)
        return result;

    throw TypeError("Your query to tree contains inconsistent key type.");

    return true;
}


#endif // __ITER_TPP