
TYPES = [ 'uint8_t',
          'uint16_t',
          'uint32_t',
          'uint64_t',
          'uint96_t',
          'uint128_t',
          'int8_t',
          'int16_t',
          'int32_t',
          'int64_t',
          'int96_t',
          'int128_t',
          'float32_t',
          'float64_t',
          'float80_t',
          'float96_t',
          'float128_t',
          'object' ]


def generate_from_cython_src(input_file, output_file, list_of_types, from_str):

    src = input_file.readlines()[from_str:]

    for dtype in list_of_types:

        for line in src:
            new_line = line.format(DTYPE=dtype, key='{key}', value='{value}', map_kwargs='{}')
            output_file.write(new_line)


    



