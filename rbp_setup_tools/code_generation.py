#
#  Created by Soldoskikh Kirill.
#  Copyright 2018 Intuition. All rights reserved.
#

# Generates templated source code for multiple types.
def generate_from_cython_src(input_file, output_file, list_of_types, from_str):

    src = input_file.readlines()[from_str:]

    for dtype in list_of_types:
        for line in src:
            new_line = line.format( DTYPE=dtype, key='{key}', 
                                    value='{value}', map_kwargs='{}')
            output_file.write(new_line)
