myf(a)
{
    if(a < 1) {
        return 1;
    }
    else {
        return a * myf(a-1); 
    } 
}
main()
{
    kang = myf(6);

    println("%d", kang);

}

