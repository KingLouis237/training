#! /usr/bin/env nextflow





/*
* We using text replacement tool to convert greeting to upper case letters
*/
process convertToUpper{

    input:
    path input_file

    output:
    path "UPPER-${input_file}"

    script:
    """
    cat '${input_file}' | tr '[a-z]' '[A-Z]' > UPPER-${input_file}
    """
}


