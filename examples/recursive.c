
function fibo(x)
{
    if(x == 1)
        return 1;
    if(x == 2)
        return 1;
    return fibo(x-1) + fibo(x-2);
    
}
function main()
{
    print("1 1 2 3 5 8 13 21...\n");
    print("fibonacci = ");
    print(fibo(7));
    print("\n");
}

