//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __TC // header guards
#define __TC

#include <memory>
#include <list>
#include <iterator>
#include <utility>

#include "../exceptions/qs_exceptions.hpp"

/*
This file contains definition of red-back tree template class.
This template class has basics C++11 features. It has allocator(STL interface) as 
template argument, so user could use any allocator wich provides std::allocator interface.
To speed up insertion, deletion operations one can use pool allocators (Boost pool allocator, 
for example).
**/

namespace qseries {

//---------------------------------------------------------------------------------------
// Template class for red-black tree node
//---------------------------------------------------------------------------------------
/*
Black nodes have color equals to true, red nodes have color equals to false.
**/

template <class key_type>
class rb_node {

    public:

        //Typedefs
        typedef rb_node*                                 self_ptr;
        typedef rb_node&                                 self_ref;
        typedef const rb_node&                           const_ref;
        typedef const rb_node*                           const_ptr;
        typedef rb_node&&                                self_rref;
        typedef typename std::list<self_ptr>::iterator   iterator;             

        // Attributes
        self_ptr left;
        self_ptr right;
        self_ptr parent;
        key_type key;
        iterator it_position;
        bool     color;

        // Constructors
        rb_node();
        rb_node(const_ref other);
        rb_node(self_rref other);
        rb_node(const key_type& key);
        rb_node(key_type&& key);
        rb_node(const key_type& key, self_ptr left, self_ptr right);
        ~rb_node();

        // Operators
        self_ref operator=(const_ref other);
};

// Include template class implementation
#include "rb_node.tpp"



//---------------------------------------------------------------------------------------
// Template class for valued red-black tree node
//---------------------------------------------------------------------------------------

template <class key_type, class val_type>
class rb_node_valued {

    public:

        //Typedefs
        typedef rb_node_valued*                         self_ptr;
        typedef rb_node_valued&                         self_ref;
        typedef const rb_node_valued&                   const_ref;
        typedef const rb_node_valued*                   const_ptr;
        typedef rb_node_valued&&                        self_rref;
        typedef typename std::list<self_ptr>::iterator  iterator;             

        // Attributes
        self_ptr left;
        self_ptr right;
        self_ptr parent;
        key_type key;
        val_type value;
        iterator it_position;
        bool     color;

        // Constructors
        rb_node_valued();
        rb_node_valued(const_ref other);
        rb_node_valued(self_rref other);
        rb_node_valued(const key_type& key, const val_type& value);
        rb_node_valued(key_type&& key, val_type&& value);
        rb_node_valued(const key_type& key, self_ptr left, self_ptr right);
        ~rb_node_valued();

        // Operators
        self_ref operator=(const_ref other);
};

// Include template class implementation
#include "rb_node_valued.tpp"


//-------------------------------------------------------------------------------------------
// Template class for red-black tree
//-------------------------------------------------------------------------------------------
template < class node_type,
           class key_type,
           class alloc_type = std::allocator<node_type> >
class rb_tree {

    public:

        // Typedefs
        typedef typename std::allocator_traits<alloc_type>     alloc_traits;
        typedef node_type*                                     node_ptr;
        typedef node_type&                                     node_ref;
        typedef const node_type*                               const_node_ptr;
        typedef const node_type&                               const_node_ref;
        typedef typename alloc_traits::size_type               size_type;
        typedef rb_tree*                                       ptr;
        typedef rb_tree&                                       ref;
        typedef rb_tree&&                                      rref;
        typedef const rb_tree&                                 const_ref;
        typedef const rb_tree*                                 const_ptr;
        typedef typename std::list<node_ptr>::iterator         iterator;
        typedef const typename std::list<node_ptr>::iterator   const_iterator;
        typedef typename std::pair<node_ptr, node_ptr>         node_pair;
        typedef int  (*key_compare_py)(const key_type&, const key_type&);
        typedef bool (*key_compare)(const key_type&, const key_type&);

        // Constructors
        rb_tree();
        rb_tree(const_ref other);
        ~rb_tree();

        // Methods
        size_type size();
        void clear();

        // Iterators
        iterator begin();
        iterator end();
        iterator back();
        const_iterator cbegin() const;
        const_iterator cend() const;

        // Modifiers
        node_ptr insert(const key_type&);
        node_ptr insert(key_type&&);
        node_ptr insert(const_node_ref);
        node_ptr insert(node_type&&);
        node_ptr insert(node_ptr&, const node_type&);
        node_ptr insert_search(const key_type&);
        void erase(const key_type&);
        void erase(node_ptr);
        void set_compare(key_compare_py);
        void set_equal(key_compare_py);

        // Search
        node_ptr root();
        node_ptr link();
        node_ptr search(const key_type&);

        // Interpolation
        std::pair<node_ptr, node_ptr> linear_search_from(node_ptr, const key_type&);
        std::pair<node_ptr, node_ptr> tree_search(const key_type&); 

        // Operators
        ref operator=(const_ref other);

    private:

        // Atributes
        node_ptr              __root;
        node_ptr              __begin;
        node_ptr              __end;
        node_ptr              __link;
        key_compare_py        __comp_py;
        key_compare_py        __equal_py;
        size_type             __size;
        alloc_type            __allocator;
        std::list<node_ptr>   __nodes;

        // Insert helpers
        void __insert(node_ptr&, node_ptr&);
        void __insert_process(node_ptr&);
        int  __insert_update(node_ptr&);
        void __insert_process_red(node_ptr&, node_ptr&);
        void __insert_process_side( node_ptr&, node_ptr node_type::*side_1, 
                                    node_ptr node_type::*side_2 );

        // Delete helpers
        void __delete(node_ptr&);
        void __transplant(node_ptr&, node_ptr&);
        void __delete_process(node_ptr&);
        void __delete_process_side( node_ptr&, node_ptr node_type::*side_1, 
                                    node_ptr node_type::*side_2 );
        void __rotation( node_ptr, node_ptr node_type::*side_1, 
                         node_ptr node_type::*side_2 );
        // Comparators wrappers(__comp_py, __equal_py) for handling Python exceptions
        bool __comp(const key_type&, const key_type&);
        bool __equal(const key_type&, const key_type&);
};

// Include template class implementation
#include "rb_tree.tpp"


} // namespace qseries



#endif // __TC