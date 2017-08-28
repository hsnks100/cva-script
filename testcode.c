
function fff() {
    print "fff()";
}
function fff2() {
    print "fff2()";
}

call fff();
call fff2();

function fffdd() {
}

i = 1;
print "-----------------";
while(i != 10){
  j = 1;

  str = "";
  while( j <= i ) {
    str = str + "*";
    j = j + 1;
  }
  i = i + 1;
  print str;
 }


print "fibonacci";

a = 0;
b = 1;

i = 1;
while(i <= 7){
  print a;
  c = b;
  b = a+b;
  a = c; 
  i = i + 1;
 }
