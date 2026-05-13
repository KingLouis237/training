#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    input:
    val greeting

    output:
    path "${greeting}_output.txt"

    script:
    """
    echo '${greeting}' > ${greeting}_output.txt
    """
}

/*
 * Pipeline parameters
 */
params {
    input: Path = 'data/greetings.csv'
}

workflow {

    main:

// create an array
    greetings_array= ['Hello', 'Bonjour']
// create a new channel
    greetings_ch = channel.fromPath(params.input)
    .view { csv -> "Before splitCsv: $csv" }
    .splitCsv()
    .view {csv -> "After splitCsv: $csv" }
    .map { row -> row[0] }
    .view { greeting -> "After map: $greeting" }

    // emit a greeting
    sayHello(greetings_ch)

    publish:
    first_output = sayHello.out
}

output {
    first_output {
        path 'hello_channels'
        mode 'copy'
    }
}
