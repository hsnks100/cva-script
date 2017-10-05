number kang; 
function fibo(x) {
    if(x == 1)
        return 1;
    if(x == 2)
        return 1;

    if(x > 2) {
        return fibo(x-1) + fibo(x-2);
    } 
} 

function whileTest() {
    whilei = 10;

    while( whilei > 1) {
        whilei = whilei - 1;
        print(whilei);
    } 
}

function printTriangle() {
    i = 0;
    for(i=0; i<10; i=i+1) {

        if(i == 7) { 
            break;
        }
        if(i == 3) {
            continue;
        }
        for(j=0; j<i; j=j+1) { 
            print("*");
        }
        print("\n");
    } 
} 

function main()
{

    print(5);
    print("\n");
    print(fibo(10));
    print("\n\n\n");
    whileTest(); 
    print("\n\n\n");

    printTriangle();
    print("\n\n\n");
}

