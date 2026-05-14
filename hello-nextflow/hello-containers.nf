#!/usr/bin/env nextflow


// Include modules
include { sayHello } from '/workspaces/training/hello-nextflow/modules/sayHello.nf'
include { convertToUpper } from '/workspaces/training/hello-nextflow/modules/convertToUpper.nf'
include { collectGreetings } from '/workspaces/training/hello-nextflow/modules/collectGreetings.nf'
include { cowpy } from '/workspaces/training/hello-nextflow/modules/cowpy.nf'

/*
 * Pipeline parameters
 */
params {
    input: Path = 'data/greetings.csv'
    batch: String = 'batch'
    character: String = 'moose'
}

workflow {

    main:
    // create a channel for inputs from a CSV file
    greeting_ch = channel.fromPath(params.input)
                        .splitCsv()
                        .map { line -> line[0] }
    // emit a greeting
    sayHello(greeting_ch)
    // convert the greeting to uppercase
    convertToUpper(sayHello.out)
    // collect all the greetings into one file
    collectGreetings(convertToUpper.out.collect(), params.batch)
    // Run cowpy to generate ASCII art of the greetings
    cowpy(collectGreetings.out.outfile, params.character)

    publish:
    first_output = sayHello.out
    uppercased = convertToUpper.out
    collected = collectGreetings.out.outfile
    batch_report = collectGreetings.out.report
    mycowpy = cowpy.out
}

output {
    first_output {
        path 'hello_containers'
        mode 'copy'
    }
    uppercased {
        path 'hello_containers'
        mode 'copy'
    }
    collected {
        path 'hello_containers'
        mode 'copy'
    }
    batch_report {
        path 'hello_containers'
        mode 'copy'
    }
    mycowpy {
        path 'hello_containers'
        mode 'copy'
    }
}
