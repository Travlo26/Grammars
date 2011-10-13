
# Declare the name of the grammar and the paths to the used libraries
name="Address"
path=":../Numerals/:../lib/"

# These you probably do not need to modify
l="${name}App"

examples="examples/"
e_f="${examples}App.txt"

# These are the actual tests
cat ${e_f} |\
sed "s/^/p -lang=${l} \"/" |\
sed "s/$/\" | l/" |\
gf --run --path $path ${name}???.gf
