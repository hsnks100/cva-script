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
    printTriangle();
}
