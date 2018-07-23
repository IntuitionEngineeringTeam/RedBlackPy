//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __TREE_TPP
#define __TREE_TPP


//---------------------------------------------------------------------------------------------------------
// Red-Black Tree template class implementation
//---------------------------------------------------------------------------------------------------------
template <class node_type, class key_type, class alloc_type>
using iterator = typename rb_tree<node_type, key_type, alloc_type>::iterator;

template <class node_type, class key_type, class alloc_type>
using ptr = typename rb_tree<node_type, key_type, alloc_type>::ptr;

template <class node_type, class key_type, class alloc_type>
using ref = typename rb_tree<node_type, key_type, alloc_type>::ref;

template <class node_type, class key_type, class alloc_type>
using const_ref = typename rb_tree<node_type, key_type, alloc_type>::const_ref;

template <class node_type, class key_type, class alloc_type>
using node_ptr = typename rb_tree<node_type, key_type, alloc_type>::node_ptr;

template <class node_type, class key_type, class alloc_type>
using node_ref = typename rb_tree<node_type, key_type, alloc_type>::node_ref;

template <class node_type, class key_type, class alloc_type>
using const_node_ptr = typename rb_tree<node_type, key_type, alloc_type>::const_node_ptr;

template <class node_type, class key_type, class alloc_type>
using const_node_ref = typename rb_tree<node_type, key_type, alloc_type>::const_node_ref;

template <class node_type, class key_type, class alloc_type>
using node_pair = typename rb_tree<node_type, key_type, alloc_type>::node_pair;

template <class node_type, class key_type, class alloc_type>
using size_type = typename rb_tree<node_type, key_type, alloc_type>::size_type;
//---------------------------------------------------------------------------------------------------------

// Constructors
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
rb_tree<node_type, key_type, alloc_type>::rb_tree()
    : __link( new node_type() )
    , __comp_py(nullptr)
    , __equal_py(nullptr)
    , __size(0)
    , __allocator( alloc_type() ) { 

    *__link = node_type();
    __root = __link;
    __begin = __link;
    __end = __link;

    __root->color = true;
    __root->parent = __link;
    __root->left = __link;
    __root->right = __link;
}


template < class node_type,
           class key_type,
           class alloc_type >
rb_tree<node_type, key_type, alloc_type>::rb_tree(const_ref other)
    : __link( new node_type() )
    , __comp_py(nullptr)
    , __equal_py(nullptr)
    , __size(0)
    , __allocator( alloc_type() ) { 

    *__link = node_type();
    __root = __link;
    __begin = __link;
    __end = __link;

    __root->color = true;
    __root->parent = __link;
    __root->left = __link;
    __root->right = __link;

    *this = other;
}


template < class node_type,
           class key_type,
           class alloc_type >
rb_tree<node_type, key_type, alloc_type>::~rb_tree() { 

    clear();
    delete __link;
}


// Public methods
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
inline size_type<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::size() {

    return __size;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::clear() {

    for (size_t i = 0; i < __size; i++)
        erase(__begin->key);
    
}


// Iterators
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
inline typename rb_tree<node_type, key_type, alloc_type>::iterator
rb_tree<node_type, key_type, alloc_type>::begin() {

    return __nodes.begin();
}


template < class node_type,
           class key_type,
           class alloc_type >
inline typename rb_tree<node_type, key_type, alloc_type>::iterator
rb_tree<node_type, key_type, alloc_type>::end() {

    return __nodes.end();
}


template < class node_type,
           class key_type,
           class alloc_type >
inline typename rb_tree<node_type, key_type, alloc_type>::iterator
rb_tree<node_type, key_type, alloc_type>::back() {

    return __end->it_position;
}


template < class node_type,
           class key_type,
           class alloc_type >
inline typename rb_tree<node_type, key_type, alloc_type>::const_iterator
rb_tree<node_type, key_type, alloc_type>::cbegin() const {

    return __nodes.cbegin();
}


template < class node_type,
           class key_type,
           class alloc_type >
inline typename rb_tree<node_type, key_type, alloc_type>::const_iterator
rb_tree<node_type, key_type, alloc_type>::cend() const {

    return __nodes.cend();
}


// Modifiers
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
inline node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::insert(const key_type& key) {

    return insert( node_type(key) );
}


template < class node_type,
           class key_type,
           class alloc_type >
inline node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::insert(key_type&& key) {

    return insert( node_type(key) );
}


template < class node_type,
           class key_type,
           class alloc_type >
inline node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::insert(const_node_ref node) {

    return insert( std::move( node_type(node) ) );
}


template < class node_type,
           class key_type,
           class alloc_type >
node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::insert(node_type&& node) {

    node_ptr new_node = __allocator.allocate(1);
    __allocator.construct( new_node, node_type(node) );
    int update = __insert_update(new_node);
    node_ptr position;

    switch(update) {

        case 0: position = insert_search(new_node->key);

                if ( __equal(new_node->key, position->key) )
                    throw KeyError("Key already exists.");

                __insert(new_node,  position);
                break; 

        case 1: if ( __equal(new_node->key, __begin->key) )
                    throw KeyError("Key already exists.");

                __insert(new_node, __begin);
                __begin = new_node;
                break;

        case -1: if ( __equal(new_node->key, __end->key) )
                    throw KeyError("Key already exists.");

                 __insert(new_node, __end);
                 __end = new_node;
                 break;

        case 2: break;
    }

    __insert_process(new_node);
    __size++;

    return new_node;
}


template < class node_type,
           class key_type,
           class alloc_type >
node_ptr<node_type, key_type, alloc_type> rb_tree<node_type, key_type, alloc_type>::
insert(node_ptr& position, const_node_ref node) {

    node_ptr new_node = __allocator.allocate(1);
    __allocator.construct(new_node, node_type(node));
    int update = __insert_update(new_node);

    switch(update) {

        case 0: if ( __equal(new_node->key, position->key) )
                    throw KeyError("Key already exists.");

                __insert(new_node,  position);
                break; 

        case 1: if ( __equal(new_node->key, __begin->key) )
                    throw KeyError("Key already exists.");

                __insert(new_node, __begin);
                __begin = new_node;
                break;

        case -1: if ( __equal(new_node->key, __end->key) )
                    throw KeyError("Key already exists.");

                 __insert(new_node, __end);
                 __end = new_node;
                 break;

        case 2: break;
    }

    __insert_process(new_node);
    __size++;

    return new_node;
}


template < class node_type,
           class key_type,
           class alloc_type >
node_ptr<node_type, key_type, alloc_type> 
rb_tree<node_type, key_type, alloc_type>::insert_search(const key_type& key) {

    node_ptr it = __root;
    node_ptr result = __link;

    while (it != __link) {
        result = it;

        if ( __equal(it->key, key) ) 
            return it;

        if ( __comp(key, it->key) )
            it = it->left;

        else 
            it = it->right;

    }

    return result; 
}


template < class node_type,
           class key_type,
           class alloc_type >
inline void rb_tree<node_type, key_type, alloc_type>::erase(const key_type& key) {

    node_ptr node = search(key);

    if ( __equal(node->key, key) )
        erase(node);
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::erase(node_ptr node) {

    __delete(node);
    __nodes.erase(node->it_position);
    __allocator.destroy(node);
    __allocator.deallocate(node, 1);
    __size--;
    __begin = *__nodes.begin();
    __end = __nodes.back();
}


template < class node_type,
           class key_type,
           class alloc_type >
inline void 
rb_tree<node_type, key_type, alloc_type>::set_compare(key_compare_py compare) {

    __comp_py = compare;
}


template < class node_type,
           class key_type,
           class alloc_type >
inline void 
rb_tree<node_type, key_type, alloc_type>::set_equal(key_compare_py equal) {

    __equal_py = equal;
}


template < class node_type,
           class key_type,
           class alloc_type >
ref<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::operator=(const_ref other) {

    clear();
    rb_tree();

    __comp_py = other.__comp_py;
    __equal_py = other.__equal_py;

    for (auto &node: other.__nodes)
        insert(*node);

    return *this;
}


// Search, Interpolation
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
inline node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::root() {

    return __root;
}


template < class node_type,
           class key_type,
           class alloc_type >
inline node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::link() {

    return __link;
}


template < class node_type,
           class key_type,
           class alloc_type >
node_ptr<node_type, key_type, alloc_type>
rb_tree<node_type, key_type, alloc_type>::search(const key_type& key) {

    node_ptr it = __root;

    while (it != __link) {

        if ( __equal(it->key, key) ) 
            return it;

        if ( __comp(key, it->key) )
            it = it->left;

        else 
            it = it->right;
    }

    return it; 
}


template < class node_type,
           class key_type,
           class alloc_type >
node_pair<node_type, key_type, alloc_type> rb_tree<node_type, key_type, alloc_type>::
linear_search_from(node_ptr it, const key_type& key) {

    if ( __comp(key, it->key) )
        return tree_search(key);

    iterator result = it->it_position;
    iterator end = std::prev( __nodes.end() );

    for( ; result != end; result++) {

        if ( __equal( (*result)->key, key ) )
            return node_pair( (*result), (*result) );

        if ( __comp(key, ( *std::next(result) )->key) )
            return node_pair( *result, *std::next(result) );
    }

    return node_pair(__end, __link);
}


template < class node_type,
           class key_type,
           class alloc_type >
node_pair<node_type, key_type, alloc_type> 
rb_tree<node_type, key_type, alloc_type>::tree_search(const key_type& key) {

    if ( __comp(key, __begin->key) )
        return node_pair(__link, __begin);

    if ( __comp(__end->key, key) )
        return node_pair(__end, __link);

    node_ptr it = insert_search(key);

    if ( __comp(key, it->key) )
        return node_pair( *std::prev(it->it_position), it );

    if ( __comp(it->key, key) )
        return node_pair( it, *std::next(it->it_position) );

    return node_pair(it, it);
}


// Private methods
//---------------------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__insert(node_ptr& new_node, node_ptr& pos) {

    new_node->parent = pos;

    if (pos == __link)
        __root = new_node;

    else if ( __comp(new_node->key, pos->key) ) {
        pos->left = new_node;
        new_node->it_position = __nodes.insert( pos->it_position,
                                                new_node );
    }

    else {
        pos->right = new_node;
        new_node->it_position = __nodes.insert( std::next(
                                                pos->it_position),
                                                new_node );
    }

    new_node->left = __link;
    new_node->right = __link;
    new_node->color = false;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__insert_process(node_ptr& new_node) {

    while (!new_node->parent->color) {

        if (new_node->parent == new_node->parent->parent->left) 
            __insert_process_side( new_node, 
                                   &node_type::left,
                                   &node_type::right );

        else
            __insert_process_side( new_node, 
                                   &node_type::right,
                                   &node_type::left );
    }

    __root->color = true;   
}


template < class node_type,
           class key_type,
           class alloc_type >
int rb_tree<node_type, key_type, alloc_type>::
__insert_update(node_ptr& new_node) {

    if (__size > 0) {

        if ( __comp(new_node->key, __begin->key) ) 
            return 1;

        if ( __comp(__end->key, new_node->key) ) {
            return -1;
        }
    }

    if (__size == 0) {
        __root = new_node;
        __begin = new_node;
        __end = new_node;
        __nodes.push_back(new_node);
        __insert(new_node,  __link);
        new_node->it_position = __nodes.begin();
        return 2;
    }

    return 0;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__insert_process_red(node_ptr& new_node, node_ptr& it) {

    new_node->parent->color = true;
    it->color = true;
    new_node->parent->parent->color = false;
    new_node = new_node->parent->parent;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__insert_process_side( node_ptr& new_node, node_ptr node_type::*side_1, 
                       node_ptr node_type::*side_2 ) {

    node_ptr node_1 = new_node->parent->parent->* side_2;

    if (!node_1->color)
        __insert_process_red(new_node, node_1);

    else {

        if (new_node == new_node->parent->* side_2) {
            new_node = new_node->parent;
            __rotation(new_node, side_1, side_2);
        }

        std::swap( new_node->parent->color, 
                   new_node->parent->parent->color);
        __rotation(new_node->parent->parent, side_2, side_1);
    }
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::__delete(node_ptr& node) {

    node_ptr it_1 = node;
    node_ptr it_2;
    bool it_color = it_1->color;

    if (node->left == __link) {
        it_2 = node->right;
        __transplant(node, node->right);
    }

    else if (node->right == __link) {
        it_2 = node->left;
        __transplant(node, node->left);
    }

    else {
        it_1 = *std::next(node->it_position);
        it_color = it_1->color;
        it_2 = it_1->right;

        if (it_1->parent == node)
            it_2->parent = it_1;

        else {
            __transplant(it_1, it_1->right);
            it_1->right = node->right;
            it_1->right->parent = it_1;
        }

        __transplant(node, it_1);
        it_1->left = node->left;
        it_1->left->parent = it_1;
        it_1->color = node->color;
    }

    if (it_color)
        __delete_process(it_2);
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__transplant(node_ptr& node_1, node_ptr& node_2) {

    if (node_1->parent == __link)
        __root = node_2;

    else if (node_1 == node_1->parent->left)
        node_1->parent->left = node_2;

    else 
        node_1->parent->right = node_2;

    node_2->parent = node_1->parent;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__delete_process(node_ptr& node) {

    while ( (node != __root) and (node->color) ) {

        if (node == node->parent->left)
            __delete_process_side( node, &node_type::left,
                                   &node_type::right );

        else
            __delete_process_side( node, &node_type::right,
                                   &node_type::left );            
    }

    node->color = true;
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__delete_process_side( node_ptr& node, node_ptr node_type::*side_1, 
                       node_ptr node_type::*side_2) {

    node_ptr it = node->parent->* side_2;

    if (!it->color) {
        it->color = true;
        node->parent->color = false;
        __rotation(node->parent, side_1, side_2);
        it = node->parent->* side_2;
    }

    if ( ( (it->* side_1)->color ) and ( (it->* side_2)->color ) ) {
        it->color = false;
        node = node->parent;
    }

    else {

        if ( (it->* side_2)->color ) {

            (it->* side_1)->color = true;
            it->color = false;
            __rotation(it, side_2, side_1);
            it = node->parent->* side_2;
        }

        it->color = node->parent->color;
        node->parent->color = true;
        (it->* side_2)->color = true;
        __rotation(node->parent, side_1, side_2);
        node = __root;
    }
}


template < class node_type,
           class key_type,
           class alloc_type >
void rb_tree<node_type, key_type, alloc_type>::
__rotation( node_ptr node, node_ptr node_type::*side_1, 
            node_ptr node_type::*side_2 ) {
    
    node_ptr child = node->* side_2;
    node->* side_2 = child->* side_1;

    if (child->* side_1 != __link)
        (child->* side_1)->parent = node;

    child->parent = node->parent;

    if (node->parent == __link) 
        __root = child;
    
    else if (node == node->parent->* side_1)
        node->parent->* side_1 = child;
    
    else
        node->parent->* side_2 = child;

    child->* side_1 = node;
    node->parent = child;
}


template < class node_type,
           class key_type,
           class alloc_type >
bool rb_tree<node_type, key_type, alloc_type>::
__comp(const key_type& key_1, const key_type& key_2) {

    int result = __comp_py(key_1, key_2);

    if (result != -1)
        return result;
    
    clear();
    throw TypeError("Your query to tree contain inconsistent key type.");

    return true;
}


template < class node_type,
           class key_type,
           class alloc_type >
bool rb_tree<node_type, key_type, alloc_type>::
__equal(const key_type& key_1, const key_type& key_2) {

    int result = __equal_py(key_1, key_2);

    if (result != -1)
        return result;

    clear();
    throw TypeError("Your query to tree contain inconsistent key type.");

    return true;
}


#endif // __TREE_TPP