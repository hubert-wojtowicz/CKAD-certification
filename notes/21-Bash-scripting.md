# Based on https://www.learnshell.org/en/Hello%2C_World%21
## Variables

`#!/bin/bash` - Bash ("Bourne Again Shell")
sh, csh, tcsh - other shells

```sh
#!/bin/bash

BIRTHDATE="Jan 1, 2000"
Presents=10
BIRTHDAY=`date -d "$BIRTHDATE" +%A`

greeting='Hello        world!'
echo $greeting" now with spaces: $greeting"  # Hello world! now with spaces: Hello        world!

# Testing code - do not change it

if [ "$BIRTHDATE" == "Jan 1, 2000" ] ; then
    echo "BIRTHDATE is correct, it is $BIRTHDATE"
else
    echo "BIRTHDATE is incorrect - please retry"
fi
if [ $Presents == 10 ] ; then
    echo "I have received $Presents presents"
else
    echo "Presents is incorrect - please retry"
fi
if [ "$BIRTHDAY" == "Saturday" ] ; then
    echo "I was born on a $BIRTHDAY"
else
    echo "BIRTHDAY is incorrect - please retry"
fi
```

# Passing Arguments to the Script

```
$#                                                  # count of script params
$@                                                  # a space delimited string of all arguments passed to the script
$0                                                  # references to the current script
$1, .., $n                                          # ref to subsequent parameters

args=("$@")
echo ${args[0]} ${args[1]} ${args[2]}
echo $#                                             # prints the length f the array
```

# Arrays
```sh
my_array=(apple banana "Fruit Basket" orange)
echo $my_array                                      # apple
echo ${my_array[3]}                                 # orange - note that curly brackets are needed
# adding another array element
my_array[4]="carrot"                                # value assignment without a $ and curly brackets
echo ${#my_array[@]}                                # 5
echo ${#my_array}                                   # 5
echo ${my_array[${#my_array[@]}-1]}                 # carrot
```

# Basic Operators

```sh
A=3
B=$((100 * $A + 5)) # 305
```

# Logical Operators
```sh
expr1; expr2                                        # semicolon means the same as putting expr2 into new line
expr1 && expr2                                      # execute expr2 only if expr1 return zero status code
expr1 || expr2                                      # execute expr2 only if expr1 return non-zero status code
expr1 & expr2                                       # execute both in parallel
sleep 5 & echo 'started sleep command'              # it will run sleep 5 in a septate process
```

- using those operators eliminate need for using if statement in most cases

# Strings
```sh
STRING="this is a string"
echo $STRING                # this is a string
echo ${#STRING}             # 16
echo ${STRING:2:3}          # is
echo ${STRING:1}            # his is a string

DATARECORD="last=Clifford,first=Johnny Boy,state=CA"

```

# Types of numeric comparisons
comparison    Evaluated to true when
$a -lt $b    $a < $b
$a -gt $b    $a > $b
$a -le $b    $a <= $b
$a -ge $b    $a >= $b
$a -eq $b    $a is equal to $b
$a -ne $b    $a is not equal to $b

# Types of string comparisons
comparison    Evaluated to true when
"$a" = "$b"     $a is the same as $b
"$a" == "$b"    $a is the same as $b
"$a" != "$b"    $a is different from $b
-z "$a"         $a is empty

# If statement 

```sh
NAME="George"
if [ "$NAME" = "John" ]; then
  echo "John Lennon"
elif [ "$NAME" = "George" ]; then
  echo "George Harrison"
else
  echo "This leaves us with Paul and Ringo"
fi
```

# Pipelines
`ls / | wc -l`

By default pipelines redirects only the standard output, if you want to include the standard error you need to use the form `|&` which is a short hand for `2>&1 |`.

# Redirection

0 - STDIN
1 - STDOUT
2 - STDERR

1>&2 - redirect STOUT into STDERR
2>/dev/null - do not care of errors

>   - override
>>  - append