---

title: shell-scripting-recipes
date: 2018-06-02 10:27 UTC
tags:

---
# Overview

The aim of this article to give you the smallest set of recipes for easily writing robust Bash a shell scripts.

This means there's going to be nothing that's "clever" - solid POSIX compliant like your dad used to code.

You'll need your favourite editor and a terminal. I'm going to recommend you install [Shellcheck](https://github.com/koalaman/shellcheck) which you can use to check your shell scripts before you run them. Because shell scripts often do a lot of disk I/O, they often take a long time to run. So, checking them beforehand can save you a lot of time.

# Recipes
## Script Header

Start  scripts with the following:

    #!/bin/sh
    set -Eeuo pipefail

The first line causes the script to run using the `sh` command. This is preferable to than `bash`, as it has a smaller set of commands and  forces you to write simpler scripts.

The second line makes the shell strict with errors. It is short for:

    set -e
    set -u
    set -o pipefail

* `-e` causes the script to exit if there's an error.
* `-u` tells the shell that unset variables are an error.
* `-o` pipefail' tells the shell that errors in pipes should be treated as errors.

You can add `set -x` and the shell to print out each command as it is executed.

## Function Header

This format also applies to functions, you should set this as the first line of your function:

    hello_world() {
      set -Eeuo pipefail

      echo "Hello world!"
    }

Put this together with your script header:

    #!/bin/sh
    set -Eeuo pipefail

    hello_world() {
      set -Eeuo pipefail

      echo "Hello world!"
    }

    hello_world

Then run it as follows:

    $ ./hello_world
    Hello World!

## Input Recipes

Scripts and functions can take input in two ways:

* Parameters
* Standard input

### Parameter Recipes

Parameters are assigned to variables `$1`, `$2`, ... It's handy to assign them to variables:

    hello_world() {
      set -Eeuo pipefail

      name=$1

      echo "Hello $name!"
    }

    $ ./hello_world Barbara
    Hello Barbara!

You can also give variables defaults, in case they are not passed:

    hello_world() {
      set -Eeuo pipefail

      name=${1:-"Anonymous"}

      echo "Hello $name!"
    }

    $ ./hello_world
    Hello Anonymous!

It's often useful to validate your inputs, so the following snippet prevents illegal names:

    hello_world() {
      set -Eeuo pipefail

      name=$1

      [ "$name" = "" ] && echo "invalid name" >&2 && exit 1

      echo "Hello $name!"
    }

    $ ./hello_world ''
    invalid name

### Standard Input

Scripts and functions can also read from standard in, allowing you to used them as part of a pipeline:

    hello_world() {
      set -Eeuo pipefail

      while read name ; do
        echo "Hello $name!"
      done
    }

To use this script, `cat` a file to it:

    $ cat names.txt | ./hello_world
    Hello Barbara Bellamy!
    Hello John Smith!

This is useful if you want to build your script up from a number of smaller parts.

    add_salutation() {
      set -Eeuo pipefail

      while read name ; do
        case $name in
          Barbara*)
            echo "Ms $name"
            ;;
          John*)
            echo "Mr $name"
            ;;
          *)
            echo "invalid name $name" >&2 && exit 1
            ;;
        esac
      done
    }

    ...

    add_salutation | hello_world

    $ cat names.txt | ./hello_world
    Hello Ms Barbara Bellamy!
    Hello Mr John Smith!

Standard input is more flexible than parameters typically. You can use both together.

## Map-Filter Recipes

A typical script might:

* Read lines from a file
* Map each line, e.g. to extract a value
* Filter some of those values out

Linux is full of map and filter commands, e.g.

Filter out John:

    $ cat names.txt | grep -v John
    Barbara Bellamy

Add "Hello Ms"

    $ cat names.txt | grep -v John | sed 's/\(.*\)/Hello Ms \1/'
    Hello Ms Barbara Bellamy

Both `find` and `grep` return error exit code if they don't find what they were looking for. There are a lot of cases where that's just fine. E.g. when `names.txt` does not contain a name.

    cat names.txt | grep Alex

Would fail. Append `|| true` to make this pass if no match is found:

    cat names.txt | grep Alex || true

To demonstrate map-filter, lets create a script that takes a CSV file and prints hello word:

    names.csv
    FIRST NAME,LAST NAME
    "Barbara","Bellamy"
    John,Smith

Tricky!

    rm_quotes() {
      set -Eeuo pipefail

      text=$1

      echo $text | sed 's/^"\(.*\)"$/\1/'
    }

    csv2txt() {
      set -Eeuo pipefail

      read header ;# discard the header row

      # split on commas
      while IFS=, read -r first_name last_name ; do
        echo $(rm_quotes "$first_name") $(rm_quotes "$last_name")
      done
    }

    csv2txt | add_salutation | hello_world

    $ ./hello_world
    Hello Ms Barbara Bellamy!
    Hello Mr John Smith!

That's a pretty naive `csv2txt` function, but it might work for many uses cases.

# Marker File

A marker file is a file used to indicate a long running task has already run, and does not need to be run again, or is already running, and should not start.

For example, only run the find if the output file has not already been created:

    [ ! -e text_files ] && find . -name '*.txt' > text_files

In that example, the file `text_files` is output of find, and implicitly a marker file. You can be explicit:

    find_text_files() {
      set -Eeuo pipefail

      find . -name '*.txt' > text_files
    }

    [ ! -e /tmp/find.marker ] && find_text_files && touch /tmp/find.marker

## Variable Names

I recommend they are lower-case, to make them clearly different to from environment variables, which are usually upper-case.
