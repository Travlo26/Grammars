name=$1
path=$2

# These you probably do not need to modify
l="${name}Est"

l_f="${l}.gf"

examples="examples/"
e_f="${examples}Est.txt"

# These are the actual tests
cat ${e_f} | sed "s/^/p -tr -lang=${l} \"/" | sed 's/$/" | l -all | ps -bind/' | gf --run --path $path ${l_f}
