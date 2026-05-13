#!/usr/bin/env nextflow

/*
 * Use echo to print 'Hello World!' to a file
 */
process sayHello {

    input:
    val greeting

    output:
    path "${greeting}-output.txt"

    script:
    """
    echo '${greeting}' > '${greeting}-output.txt'
    """
}


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



/*
* Collecting uppercase greetings into a single output file
*/
process collectGreetings {

    input:
    path upper_files
    val batch_name

    output:
    path "COLLECTED-${batch_name}-output.txt", emit: outfile
    path "${batch_name}-report.txt", emit: report

    script:
    count_greetings = upper_files.size()
    """
    cat ${upper_files} > COLLECTED-${batch_name}-output.txt
    echo 'There were ${count_greetings} greetings in this batch' > '${batch_name}-report.txt'
    """
}

/*
 * Pipeline parameters
 */
params {
    input: Path = 'data/greetings.csv'
    batch: String = 'batch'
}

workflow {

    main:
    // create a channel for inputs from a CSV file
    greeting_ch = channel.fromPath(params.input)
                        .splitCsv()
                        .map { line -> line[0] }
    // emit a greeting
    sayHello(greeting_ch)
    convertToUpper(sayHello.out)
    collectGreetings(convertToUpper.out.collect(), params.batch)

    publish:
    first_output = sayHello.out
    second_output = convertToUpper.out
    outfile = collectGreetings.out.outfile
    report = collectGreetings.out.report
}

output {
    first_output {
        path 'hello_workflow'
        mode 'copy'
    }
    second_output {
        path 'hello_workflow'
        mode 'copy'
    }
    outfile {
        path 'hello_workflow'
        mode 'copy'
    }
    report {
        path 'hello_workflow'
        mode 'copy'
    }
}
