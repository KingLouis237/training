#!/usr/bin/env nextflow

/*
* Pipeline parameters
*/

params {
    input: String = 'Hello World!'}
/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    input:
    val greeting

    output:
    path 'output.txt'

    script:
    """
    echo '${greeting}' > output.txt
    """
}

workflow {

    main:
    // emit a greeting
    sayHello(params.input)

    publish:
    first_output = sayHello.out
}


output {
    first_output {
        path 'hello_world'
        mode 'copy'
    }
}
