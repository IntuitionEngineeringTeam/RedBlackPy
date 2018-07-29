//
//  Created by Soldoskikh Kirill.
//  Copyright © 2018 Intuition. All rights reserved.
//

#ifndef __ITER // header guards
#define __ITER

#include <iterator>
#include <utility>
#include <string>

#include "../tree/tree.hpp"


namespace qseries {

//-------------------------------------------------------------------------------------------
// Template class of bidirectional iterator over multiple trees
//-------------------------------------------------------------------------------------------
template <class tree_type, class node_type>
class trees_iterator : public std::iterator< std::bidirectional_iterator_tag,
                                             node_type > {


    // Private typedefs
    typedef typename tree_type::iterator                     node_iter;
    typedef typename std::pair<tree_type*, node_iter>        pair_t;
    typedef rb_node<std::pair<tree_type*, node_iter>>        node_t;
    typedef typename rb_tree<node_t, pair_t>::iterator       queue_iterator;
    typedef typename rb_tree<node_t, pair_t>::key_compare_py key_compare_py;

    // Function pointers
    // tail_queue and tail_tree is related to begin(), back() tree member functions
    typedef queue_iterator (rb_tree<node_t, pair_t>::*tail_queue)(void);
    typedef node_iter      (tree_type::*tail_tree)(void);
    typedef node_iter      (*advance_t)(node_iter);

    public:
        // Constructros
        trees_iterator();
        trees_iterator(const trees_iterator&);
        template <class Iterable> trees_iterator( Iterable&, std::string);
        template <class Iterable> trees_iterator( Iterable&, std::string,
                                                  key_compare_py,
                                                  key_compare_py );
        ~trees_iterator();

        // Methods
        bool empty();
        template <class Iterable> void set_iterator(Iterable&, std::string);
        void set_compare(key_compare_py);
        void set_equal(key_compare_py);

        // Operators
        bool operator==(const trees_iterator&) const;
        bool operator!=(const trees_iterator&) const;
        trees_iterator& operator++(int);
        trees_iterator& operator--(int);
        trees_iterator& operator=(const trees_iterator&);
        node_type& operator*() const;


    private:
        // Attributes
        pair_t*                 __current;
        rb_tree<node_t, pair_t> __queue;
        key_compare_py          __comp_py;
        key_compare_py          __equal_py;

        // Advance
        static node_iter __next(node_iter);
        static node_iter __prev(node_iter);
        void __advance(advance_t, tail_tree, tail_queue);
        template <class Iterable> void __set_iterator( Iterable&, 
                                                       tail_tree, 
                                                       tail_queue );
        // Comparators wrappers for Python exception handling
        bool __comp(const pair_t&, const pair_t&);
        bool __equal(const pair_t&, const pair_t&);
};

// Include template class implementation
#include "iterator.tpp"


} // namespace qseries



#endif // __ITER